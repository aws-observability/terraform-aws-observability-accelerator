#!/usr/bin/env python3
"""
Transform standard Prometheus/AMP Grafana dashboards for Zeus (CloudWatch OTLP).

Zeus label mapping:
- cluster       -> REMOVED (no cluster label in Zeus)
- job           -> @resource.service.name (with different values)
- instance      -> @resource.service.instance.id
- Job name mapping:
    kubernetes-kubelet  -> kubelet (scraped via prometheus receiver)
    kubernetes-nodes    -> node-exporter
    kube-state-metrics  -> kube-state-metrics
    node-exporter       -> node-exporter

Recording rules are expanded to raw PromQL since Zeus has no recording rule engine.
"""

import json
import re
import sys
import os

# Job name mapping: AMP dashboard job name -> Zeus @resource.service.name
# The OTel scrape config uses job_name: "kubelet", "node-exporter", "kube-state-metrics"
# Zeus stores these as @resource.service.name values
JOB_MAP = {
    "kubernetes-kubelet": "kubelet",
    "kubernetes-nodes": "node-exporter",
    "kube-state-metrics": "kube-state-metrics",
    "node-exporter": "node-exporter",
    "kubelet": "kubelet-cadvisor",
    "cadvisor": "kubelet-cadvisor",
    "node": "node-exporter",
}

# Recording rule expansions: standard Kubernetes monitoring mixin recording rules
# expanded to raw PromQL for Zeus (which has no recording rule engine).
# Label transforms (cluster/job/instance) are applied AFTER expansion.
RECORDING_RULE_EXPANSIONS = {
    "cluster:node_cpu:ratio_rate5m":
        '1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))',

    ":node_memory_MemAvailable_bytes:sum":
        "node_memory_MemAvailable_bytes",

    "node_memory_MemAvailable_bytes:sum":
        "node_memory_MemAvailable_bytes",

    "namespace_cpu:kube_pod_container_resource_requests:sum":
        'sum(kube_pod_container_resource_requests{resource="cpu"}) by (namespace)',

    "namespace_cpu:kube_pod_container_resource_limits:sum":
        'sum(kube_pod_container_resource_limits{resource="cpu"}) by (namespace)',

    "namespace_memory:kube_pod_container_resource_requests:sum":
        'sum(kube_pod_container_resource_requests{resource="memory"}) by (namespace)',

    "namespace_memory:kube_pod_container_resource_limits:sum":
        'sum(kube_pod_container_resource_limits{resource="memory"}) by (namespace)',

    "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate":
        "sum(irate(container_cpu_usage_seconds_total[5m])) by (namespace, pod, container, node)",

    "namespace_workload_pod:kube_pod_owner:relabel":
        'max(kube_pod_owner{owner_kind=~"ReplicaSet|StatefulSet|DaemonSet|Job"}) by (namespace, workload, pod, workload_type)',

    "node_namespace_pod_container:container_memory_working_set_bytes":
        "container_memory_working_set_bytes",

    "node_namespace_pod_container:container_memory_rss":
        "container_memory_rss",

    "node_namespace_pod_container:container_memory_cache":
        "container_memory_cache",

    "node_namespace_pod_container:container_memory_swap":
        "container_memory_swap",

    "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests":
        'kube_pod_container_resource_requests{resource="cpu"}',

    "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits":
        'kube_pod_container_resource_limits{resource="cpu"}',

    "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests":
        'kube_pod_container_resource_requests{resource="memory"}',

    "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits":
        'kube_pod_container_resource_limits{resource="memory"}',
}


def transform_expr(expr: str) -> str:
    """Transform a PromQL expression from AMP labels to Zeus labels."""
    if not expr:
        return expr

    original = expr

    # 0. Expand recording rules to raw PromQL
    # Sort by length descending to match longest names first
    for rule_name in sorted(RECORDING_RULE_EXPANSIONS.keys(), key=len, reverse=True):
        expansion = RECORDING_RULE_EXPANSIONS[rule_name]
        # Replace recording rule name, preserving any label selectors after it
        # Match the rule name when it appears as a metric name (not inside quotes)
        # Handle: rule_name{labels}, rule_name by (...), rule_name)
        pattern = re.escape(rule_name)
        if re.search(pattern, expr):
            # If the recording rule has selectors after it like {node=~"$node"}
            # we need to merge them into the expansion
            def expand_rule(match):
                before = match.group(0)
                return expansion
            # Simple replacement - recording rule used as a bare metric name
            expr = expr.replace(rule_name, f"({expansion})")

    # 1. Remove cluster="$cluster" filter (with optional spaces and comma handling)
    # Pattern: cluster="$cluster", (with trailing comma+space)
    expr = re.sub(r'cluster\s*=\s*"[^"]*"\s*,\s*', '', expr)
    # Pattern: , cluster="$cluster" (with leading comma)
    expr = re.sub(r',\s*cluster\s*=\s*"[^"]*"', '', expr)
    # Pattern: cluster="$cluster" alone in braces
    expr = re.sub(r'\{\s*cluster\s*=\s*"[^"]*"\s*\}', '{}', expr)

    # 2. Replace job="xxx" with "@resource.service.name"="yyy"
    # Note: @ labels must be double-quoted in PromQL
    def replace_job(match):
        op = match.group(1)  # = or =~ or != or !~
        val = match.group(2)
        # Try exact match first, then substring replacement
        if val in JOB_MAP:
            val = JOB_MAP[val]
        else:
            # For regex patterns, replace longest matches first
            for old_name in sorted(JOB_MAP.keys(), key=len, reverse=True):
                val = val.replace(old_name, JOB_MAP[old_name])
        return f'"@resource.service.name"{op}"{val}"'

    expr = re.sub(r'job\s*(=~?|!=|!~)\s*"([^"]*)"', replace_job, expr)

    # 3. Replace instance=~"$instance" with "@resource.service.instance.id"=~"$instance"
    expr = re.sub(
        r'instance\s*(=~?|!=|!~)\s*"([^"]*)"',
        r'"@resource.service.instance.id"\1"\2"',
        expr
    )

    # 4. Replace bare instance in by() clauses with backtick-quoted label
    # Zeus PromQL uses backticks for @ labels in by() clauses:
    #   by (`@resource.service.instance.id`, other_label)
    expr = re.sub(
        r'\b(by\s*\([^)]*)\binstance\b([^)]*\))',
        r'\1`@resource.service.instance.id`\2',
        expr
    )

    # 5. Clean up empty selectors: metric{} -> metric
    expr = re.sub(r'\{\s*\}', '', expr)

    return expr


def transform_template_var(var: dict) -> dict:
    """Transform a template variable definition."""
    var = var.copy()
    name = var.get("name", "")

    if name == "cluster":
        # Remove the cluster variable entirely - Zeus doesn't have it
        return None

    if name == "instance":
        # Change label_values query to use @resource.service.instance.id
        # In label_values(), @ labels are UNQUOTED:
        #   label_values(metric{...}, @resource.service.instance.id)
        # But inside selectors {}, @ labels are double-quoted:
        #   label_values(metric{"@resource.service.name"="kubelet"}, ...)
        if "query" in var:
            q = var["query"]
            if isinstance(q, str):
                q = q.replace(", instance)", ", @resource.service.instance.id)")
                q = transform_expr(q)
                var["query"] = q
            elif isinstance(q, dict) and "query" in q:
                qq = q["query"]
                qq = qq.replace(", instance)", ", @resource.service.instance.id)")
                qq = transform_expr(qq)
                var["query"]["query"] = qq

    elif "query" in var:
        q = var["query"]
        if isinstance(q, str):
            var["query"] = transform_expr(q)
        elif isinstance(q, dict) and "query" in q:
            var["query"]["query"] = transform_expr(q["query"])

    return var


def transform_panel(panel: dict) -> dict:
    """Transform all targets in a panel."""
    panel = panel.copy()

    # Transform targets
    if "targets" in panel:
        new_targets = []
        for target in panel["targets"]:
            target = target.copy()
            if "expr" in target:
                target["expr"] = transform_expr(target["expr"])
            new_targets.append(target)
        panel["targets"] = new_targets

    # Transform nested panels (rows)
    if "panels" in panel:
        panel["panels"] = [transform_panel(p) for p in panel["panels"]]

    return panel


def transform_dashboard(dash: dict) -> dict:
    """Transform an entire dashboard for Zeus."""
    dash = dash.copy()

    # Update title
    if "title" in dash:
        dash["title"] = dash["title"] + " (Zeus)"

    # Add zeus tag
    tags = dash.get("tags", [])
    if "zeus" not in tags:
        tags = tags + ["zeus"]
    dash["tags"] = tags

    # Transform template variables
    if "templating" in dash and "list" in dash["templating"]:
        new_vars = []
        for var in dash["templating"]["list"]:
            transformed = transform_template_var(var)
            if transformed is not None:
                new_vars.append(transformed)
        dash["templating"]["list"] = new_vars

    # Transform panels
    if "panels" in dash:
        dash["panels"] = [transform_panel(p) for p in dash["panels"]]

    # Remove id to allow Grafana to assign new ones
    dash.pop("id", None)
    dash.pop("version", None)

    return dash


def main():
    if len(sys.argv) < 3:
        print("Usage: zeus-dashboard-transform.py <input.json> <output.json>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    with open(input_path) as f:
        dash = json.load(f)

    transformed = transform_dashboard(dash)

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(transformed, f, indent=2)

    print(f"Transformed: {input_path} -> {output_path}")


if __name__ == "__main__":
    main()
