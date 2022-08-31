# Prioritize recording rules over alerting rules for limits (10)

################################################################################################################################################
# Recording rules ##############################################################################################################################
################################################################################################################################################

resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count        = var.enable_recording_rules ? 1 : 0
  name         = "acclerator-infra-rules"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: noderules-01
    rules:
      - record: "node_namespace_pod:kube_pod_info:"
        expr: topk by(cluster, namespace, pod) (1, max by(cluster, node, namespace, pod) (label_replace(kube_pod_info{job="kube-state-metrics",node!=""}, "pod", "$1", "pod", "(.*)")))
  - name: noderules-02
    rules:
      - record: node:node_num_cpu:sum
        expr: count by(cluster, node) (sum by(node, cpu) (node_cpu_seconds_total{job="node-exporter"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, node_namespace_pod:kube_pod_info:)))
  - name: noderules-03
    rules:
      - record: :node_memory_MemAvailable_bytes:sum
        expr: sum by(cluster) (node_memory_MemAvailable_bytes{job="node-exporter"} or (node_memory_Buffers_bytes{job="node-exporter"} + node_memory_Cached_bytes{job="node-exporter"} + node_memory_MemFree_bytes{job="node-exporter"} + node_memory_Slab_bytes{job="node-exporter"}))
  - name: noderules-04
    rules:
      - record: cluster:node_cpu:ratio_rate5m
        expr: sum(rate(node_cpu_seconds_total{job="node-exporter",mode!="idle",mode!="iowait",mode!="steal"}[5m])) / count(sum by(cluster, instance, cpu) (node_cpu_seconds_total{job="node-exporter"}))
  - name: kubelet-01
    rules:
      - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
        labels:
          quantile: 0.99
  - name: kubelet-02
    rules:
      - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.9, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
        labels:
          quantile: 0.9
  - name: kubelet-03
    rules:
      - record: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.5, sum by(cluster, instance, le) (rate(kubelet_pleg_relist_duration_seconds_bucket[5m])) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet",metrics_path="/metrics"})
        labels:
          quantile: 0.5
  - name: nerules-01
    rules:
      - record: instance:node_num_cpu:sum
        expr: count without(cpu, mode) (node_cpu_seconds_total{job="node-exporter",mode="idle"})
  - name: nerules-02
    rules:
      - record: instance:node_cpu_utilisation:rate5m
        expr: 1 - avg without(cpu) (sum without(mode) (rate(node_cpu_seconds_total{job="node-exporter",mode=~"idle|iowait|steal"}[5m])))
  - name: nerules-03
    rules:
      - record: instance:node_load1_per_cpu:ratio
        expr: (node_load1{job="node-exporter"} / instance:node_num_cpu:sum{job="node-exporter"})
  - name: nerules-04
    rules:
      - record: instance:node_memory_utilisation:ratio
        expr: 1 - ((node_memory_MemAvailable_bytes{job="node-exporter"} or (node_memory_Buffers_bytes{job="node-exporter"} + node_memory_Cached_bytes{job="node-exporter"} + node_memory_MemFree_bytes{job="node-exporter"} + node_memory_Slab_bytes{job="node-exporter"})) / node_memory_MemTotal_bytes{job="node-exporter"})
  - name: nerules-05
    rules:
      - record: instance:node_vmstat_pgmajfault:rate5m
        expr: rate(node_vmstat_pgmajfault{job="node-exporter"}[5m])
  - name: nerules-06
    rules:
      - record: instance_device:node_disk_io_time_seconds:rate5m
        expr: rate(node_disk_io_time_seconds_total{device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+",job="node-exporter"}[5m])
  - name: nerules-07
    rules:
      - record: instance_device:node_disk_io_time_weighted_seconds:rate5m
        expr: rate(node_disk_io_time_weighted_seconds_total{device=~"mmcblk.p.+|nvme.+|rbd.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+",job="node-exporter"}[5m])
  - name: nerules-08
    rules:
      - record: instance:node_network_receive_bytes_excluding_lo:rate5m
        expr: sum without(device) (rate(node_network_receive_bytes_total{device!="lo",job="node-exporter"}[5m]))
  - name: nerules-09
    rules:
      - record: instance:node_network_transmit_bytes_excluding_lo:rate5m
        expr: sum without(device) (rate(node_network_transmit_bytes_total{device!="lo",job="node-exporter"}[5m]))
  - name: nerules-10
    rules:
      - record: instance:node_network_receive_drop_excluding_lo:rate5m
        expr: sum without(device) (rate(node_network_receive_drop_total{device!="lo",job="node-exporter"}[5m]))
  - name: nerules-11
    rules:
      - record: instance:node_network_transmit_drop_excluding_lo:rate5m
        expr: sum without(device) (rate(node_network_transmit_drop_total{device!="lo",job="node-exporter"}[5m]))
  - name: kubeschdlr-01
    rules:
      - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.99
  - name: kubeschdlr-02
    rules:
      - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.99
  - name: kubeschdlr-03
    rules:
      - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.99
  - name: kubeschdlr-04
    rules:
      - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.9
  - name: kubeschdlr-05
    rules:
      - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.9
  - name: kubeschdlr-06
    rules:
      - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.9, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.9
  - name: kubeschdlr-07
    rules:
      - record: cluster_quantile:scheduler_e2e_scheduling_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_e2e_scheduling_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.5
  - name: kubeschdlr-08
    rules:
      - record: cluster_quantile:scheduler_scheduling_algorithm_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_scheduling_algorithm_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.5
  - name: kubeschdlr-09
    rules:
      - record: cluster_quantile:scheduler_binding_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.5, sum without(instance, pod) (rate(scheduler_binding_duration_seconds_bucket{job="kube-scheduler"}[5m])))
        labels:
          quantile: 0.5
  - name: kubepromnr-01
    rules:
      - record: instance:node_cpu:rate:sum
        expr: sum by(instance) (rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[3m]))
  - name: kubepromnr-02
    rules:
      - record: instance:node_network_receive_bytes:rate:sum
        expr: sum by(instance) (rate(node_network_receive_bytes_total[3m]))
  - name: kubepromnr-03
    rules:
      - record: instance:node_network_transmit_bytes:rate:sum
        expr: sum by(instance) (rate(node_network_transmit_bytes_total[3m]))
  - name: kubepromnr-04
    rules:
      - record: instance:node_cpu:ratio
        expr: sum without(cpu, mode) (rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[5m])) / on(instance) group_left() count by(instance) (sum by(instance, cpu) (node_cpu_seconds_total))
  - name: kubepromnr-05
    rules:
      - record: cluster:node_cpu:sum_rate5m
        expr: sum(rate(node_cpu_seconds_total{mode!="idle",mode!="iowait",mode!="steal"}[5m]))
  - name: kubepromnr-06
    rules:
      - record: cluster:node_cpu:ratio
        expr: cluster:node_cpu:sum_rate5m / count(sum by(instance, cpu) (node_cpu_seconds_total))
  - name: kubprom-01
    rules:
      - record: count:up1
        expr: count without(instance, pod, node) (up == 1)
  - name: kubprom-02
    rules:
      - record: count:up0
        expr: count without(instance, pod, node) (up == 0)
  - name: apihg-01
    rules:
      - record: cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum by(cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m]))) > 0
        labels:
          quantile: 0.99
          verb: read
  - name: apihg-02
    rules:
      - record: cluster_quantile:apiserver_request_slo_duration_seconds:histogram_quantile
        expr: histogram_quantile(0.99, sum by(cluster, le, resource) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) > 0
        labels:
          quantile: 0.99
          verb: write
  - name: apibr-01
    rules:
      - record: apiserver_request:burnrate1d
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1d]))
        labels:
          verb: read
  - name: apibr-02
    rules:
      - record: apiserver_request:burnrate1h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1h]))
        labels:
          verb: read
  - name: apibr-03
    rules:
      - record: apiserver_request:burnrate2h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[2h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[2h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[2h]))
        labels:
          verb: read
  - name: apibr-04
    rules:
      - record: apiserver_request:burnrate30m
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[30m])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[30m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[30m]))
        labels:
          verb: read
  - name: apibr-05
    rules:
      - record: apiserver_request:burnrate3d
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[3d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[3d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[3d]))
        labels:
          verb: read
  - name: apibr-06
    rules:
      - record: apiserver_request:burnrate5m
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[5m])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[5m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[5m]))
        labels:
          verb: read
  - name: apibr-07
    rules:
      - record: apiserver_request:burnrate6h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[6h])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[6h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[6h]))
        labels:
          verb: read
  - name: apibr-08
    rules:
      - record: apiserver_request:burnrate1d
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1d])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1d]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1d]))
        labels:
          verb: read
  - name: apibr-09
    rules:
      - record: apiserver_request:burnrate1d
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) - ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",scope=~"resource|",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) or vector(0)) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="5",scope="namespace",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])) + sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="30",scope="cluster",subresource!~"proxy|attach|log|exec|portforward",verb=~"LIST|GET"}[1d])))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"LIST|GET"}[1d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"LIST|GET"}[1d]))
        labels:
          verb: write
  - name: apibr-10
    rules:
      - record: apiserver_request:burnrate1h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[1h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[1h]))
        labels:
          verb: write
  - name: apibr-11
    rules:
      - record: apiserver_request:burnrate2h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[2h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[2h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[2h]))
        labels:
          verb: write
  - name: apibr-12
    rules:
      - record: apiserver_request:burnrate30m
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[30m])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[30m]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[30m]))
        labels:
          verb: write
  - name: apibr-13
    rules:
      - record: apiserver_request:burnrate3d
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[3d])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[3d]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[3d]))
        labels:
          verb: write
  - name: apibr-14
    rules:
      - record: apiserver_request:burnrate5m
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[5m]))
        labels:
          verb: write
  - name: apibr-15
    rules:
      - record: apiserver_request:burnrate6h
        expr: ((sum by(cluster) (rate(apiserver_request_slo_duration_seconds_count{job="apiserver",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[6h])) - sum by(cluster) (rate(apiserver_request_slo_duration_seconds_bucket{job="apiserver",le="1",subresource!~"proxy|attach|log|exec|portforward",verb=~"POST|PUT|PATCH|DELETE"}[6h]))) + sum by(cluster) (rate(apiserver_request_total{code=~"5..",job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))) / sum by(cluster) (rate(apiserver_request_total{job="apiserver",verb=~"POST|PUT|PATCH|DELETE"}[6h]))
        labels:
          verb: write
  - name: api-01
    rules:
      - record: code_verb:apiserver_request_total:increase30d
        expr: avg_over_time(code_verb:apiserver_request_total:increase1h[30d]) * 24 * 30
  - name: api-02
    rules:
      - record: code:apiserver_request_total:increase30d
        expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"LIST|GET"})
        labels:
          verb: read
  - name: api-03
    rules:
      - record: code:apiserver_request_total:increase30d
        expr: sum by(cluster, code) (code_verb:apiserver_request_total:increase30d{verb=~"POST|PUT|PATCH|DELETE"})
        labels:
          verb: write
  - name: api-04
    rules:
      - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h
        expr: sum by(cluster, verb, scope) (increase(apiserver_request_slo_duration_seconds_count[1h]))
  - name: api-05
    rules:
      - record: cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase30d
        expr: sum by(cluster, verb, scope) (avg_over_time(cluster_verb_scope:apiserver_request_slo_duration_seconds_count:increase1h[30d]) * 24 * 30)
  - name: k8s-01
    rules:
      - record: node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate
        expr: sum by(cluster, namespace, pod, container) (irate(container_cpu_usage_seconds_total{image!="",job="kubelet",metrics_path=~".*/metrics/cadvisor"}[5m])) * on(cluster, namespace, pod) group_left(node) topk by(cluster, namespace, pod) (1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))

  - name: k8s-02
    rules:
      - record: node_namespace_pod_container:container_memory_working_set_bytes
        expr: container_memory_working_set_bytes{image!="",job="kubelet",metrics_path=~".*/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
  - name: k8s-03
    rules:
      - record: node_namespace_pod_container:container_memory_rss
        expr: container_memory_rss{image!="",job="kubelet",metrics_path=~".*/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
  - name: k8s-04
    rules:
      - record: node_namespace_pod_container:container_memory_cache
        expr: container_memory_cache{image!="",job="kubelet",metrics_path=~".*/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
  - name: k8s-05
    rules:
      - record: node_namespace_pod_container:container_memory_swap
        expr: container_memory_swap{image!="",job="kubelet",metrics_path=~".*/metrics/cadvisor"} * on(namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))
  - name: k8s-06
    rules:
      - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_requests
        expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
  - name: k8s-07
    rules:
      - record: namespace_memory:kube_pod_container_resource_requests:sum
        expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
  - name: k8s-08
    rules:
      - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests
        expr: kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
  - name: k8s-09
    rules:
      - record: namespace_cpu:kube_pod_container_resource_requests:sum
        expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
  - name: k8s-10
    rules:
      - record: cluster:namespace:pod_memory:active:kube_pod_container_resource_limits
        expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
  - name: k8s-11
    rules:
      - record: namespace_memory:kube_pod_container_resource_limits:sum
        expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="memory"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
  - name: k8s-12
    rules:
      - record: cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits
        expr: kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"} * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))
  - name: k8s-13
    rules:
      - record: namespace_cpu:kube_pod_container_resource_limits:sum
        expr: sum by(namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{job="kube-state-metrics",resource="cpu"}) * on(namespace, pod, cluster) group_left() max by(namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))
  - name: k8s-14
    rules:
      - record: namespace_workload_pod:kube_pod_owner:relabel
        expr: max by(cluster, namespace, workload, pod) (label_replace(label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="ReplicaSet"}, "replicaset", "$1", "owner_name", "(.*)") * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (1, max by(replicaset, namespace, owner_name) (kube_replicaset_owner{job="kube-state-metrics"})), "workload", "$1", "owner_name", "(.*)"))
        labels:
          workload_type: deployment
  - name: k8s-15
    rules:
      - record: namespace_workload_pod:kube_pod_owner:relabel
        expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="DaemonSet"}, "workload", "$1", "owner_name", "(.*)"))
        labels:
          workload_type: daemonset
  - name: k8s-16
    rules:
      - record: namespace_workload_pod:kube_pod_owner:relabel
        expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="StatefulSet"}, "workload", "$1", "owner_name", "(.*)"))
        labels:
          workload_type: statefulset
  - name: k8s-17
    rules:
      - record: namespace_workload_pod:kube_pod_owner:relabel
        expr: max by(cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics",owner_kind="Job"}, "workload", "$1", "owner_name", "(.*)"))
        labels:
          workload_type: job
EOF
}
