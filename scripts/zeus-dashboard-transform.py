#!/usr/bin/env python3
"""
Transform standard Prometheus/AMP Grafana dashboards for Zeus (CloudWatch OTLP).

The OTel collector's transform/zeus_compat processor promotes resource attributes
to metric-level attributes:
  service.name        -> job      (standard Prometheus label)
  service.instance.id -> instance (standard Prometheus label)

This means dashboards can use standard job/instance labels and work on any
Grafana version (v10+). The only transforms needed here are:
  1. Remove cluster label (not present in Zeus)
  2. Remap job values (OTel scrape job names differ from AMP dashboard defaults)
  3. Expand recording rules to raw PromQL (no recording rule engine in Zeus)
"""

import json
import re
import sys
import os

# Job name mapping: AMP dashboard job name -> OTel collector scrape job_name
# The collector sets service.name = job_name from scrape config, which the
# transform/zeus_compat processor then copies to the "job" metric attribute.
JOB_MAP = {
    "kubernetes-kubelet": "kubelet",
    "kubernetes-nodes": "node-exporter",
    "kube-state-metrics": "kube-state-metrics",
    "node-exporter": "node-exporter",
    "cadvisor": "kubelet-cadvisor",
    "node": "node-exporter",
}

# Recording rule expansions: standard Kubernetes monitoring mixin recording rules
# expanded to raw PromQL for Zeus (which has no recording rule engine).
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
    """Transform a PromQL expression for Zeus."""
    if not expr:
        return expr

    # 0. Expand recording rules to raw PromQL
    for rule_name in sorted(RECORDING_RULE_EXPANSIONS.keys(), key=len, reverse=True):
        expansion = RECORDING_RULE_EXPANSIONS[rule_name]
        if rule_name in expr:
            expr = expr.replace(rule_name, f"({expansion})")

    # 1. Remove cluster="$cluster" filter
    expr = re.sub(r'cluster\s*=\s*"[^"]*"\s*,\s*', '', expr)
    expr = re.sub(r',\s*cluster\s*=\s*"[^"]*"', '', expr)
    expr = re.sub(r'\{\s*cluster\s*=\s*"[^"]*"\s*\}', '{}', expr)

    # 2. Remap job values (keep job as the label name, just change values)
    def replace_job(match):
        op = match.group(1)
        val = match.group(2)
        if val in JOB_MAP:
            val = JOB_MAP[val]
        else:
            for old_name in sorted(JOB_MAP.keys(), key=len, reverse=True):
                val = val.replace(old_name, JOB_MAP[old_name])
        return f'job{op}"{val}"'

    expr = re.sub(r'job\s*(=~?|!=|!~)\s*"([^"]*)"', replace_job, expr)

    # 3. Clean up empty selectors: metric{} -> metric
    expr = re.sub(r'\{\s*\}', '', expr)

    return expr


def transform_template_var(var: dict) -> dict:
    """Transform a template variable definition."""
    var = var.copy()
    name = var.get("name", "")

    if name == "cluster":
        return None

    if "query" in var:
        q = var["query"]
        if isinstance(q, str):
            var["query"] = transform_expr(q)
        elif isinstance(q, dict) and "query" in q:
            var["query"]["query"] = transform_expr(q["query"])

    return var


def transform_panel(panel: dict) -> dict:
    """Transform all targets in a panel."""
    panel = panel.copy()

    if "targets" in panel:
        new_targets = []
        for target in panel["targets"]:
            target = target.copy()
            if "expr" in target:
                target["expr"] = transform_expr(target["expr"])
            new_targets.append(target)
        panel["targets"] = new_targets

    if "panels" in panel:
        panel["panels"] = [transform_panel(p) for p in panel["panels"]]

    return panel


def transform_dashboard(dash: dict) -> dict:
    """Transform an entire dashboard for Zeus."""
    dash = dash.copy()

    if "title" in dash:
        dash["title"] = dash["title"] + " (Zeus)"

    tags = dash.get("tags", [])
    if "zeus" not in tags:
        tags = tags + ["zeus"]
    dash["tags"] = tags

    if "templating" in dash and "list" in dash["templating"]:
        new_vars = []
        for var in dash["templating"]["list"]:
            transformed = transform_template_var(var)
            if transformed is not None:
                new_vars.append(transformed)
        dash["templating"]["list"] = new_vars

    if "panels" in dash:
        dash["panels"] = [transform_panel(p) for p in dash["panels"]]

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
