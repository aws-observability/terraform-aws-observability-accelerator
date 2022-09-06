################################################################################################################################################
# Alerting rules ###############################################################################################################################
################################################################################################################################################

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.enable_alerting_rules ? 1 : 0

  name         = "accelerator-infra-alerting"
  workspace_id = var.managed_prometheus_workspace_id
  data         = <<EOF
groups:
  - name: infra-alerts-01
    rules:
      - alert: NodeNetworkInterfaceFlapping
        expr: changes(node_network_up{device!~"veth.+",job="node-exporter"}[2m]) > 2
        for: 2m
        labels:
          severity: warning
        annotations:
          description: Network interface "{{ $labels.device }}" changing its up status often on node-exporter {{ $labels.namespace }}/{{ $labels.pod }}
          summary: Network interface is often changing its status
      - alert: NodeFilesystemSpaceFillingUp
        expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 15 and predict_linear(node_filesystem_avail_bytes{fstype!="",job="node-exporter"}[6h], 24 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left and is filling up.
          summary: Filesystem is predicted to run out of space within the next 24 hours.
      - alert: NodeFilesystemSpaceFillingUp
        expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 10 and predict_linear(node_filesystem_avail_bytes{fstype!="",job="node-exporter"}[6h], 4 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: critical
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left and is filling up fast.
          summary: Filesystem is predicted to run out of space within the next 4 hours.
      - alert: NodeFilesystemAlmostOutOfSpace
        expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 3 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 30m
        labels:
          severity: warning
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left.
          summary: Filesystem has less than 3% space left.
      - alert: NodeFilesystemAlmostOutOfSpace
        expr: (node_filesystem_avail_bytes{fstype!="",job="node-exporter"} / node_filesystem_size_bytes{fstype!="",job="node-exporter"} * 100 < 5 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 30m
        labels:
          severity: critical
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available space left.
          summary: Filesystem has less than 5% space left.
      - alert: NodeFilesystemFilesFillingUp
        expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 40 and predict_linear(node_filesystem_files_free{fstype!="",job="node-exporter"}[6h], 24 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left and is filling up.
          summary: Filesystem is predicted to run out of inodes within the next 24 hours.
      - alert: NodeFilesystemFilesFillingUp
        expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 20 and predict_linear(node_filesystem_files_free{fstype!="",job="node-exporter"}[6h], 4 * 60 * 60) < 0 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: critical
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left and is filling up fast.
          summary: Filesystem is predicted to run out of inodes within the next 4 hours.
      - alert: NodeFilesystemAlmostOutOfFiles
        expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 5 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left.
          summary: Filesystem has less than 5% inodes left.
      - alert: NodeFilesystemAlmostOutOfFiles
        expr: (node_filesystem_files_free{fstype!="",job="node-exporter"} / node_filesystem_files{fstype!="",job="node-exporter"} * 100 < 3 and node_filesystem_readonly{fstype!="",job="node-exporter"} == 0)
        for: 1h
        labels:
          severity: critical
        annotations:
          description: Filesystem on {{ $labels.device }} at {{ $labels.instance }} has only {{ printf "%.2f" $value }}% available inodes left.
          summary: Filesystem has less than 3% inodes left.
      - alert: NodeNetworkReceiveErrs
        expr: rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01
        for: 1h
        labels:
          severity: warning
        annotations:
          description: The {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} receive errors in the last two minutes.
          summary: Network interface is reporting many receive errors.
      - alert: NodeNetworkTransmitErrs
        expr: rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01
        for: 1h
        labels:
          severity: warning
        annotations:
          description: The {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf "%.0f" $value }} transmit errors in the last two minutes.
          summary: Network interface is reporting many transmit errors.
      - alert: NodeHighNumberConntrackEntriesUsed
        expr: (node_nf_conntrack_entries / node_nf_conntrack_entries_limit) > 0.75
        labels:
          severity: warning
        annotations:
          description: The {{ $value | humanizePercentage }} of conntrack entries are used.
          summary: Number of conntrack are getting close to the limit.
      - alert: NodeTextFileCollectorScrapeError
        expr: node_textfile_scrape_error{job="node-exporter"} == 1
        labels:
          severity: warning
        annotations:
          description: Node Exporter text file collector failed to scrape.
          summary: Node Exporter text file collector failed to scrape.
      - alert: NodeClockSkewDetected
        expr: (node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[5m]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0)
        for: 10m
        labels:
          severity: warning
        annotations:
          description: Clock on {{ $labels.instance }} is out of sync by more than 300s. Ensure NTP is configured correctly on this host.
          summary: Clock skew detected.
      - alert: NodeClockNotSynchronising
        expr: min_over_time(node_timex_sync_status[5m]) == 0 and node_timex_maxerror_seconds >= 16
        for: 10m
        labels:
          severity: warning
        annotations:
          description: Clock on {{ $labels.instance }} is not synchronising. Ensure NTP is configured on this host.
          summary: Clock not synchronising.
      - alert: NodeRAIDDegraded
        expr: node_md_disks_required - ignoring(state) (node_md_disks{state="active"}) > 0
        for: 15m
        labels:
          severity: critical
        annotations:
          description: RAID array '{{ $labels.device }}' on {{ $labels.instance }} is in degraded state due to one or more disks failures. Number of spare drives is insufficient to fix issue automatically.
          summary: RAID Array is degraded
      - alert: NodeRAIDDiskFailure
        expr: node_md_disks{state="failed"} > 0
        labels:
          severity: warning
        annotations:
          description: At least one device in RAID array on {{ $labels.instance }} failed. Array '{{ $labels.device }}' needs attention and possibly a disk swap.
          summary: Failed device in RAID array
      - alert: NodeFileDescriptorLimit
        expr: (node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 70)
        for: 15m
        labels:
          severity: warning
        annotations:
          description: File descriptors limit at {{ $labels.instance }} is currently at {{ printf "%.2f" $value }}%.
          summary: Kernel is predicted to exhaust file descriptors limit soon.
      - alert: NodeFileDescriptorLimit
        expr: (node_filefd_allocated{job="node-exporter"} * 100 / node_filefd_maximum{job="node-exporter"} > 90)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: File descriptors limit at {{ $labels.instance }} is currently at {{ printf "%.2f" $value }}%.
          summary: Kernel is predicted to exhaust file descriptors limit soon.
      - alert: KubeSchedulerDown
        expr: absent(up{job="kube-scheduler"} == 1)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: KubeScheduler has disappeared from Prometheus target discovery.
          summary: Target disappeared from Prometheus target discovery.
  - name: infra-alerts-02
    rules:
      - alert: KubeNodeNotReady
        expr: kube_node_status_condition{condition="Ready",job="kube-state-metrics",status="true"} == 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: The {{ $labels.node }} has been unready for more than 15 minutes.
          summary: Node is not ready.
      - alert: KubeNodeUnreachable
        expr: (kube_node_spec_taint{effect="NoSchedule",job="kube-state-metrics",key="node.kubernetes.io/unreachable"} unless ignoring(key, value) kube_node_spec_taint{job="kube-state-metrics",key=~"ToBeDeletedByClusterAutoscaler|cloud.google.com/impending-node-termination|aws-node-termination-handler/spot-itn"}) == 1
        for: 15m
        labels:
          severity: warning
        annotations:
          description: The {{ $labels.node }} is unreachable and some workloads may be rescheduled.
          summary: Node is unreachable.
      - alert: KubeletTooManyPods
        expr: count by(cluster, node) ((kube_pod_status_phase{job="kube-state-metrics",phase="Running"} == 1) * on(instance, pod, namespace, cluster) group_left(node) topk by(instance, pod, namespace, cluster) (1, kube_pod_info{job="kube-state-metrics"})) / max by(cluster, node) (kube_node_status_capacity{job="kube-state-metrics",resource="pods"} != 1) > 0.95
        for: 15m
        labels:
          severity: info
        annotations:
          description: Kubelet '{{ $labels.node }}' is running at {{ $value | humanizePercentage }} of its Pod capacity.
          summary: Kubelet is running at capacity.
      - alert: KubeNodeReadinessFlapping
        expr: sum by(cluster, node) (changes(kube_node_status_condition{condition="Ready",status="true"}[15m])) > 2
        for: 15m
        labels:
          severity: warning
        annotations:
          description: The readiness status of node {{ $labels.node }} has changed {{ $value }} times in the last 15 minutes.
          summary: Node readiness status is flapping.
      - alert: KubeletPlegDurationHigh
        expr: node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile{quantile="0.99"} >= 10
        for: 5m
        labels:
          severity: warning
        annotations:
          description: The Kubelet Pod Lifecycle Event Generator has a 99th percentile duration of {{ $value }} seconds on node {{ $labels.node }}.
          summary: Kubelet Pod Lifecycle Event Generator is taking too long to relist.
      - alert: KubeletPodStartUpLatencyHigh
        expr: histogram_quantile(0.99, sum by(cluster, instance, le) (rate(kubelet_pod_worker_duration_seconds_bucket{job="kubelet"}[5m]))) * on(cluster, instance) group_left(node) kubelet_node_name{job="kubelet"} > 60
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Kubelet Pod startup 99th percentile latency is {{ $value }} seconds on node {{ $labels.node }}.
          summary: Kubelet Pod startup latency is too high.
      - alert: KubeletClientCertificateExpiration
        expr: kubelet_certificate_manager_client_ttl_seconds < 604800
        labels:
          severity: warning
        annotations:
          description: Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
          summary: Kubelet client certificate is about to expire.
      - alert: KubeletClientCertificateExpiration
        expr: kubelet_certificate_manager_client_ttl_seconds < 86400
        labels:
          severity: critical
        annotations:
          description: Client certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
          summary: Kubelet client certificate is about to expire.
      - alert: KubeletServerCertificateExpiration
        expr: kubelet_certificate_manager_server_ttl_seconds < 604800
        labels:
          severity: warning
        annotations:
          description: Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
          summary: Kubelet server certificate is about to expire.
      - alert: KubeletServerCertificateExpiration
        expr: kubelet_certificate_manager_server_ttl_seconds < 86400
        labels:
          severity: critical
        annotations:
          description: Server certificate for Kubelet on node {{ $labels.node }} expires in {{ $value | humanizeDuration }}.
          summary: Kubelet server certificate is about to expire.
      - alert: KubeletClientCertificateRenewalErrors
        expr: increase(kubelet_certificate_manager_client_expiration_renew_errors[5m]) > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Kubelet on node {{ $labels.node }} has failed to renew its client certificate ({{ $value | humanize }} errors in the last 5 minutes).
          summary: Kubelet has failed to renew its client certificate.
      - alert: KubeletServerCertificateRenewalErrors
        expr: increase(kubelet_server_expiration_renew_errors[5m]) > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Kubelet on node {{ $labels.node }} has failed to renew its server certificate ({{ $value | humanize }} errors in the last 5 minutes).
          summary: Kubelet has failed to renew its server certificate.
      - alert: KubeletDown
        expr: absent(up{job="kubelet"} == 1)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: Kubelet has disappeared from Prometheus target discovery.
          summary: Target disappeared from Prometheus target discovery.
      - alert: KubeProxyDown
        expr: absent(up{job="kube-proxy"} == 1)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: KubeProxy has disappeared from Prometheus target discovery.
          summary: Target disappeared from Prometheus target discovery.
      - alert: KubeVersionMismatch
        expr: count by(cluster) (count by(git_version, cluster) (label_replace(kubernetes_build_info{job!~"kube-dns|coredns"}, "git_version", "$1", "git_version", "(v[0-9]*.[0-9]*).*"))) > 1
        for: 15m
        labels:
          severity: warning
        annotations:
          description: There are {{ $value }} different semantic versions of Kubernetes components running.
          summary: Different semantic versions of Kubernetes components running.
      - alert: KubeClientErrors
        expr: (sum by(cluster, instance, job, namespace) (rate(rest_client_requests_total{code=~"5.."}[5m])) / sum by(cluster, instance, job, namespace) (rate(rest_client_requests_total[5m]))) > 0.01
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Kubernetes API server client '{{ $labels.job }}/{{ $labels.instance }}' is experiencing {{ $value | humanizePercentage }} errors.'
          summary: Kubernetes API server client is experiencing errors.
      - alert: KubeControllerManagerDown
        expr: absent(up{job="kube-controller-manager"} == 1)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: KubeControllerManager has disappeared from Prometheus target discovery.
          summary: Target disappeared from Prometheus target discovery.
      - alert: KubeClientCertificateExpiration
        expr: apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by(job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 604800
        labels:
          severity: warning
        annotations:
          description: A client certificate used to authenticate to kubernetes apiserver is expiring in less than 7.0 days.
          summary: Client certificate is about to expire.
      - alert: KubeClientCertificateExpiration
        expr: apiserver_client_certificate_expiration_seconds_count{job="apiserver"} > 0 and on(job) histogram_quantile(0.01, sum by(job, le) (rate(apiserver_client_certificate_expiration_seconds_bucket{job="apiserver"}[5m]))) < 86400
        labels:
          severity: critical
        annotations:
          description: A client certificate used to authenticate to kubernetes apiserver is expiring in less than 24.0 hours.
          summary: Client certificate is about to expire.
      - alert: KubeAggregatedAPIErrors
        expr: sum by(name, namespace, cluster) (increase(aggregator_unavailable_apiservice_total[10m])) > 4
        labels:
          severity: warning
        annotations:
          description: Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has reported errors. It has appeared unavailable {{ $value | humanize }} times averaged over the past 10m.
          summary: Kubernetes aggregated API has reported errors.
  - name: infra-alerts-03
    rules:
      - alert: KubeAggregatedAPIDown
        expr: (1 - max by(name, namespace, cluster) (avg_over_time(aggregator_unavailable_apiservice[10m]))) * 100 < 85
        for: 5m
        labels:
          severity: warning
        annotations:
          description: Kubernetes aggregated API {{ $labels.name }}/{{ $labels.namespace }} has been only {{ $value | humanize }}% available over the last 10m.
          summary: Kubernetes aggregated API is down.
      - alert: KubeAPIDown
        expr: absent(up{job="apiserver"} == 1)
        for: 15m
        labels:
          severity: critical
        annotations:
          description: KubeAPI has disappeared from Prometheus target discovery.
          summary: Target disappeared from Prometheus target discovery.
      - alert: KubeAPITerminatedRequests
        expr: sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m])) / (sum(rate(apiserver_request_total{job="apiserver"}[10m])) + sum(rate(apiserver_request_terminations_total{job="apiserver"}[10m]))) > 0.2
        for: 5m
        labels:
          severity: warning
        annotations:
          description: The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests.
          summary: The kubernetes apiserver has terminated {{ $value | humanizePercentage }} of its incoming requests.
      - alert: KubePersistentVolumeFillingUp
        expr: (kubelet_volume_stats_available_bytes{job="kubelet",namespace=~".*"} / kubelet_volume_stats_capacity_bytes{job="kubelet",namespace=~".*"}) < 0.03 and kubelet_volume_stats_used_bytes{job="kubelet",namespace=~".*"} > 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
        for: 1m
        labels:
          severity: critical
        annotations:
          description: The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is only {{ $value | humanizePercentage }} free.
          summary: PersistentVolume is filling up.
      - alert: KubePersistentVolumeFillingUp
        expr: (kubelet_volume_stats_available_bytes{job="kubelet",namespace=~".*"} / kubelet_volume_stats_capacity_bytes{job="kubelet",namespace=~".*"}) < 0.15 and kubelet_volume_stats_used_bytes{job="kubelet",namespace=~".*"} > 0 and predict_linear(kubelet_volume_stats_available_bytes{job="kubelet",namespace=~".*"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to fill up within four days.
          summary: PersistentVolume is filling up.
      - alert: KubePersistentVolumeInodesFillingUp
        expr: (kubelet_volume_stats_inodes_free{job="kubelet",namespace=~".*"} / kubelet_volume_stats_inodes{job="kubelet",namespace=~".*"}) < 0.03 and kubelet_volume_stats_inodes_used{job="kubelet",namespace=~".*"} > 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
        for: 1m
        labels:
          severity: critical
        annotations:
          description: The PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} only has {{ $value | humanizePercentage }} free inodes.
          summary: PersistentVolumeInodes is filling up.
      - alert: KubePersistentVolumeInodesFillingUp
        expr: (kubelet_volume_stats_inodes_free{job="kubelet",namespace=~".*"} / kubelet_volume_stats_inodes{job="kubelet",namespace=~".*"}) < 0.15 and kubelet_volume_stats_inodes_used{job="kubelet",namespace=~".*"} > 0 and predict_linear(kubelet_volume_stats_inodes_free{job="kubelet",namespace=~".*"}[6h], 4 * 24 * 3600) < 0 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_access_mode{access_mode="ReadOnlyMany"} == 1 unless on(namespace, persistentvolumeclaim) kube_persistentvolumeclaim_labels{label_excluded_from_alerts="true"} == 1
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Based on recent sampling, the PersistentVolume claimed by {{ $labels.persistentvolumeclaim }} in Namespace {{ $labels.namespace }} is expected to run out of inodes within four days. Currently {{ $value | humanizePercentage }} of its inodes are free.
          summary: PersistentVolumeInodes are filling up.
      - alert: KubePersistentVolumeErrors
        expr: kube_persistentvolume_status_phase{job="kube-state-metrics",phase=~"Failed|Pending"} > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          description: The persistent volume {{ $labels.persistentvolume }} has status {{ $labels.phase }}.
          summary: PersistentVolume is having issues with provisioning.
      - alert: KubeCPUOvercommit
        expr: sum(namespace_cpu:kube_pod_container_resource_requests:sum) - (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0 and (sum(kube_node_status_allocatable{resource="cpu"}) - max(kube_node_status_allocatable{resource="cpu"})) > 0
        for: 10m
        labels:
          severity: warning
        annotations:
          description: Cluster has overcommitted CPU resource requests for Pods by {{ $value }} CPU shares and cannot tolerate node failure.
          summary: Cluster has overcommitted CPU resource requests.
      - alert: KubeMemoryOvercommit
        expr: sum(namespace_memory:kube_pod_container_resource_requests:sum) - (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0 and (sum(kube_node_status_allocatable{resource="memory"}) - max(kube_node_status_allocatable{resource="memory"})) > 0
        for: 10m
        labels:
          severity: warning
        annotations:
          description: Cluster has overcommitted memory resource requests for Pods by {{ $value | humanize }} bytes and cannot tolerate node failure.
          summary: Cluster has overcommitted memory resource requests.
      - alert: KubeCPUQuotaOvercommit
        expr: sum(min without(resource) (kube_resourcequota{job="kube-state-metrics",resource=~"(cpu|requests.cpu)",type="hard"})) / sum(kube_node_status_allocatable{job="kube-state-metrics",resource="cpu"}) > 1.5
        for: 5m
        labels:
          severity: warning
        annotations:
          description: Cluster has overcommitted CPU resource requests for Namespaces.
          summary: Cluster has overcommitted CPU resource requests.
      - alert: KubeMemoryQuotaOvercommit
        expr: sum(min without(resource) (kube_resourcequota{job="kube-state-metrics",resource=~"(memory|requests.memory)",type="hard"})) / sum(kube_node_status_allocatable{job="kube-state-metrics",resource="memory"}) > 1.5
        for: 5m
        labels:
          severity: warning
        annotations:
          description: Cluster has overcommitted memory resource requests for Namespaces.
          summary: Cluster has overcommitted memory resource requests.
      - alert: KubeQuotaAlmostFull
        expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) > 0.9 < 1
        for: 15m
        labels:
          severity: info
        annotations:
          description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
          summary: Namespace quota is going to be full.
      - alert: KubeQuotaFullyUsed
        expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) == 1
        for: 15m
        labels:
          severity: info
        annotations:
          description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
          summary: Namespace quota is fully used.
      - alert: KubeQuotaExceeded
        expr: kube_resourcequota{job="kube-state-metrics",type="used"} / ignoring(instance, job, type) (kube_resourcequota{job="kube-state-metrics",type="hard"} > 0) > 1
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Namespace {{ $labels.namespace }} is using {{ $value | humanizePercentage }} of its {{ $labels.resource }} quota.
          summary: Namespace quota has exceeded the limits.
      - alert: CPUThrottlingHigh
        expr: sum by(container, pod, namespace) (increase(container_cpu_cfs_throttled_periods_total{container!=""}[5m])) / sum by(container, pod, namespace) (increase(container_cpu_cfs_periods_total[5m])) > (25 / 100)
        for: 15m
        labels:
          severity: info
        annotations:
          description: The {{ $value | humanizePercentage }} throttling of CPU in namespace {{ $labels.namespace }} for container {{ $labels.container }} in pod {{ $labels.pod }}.
          summary: Processes experience elevated CPU throttling.
      - alert: KubePodCrashLooping
        expr: max_over_time(kube_pod_container_status_waiting_reason{job="kube-state-metrics",namespace=~".*",reason="CrashLoopBackOff"}[5m]) >= 1
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) is in waiting state (reason:"CrashLoopBackOff").
          summary: Pod is crash looping.
      - alert: KubePodNotReady
        expr: sum by(namespace, pod, cluster) (max by(namespace, pod, cluster) (kube_pod_status_phase{job="kube-state-metrics",namespace=~".*",phase=~"Pending|Unknown"}) * on(namespace, pod, cluster) group_left(owner_kind) topk by(namespace, pod, cluster) (1, max by(namespace, pod, owner_kind, cluster) (kube_pod_owner{owner_kind!="Job"}))) > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Pod {{ $labels.namespace }}/{{ $labels.pod }} ({{ $labels.container }}) has been in a non-ready state for longer than 15 minutes.
          summary: Pod has been in a non-ready state for more than 15 minutes.
      - alert: KubeDeploymentGenerationMismatch
        expr: kube_deployment_status_observed_generation{job="kube-state-metrics",namespace=~".*"} != kube_deployment_metadata_generation{job="kube-state-metrics",namespace=~".*"}
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Deployment generation for {{ $labels.namespace }}/{{ $labels.deployment }} does not match, this indicates that the Deployment has failed but has not been rolled back.
          summary: Deployment generation mismatch due to possible roll-back
      - alert: KubeDeploymentReplicasMismatch
        expr: (kube_deployment_spec_replicas{job="kube-state-metrics",namespace=~".*"} > kube_deployment_status_replicas_available{job="kube-state-metrics",namespace=~".*"}) and (changes(kube_deployment_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[10m]) == 0)
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has not matched the expected number of replicas for longer than 15 minutes.
          summary: Deployment has not matched the expected number of replicas.
  - name: infra-alerts-04
    rules:
      - alert: KubeStatefulSetReplicasMismatch
        expr: (kube_statefulset_status_replicas_ready{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_status_replicas{job="kube-state-metrics",namespace=~".*"}) and (changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[10m]) == 0)
        for: 15m
        labels:
          severity: warning
        annotations:
          description: StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} has not matched the expected number of replicas for longer than 15 minutes.
          summary: Deployment has not matched the expected number of replicas.
      - alert: KubeStatefulSetGenerationMismatch
        expr: kube_statefulset_status_observed_generation{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_metadata_generation{job="kube-state-metrics",namespace=~".*"}
        for: 15m
        labels:
          severity: warning
        annotations:
          description: StatefulSet generation for {{ $labels.namespace }}/{{ $labels.statefulset }} does not match, this indicates that the StatefulSet has failed but has not been rolled back.
          summary: StatefulSet generation mismatch due to possible roll-back
      - alert: KubeStatefulSetUpdateNotRolledOut
        expr: (max without(revision) (kube_statefulset_status_current_revision{job="kube-state-metrics",namespace=~".*"} unless kube_statefulset_status_update_revision{job="kube-state-metrics",namespace=~".*"}) * (kube_statefulset_replicas{job="kube-state-metrics",namespace=~".*"} != kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"})) and (changes(kube_statefulset_status_replicas_updated{job="kube-state-metrics",namespace=~".*"}[5m]) == 0)
        for: 15m
        labels:
          severity: warning
        annotations:
          description: StatefulSet {{ $labels.namespace }}/{{ $labels.statefulset }} update has not been rolled out.
          summary: StatefulSet update has not been rolled out.
      - alert: KubeDaemonSetRolloutStuck
        expr: ((kube_daemonset_status_current_number_scheduled{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"}) or (kube_daemonset_status_number_misscheduled{job="kube-state-metrics",namespace=~".*"} != 0) or (kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"}) or (kube_daemonset_status_number_available{job="kube-state-metrics",namespace=~".*"} != kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"})) and (changes(kube_daemonset_status_updated_number_scheduled{job="kube-state-metrics",namespace=~".*"}[5m]) == 0)
        for: 15m
        labels:
          severity: warning
        annotations:
          description: DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} has not finished or progressed for at least 15 minutes.
          summary: DaemonSet rollout is stuck.
      - alert: KubeContainerWaiting
        expr: sum by(namespace, pod, container, cluster) (kube_pod_container_status_waiting_reason{job="kube-state-metrics",namespace=~".*"}) > 0
        for: 1h
        labels:
          severity: warning
        annotations:
          description: Pod/{{ $labels.pod }} in namespace {{ $labels.namespace }} on container {{ $labels.container}} has been in waiting state for longer than 1 hour.
          summary: Pod container waiting longer than 1 hour
      - alert: KubeDaemonSetNotScheduled
        expr: kube_daemonset_status_desired_number_scheduled{job="kube-state-metrics",namespace=~".*"} - kube_daemonset_status_current_number_scheduled{job="kube-state-metrics",namespace=~".*"} > 0
        for: 10m
        labels:
          severity: warning
        annotations:
          description: The {{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are not scheduled.
          summary: DaemonSet pods are not scheduled.
      - alert: KubeDaemonSetMisScheduled
        expr: kube_daemonset_status_number_misscheduled{job="kube-state-metrics",namespace=~".*"} > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: The {{ $value }} Pods of DaemonSet {{ $labels.namespace }}/{{ $labels.daemonset }} are running where they are not supposed to run.
          summary: DaemonSet pods are misscheduled.
      - alert: KubeJobNotCompleted
        expr: time() - max by(namespace, job_name, cluster) (kube_job_status_start_time{job="kube-state-metrics",namespace=~".*"} and kube_job_status_active{job="kube-state-metrics",namespace=~".*"} > 0) > 43200
        labels:
          severity: warning
        annotations:
          description: Job {{ $labels.namespace }}/{{ $labels.job_name }} is taking more than {{ "43200" | humanizeDuration }} to complete.
          summary: Job did not complete in time
      - alert: KubeJobFailed
        expr: kube_job_failed{job="kube-state-metrics",namespace=~".*"} > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: Job {{ $labels.namespace }}/{{ $labels.job_name }} failed to complete. Removing failed job after investigation should clear this alert.
          summary: Job failed to complete.
      - alert: KubeHpaReplicasMismatch
        expr: (kube_horizontalpodautoscaler_status_desired_replicas{job="kube-state-metrics",namespace=~".*"} != kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"}) and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} > kube_horizontalpodautoscaler_spec_min_replicas{job="kube-state-metrics",namespace=~".*"}) and (kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} < kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics",namespace=~".*"}) and changes(kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"}[15m]) == 0
        for: 15m
        labels:
          severity: warning
        annotations:
          description: HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has not matched the desired number of replicas for longer than 15 minutes.
          summary: HPA has not matched descired number of replicas.
      - alert: KubeHpaMaxedOut
        expr: kube_horizontalpodautoscaler_status_current_replicas{job="kube-state-metrics",namespace=~".*"} == kube_horizontalpodautoscaler_spec_max_replicas{job="kube-state-metrics",namespace=~".*"}
        for: 15m
        labels:
          severity: warning
        annotations:
          description: HPA {{ $labels.namespace }}/{{ $labels.horizontalpodautoscaler }} has been running at max replicas for longer than 15 minutes.
          summary: HPA is running at max replicas
      - alert: KubeStateMetricsListErrors
        expr: (sum(rate(kube_state_metrics_list_total{job="kube-state-metrics",result="error"}[5m])) / sum(rate(kube_state_metrics_list_total{job="kube-state-metrics"}[5m]))) > 0.01
        for: 15m
        labels:
          severity: critical
        annotations:
          description: kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects or at all.
          summary: kube-state-metrics is experiencing errors in list operations.
      - alert: KubeStateMetricsWatchErrors
        expr: (sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics",result="error"}[5m])) / sum(rate(kube_state_metrics_watch_total{job="kube-state-metrics"}[5m]))) > 0.01
        for: 15m
        labels:
          severity: critical
        annotations:
          description: kube-state-metrics is experiencing errors at an elevated rate in list operations. This is likely causing it to not be able to expose metrics about Kubernetes objects or at all.
          summary: kube-state-metrics is experiencing errors in watch operations.
      - alert: KubeStateMetricsShardingMismatch
        expr: stdvar(kube_state_metrics_total_shards{job="kube-state-metrics"}) != 0
        for: 15m
        labels:
          severity: critical
        annotations:
          description: kube-state-metrics pods are running with different --total-shards configuration, some Kubernetes objects may be exposed multiple times or not exposed at all.
          summary: kube-state-metrics sharding is misconfigured.
      - alert: KubeStateMetricsShardsMissing
        expr: 2 ^ max(kube_state_metrics_total_shards{job="kube-state-metrics"}) - 1 - sum(2 ^ max by(shard_ordinal) (kube_state_metrics_shard_ordinal{job="kube-state-metrics"})) != 0
        for: 15m
        labels:
          severity: critical
        annotations:
          description: kube-state-metrics shards are missing, some Kubernetes objects are not being exposed.
          summary: kube-state-metrics shards are missing.
      - alert: KubeAPIErrorBudgetBurn
        expr: sum(apiserver_request:burnrate1h) > (14.4 * 0.01) and sum(apiserver_request:burnrate5m) > (14.4 * 0.01)
        for: 2m
        labels:
          long: 1h
          severity: critical
          short: 5m
        annotations:
          description: The API server is burning too much error budget.
          summary: The API server is burning too much error budget.
      - alert: KubeAPIErrorBudgetBurn
        expr: sum(apiserver_request:burnrate6h) > (6 * 0.01) and sum(apiserver_request:burnrate30m) > (6 * 0.01)
        for: 15m
        labels:
          long: 6h
          severity: critical
          short: 30m
        annotations:
          description: The API server is burning too much error budget.
          summary: The API server is burning too much error budget.
      - alert: KubeAPIErrorBudgetBurn
        expr: sum(apiserver_request:burnrate1d) > (3 * 0.01) and sum(apiserver_request:burnrate2h) > (3 * 0.01)
        for: 1d
        labels:
          long: 1d
          severity: warning
          short: 2h
        annotations:
          description: The API server is burning too much error budget.
          summary: The API server is burning too much error budget.
      - alert: KubeAPIErrorBudgetBurn
        expr: sum(apiserver_request:burnrate3d) > (1 * 0.01) and sum(apiserver_request:burnrate6h) > (1 * 0.01)
        for: 3h
        labels:
          long: 3d
          severity: warning
          short: 6h
        annotations:
          description: The API server is burning too much error budget.
          summary: The API server is burning too much error budget.
      - alert: TargetDown
        expr: 100 * (count by(job, namespace, service) (up == 0) / count by(job, namespace, service) (up)) > 10
        for: 10m
        labels:
          severity: warning
        annotations:
          description: The {{ printf "%.4g" $value }}% of the {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down.
  - name: infra-alerts-05
    rules:
      - alert: Watchdog
        expr: vector(1)
        labels:
          severity: none
        annotations:
          description: This is an alert meant to ensure that the entire alerting pipeline is functional. This alert is always firing, therefore it should always be firing in Alertmanager and always fire against a receiver. There are integrations with various notification mechanisms that send a notification when this alert is not firing. For example the "DeadMansSnitch" integration in PagerDuty.
      - alert: InfoInhibitor
        expr: ALERTS{severity="info"} == 1 unless on(namespace) ALERTS{alertname!="InfoInhibitor",alertstate="firing",severity=~"warning|critical"} == 1
        labels:
          severity: none
        annotations:
          description: This is an alert that is used to inhibit info alerts. By themselves, the info-level alerts are sometimes very noisy, but they are relevant when combined with other alerts. This alert fires whenever there's a severity="info" alert, and stops firing when another alert with a severity of 'warning' or 'critical' starts firing on the same namespace. This alert should be routed to a null receiver and configured to inhibit alerts with severity="info".
      - alert: etcdInsufficientMembers
        expr: sum by(job) (up{job=~".*etcd.*"} == bool 1) < ((count by(job) (up{job=~".*etcd.*"}) + 1) / 2)
        for: 3m
        labels:
          severity: critical
        annotations:
          message: etcd cluster "{{ $labels.job }}":insufficient members ({{ $value }}).
      - alert: etcdHighNumberOfLeaderChanges
        expr: rate(etcd_server_leader_changes_seen_total{job=~".*etcd.*"}[15m]) > 3
        for: 15m
        labels:
          severity: warning
        annotations:
          message: etcd cluster "{{ $labels.job }}":instance {{ $labels.instance }} has seen {{ $value }} leader changes within the last hour.
      - alert: etcdNoLeader
        expr: etcd_server_has_leader{job=~".*etcd.*"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          message: message:etcd cluster "{{ $labels.job }}":member {{ $labels.instance }} has no leader.
      - alert: etcdHighNumberOfFailedGRPCRequests
        expr: 100 * sum by(job, instance, grpc_service, grpc_method) (rate(grpc_server_handled_total{grpc_code!="OK",job=~".*etcd.*"}[5m])) / sum by(job, instance, grpc_service, grpc_method) (rate(grpc_server_handled_total{job=~".*etcd.*"}[5m])) > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          message: etcd cluster "{{ $labels.job }}":{{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}.
      - alert: etcdGRPCRequestsSlow
        expr: histogram_quantile(0.99, sum by(job, instance, grpc_service, grpc_method, le) (rate(grpc_server_handling_seconds_bucket{grpc_type="unary",job=~".*etcd.*"}[5m]))) > 0.15
        for: 10m
        labels:
          severity: critical
        annotations:
          message: etcd cluster "{{ $labels.job }}":gRPC requests to {{ $labels.grpc_method }} are taking {{ $value }}s on etcd instance {{ $labels.instance }}.
      - alert: etcdMemberCommunicationSlow
        expr: histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.15
        for: 10m
        labels:
          severity: warning
        annotations:
          message: message:etcd cluster "{{ $labels.job }}":member communication with {{ $labels.To }} is taking {{ $value }}s on etcd instance {{ $labels.instance }}.
      - alert: etcdHighNumberOfFailedProposals
        expr: rate(etcd_server_proposals_failed_total{job=~".*etcd.*"}[15m]) > 5
        for: 15m
        labels:
          severity: warning
        annotations:
          message: etcd cluster "{{ $labels.job }}":{{ $value }} proposal failures within the last hour on etcd instance {{ $labels.instance }}.
      - alert: etcdHighFsyncDurations
        expr: histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.5
        for: 10m
        labels:
          severity: warning
        annotations:
          message: etcd cluster "{{ $labels.job }}":99th percentile fync durations are {{ $value }}s on etcd instance {{ $labels.instance }}.
      - alert: etcdHighCommitDurations
        expr: histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket{job=~".*etcd.*"}[5m])) > 0.25
        for: 10m
        labels:
          severity: warning
        annotations:
          message: etcd cluster "{{ $labels.job }}":99th percentile commit durations {{ $value }}s on etcd instance {{ $labels.instance }}.
      - alert: etcdHighNumberOfFailedHTTPRequests
        expr: sum by(method) (rate(etcd_http_failed_total{code!="404",job=~".*etcd.*"}[5m])) / sum by(method) (rate(etcd_http_received_total{job=~".*etcd.*"}[5m])) > 0.01
        for: 10m
        labels:
          severity: warning
        annotations:
          message: The {{ $value }}% of requests for {{ $labels.method }} failed on etcd instance {{ $labels.instance }}
      - alert: etcdHighNumberOfFailedHTTPRequests
        expr: sum by(method) (rate(etcd_http_failed_total{code!="404",job=~".*etcd.*"}[5m])) / sum by(method) (rate(etcd_http_received_total{job=~".*etcd.*"}[5m])) > 0.05
        for: 10m
        labels:
          severity: warning
        annotations:
          message: The {{ $value }}% of requests for {{ $labels.method }} failed on etcd instance {{ $labels.instance }}.
      - alert: etcdHTTPRequestsSlow
        expr: histogram_quantile(0.99, rate(etcd_http_successful_duration_seconds_bucket[5m])) > 0.15
        for: 10m
        labels:
          severity: warning
        annotations:
          message: etcd instance {{ $labels.instance }} HTTP requests to {{ $labels.method }} are slow.
EOF
}
