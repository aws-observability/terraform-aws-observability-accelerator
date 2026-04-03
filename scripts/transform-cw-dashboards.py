#!/usr/bin/env python3
"""Transform zeus dashboards for CloudWatch PromQL compatibility.

Changes:
1. Add @resource.k8s.cluster.name variable for multi-cluster filtering
2. Replace recording rule reference with raw kube_pod_owner query
3. Fix hardcoded datasource UIDs to use $datasource variable
4. Add @aws.account and @aws.region variables
"""
import json, glob, sys, os, copy

SRC = "dashboards/zeus"
DST = "dashboards/cloudwatch-otlp"

os.makedirs(DST, exist_ok=True)

# Cluster variable template
CLUSTER_VAR = {
    "datasource": {"type": "prometheus", "uid": "$datasource"},
    "definition": "",
    "hide": 0,
    "includeAll": True,
    "multi": True,
    "name": "cluster",
    "options": [],
    "query": {
        "query": "label_values(kube_node_info, k8s_cluster_name)",
        "refId": "Prometheus-cluster-Variable-Query"
    },
    "refresh": 2,
    "regex": "",
    "skipUrlSync": False,
    "sort": 1,
    "type": "query",
    "current": {"selected": True, "text": "All", "value": "$__all"}
}

AWS_ACCOUNT_VAR = {
    "datasource": {"type": "prometheus", "uid": "$datasource"},
    "definition": "",
    "hide": 0,
    "includeAll": True,
    "multi": True,
    "name": "aws_account",
    "options": [],
    "query": {
        "query": "label_values(kube_node_info, aws_account)",
        "refId": "Prometheus-account-Variable-Query"
    },
    "refresh": 2,
    "regex": "",
    "skipUrlSync": False,
    "sort": 1,
    "type": "query",
    "current": {"selected": True, "text": "All", "value": "$__all"}
}

for src_path in sorted(glob.glob(f"{SRC}/*.json")):
    fname = os.path.basename(src_path)
    d = json.load(open(src_path))

    # 1. Fix datasource UIDs — replace hardcoded "prometheus" with "$datasource"
    text = json.dumps(d)
    text = text.replace('"uid": "prometheus"', '"uid": "$datasource"')
    text = text.replace('"uid":"prometheus"', '"uid":"$datasource"')
    d = json.loads(text)

    # 2. Add cluster + aws_account variables after the datasource variable
    tmpl = d.get("templating", {}).get("list", [])
    new_vars = []
    for v in tmpl:
        new_vars.append(v)
        if v.get("name") == "datasource":
            new_vars.append(copy.deepcopy(CLUSTER_VAR))
            new_vars.append(copy.deepcopy(AWS_ACCOUNT_VAR))
    d.setdefault("templating", {})["list"] = new_vars

    # 3. Replace recording rule in namespace-workloads variable
    for v in d["templating"]["list"]:
        if isinstance(v.get("query"), dict):
            q = v["query"].get("query", "")
            q = q.replace(
                'namespace_workload_pod:kube_pod_owner:relabel{cluster="$cluster", namespace="$namespace", workload=~".+"}, workload_type',
                '(max(kube_pod_owner{owner_kind=~"ReplicaSet|StatefulSet|DaemonSet|Job"}) by (namespace, workload, pod, workload_type)){namespace="$namespace"}, workload_type'
            )
            v["query"]["query"] = q
        if isinstance(v.get("definition"), str):
            v["definition"] = v["definition"].replace(
                'namespace_workload_pod:kube_pod_owner:relabel',
                '(max(kube_pod_owner{owner_kind=~"ReplicaSet|StatefulSet|DaemonSet|Job"}) by (namespace, workload, pod, workload_type))'
            )

    dst_path = f"{DST}/{fname}"
    with open(dst_path, "w") as f:
        json.dump(d, f, indent=2)
    print(f"  {fname} -> {dst_path}")

print("\nDone.")
