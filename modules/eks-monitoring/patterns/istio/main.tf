resource "aws_prometheus_rule_group_namespace" "recording_rules" {
  count = var.pattern_config.enable_recording_rules ? 1 : 0

  name         = "accelerator-istio-rules"
  workspace_id = var.pattern_config.managed_prometheus_workspace_id
  data         = <<EOF
 groups:
  - name: "istio.recording-rules"
    interval: 5s
    rules:
    - record: "workload:istio_requests_total"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_requests_total)

    - record: "workload:istio_request_duration_milliseconds_count"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_duration_milliseconds_count)

    - record: "workload:istio_request_duration_milliseconds_sum"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_duration_milliseconds_sum)

    - record: "workload:istio_request_duration_milliseconds_bucket"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_duration_milliseconds_bucket)

    - record: "workload:istio_request_bytes_count"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_bytes_count)

    - record: "workload:istio_request_bytes_sum"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_bytes_sum)

    - record: "workload:istio_request_bytes_bucket"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_request_bytes_bucket)

    - record: "workload:istio_response_bytes_count"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_response_bytes_count)

    - record: "workload:istio_response_bytes_sum"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_response_bytes_sum)

    - record: "workload:istio_response_bytes_bucket"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_response_bytes_bucket)

    - record: "workload:istio_tcp_sent_bytes_total"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_tcp_sent_bytes_total)

    - record: "workload:istio_tcp_received_bytes_total"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_tcp_received_bytes_total)

    - record: "workload:istio_tcp_connections_opened_total"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_tcp_connections_opened_total)

    - record: "workload:istio_tcp_connections_closed_total"
      expr: |
        sum without(instance, kubernetes_namespace, kubernetes_pod_name) (istio_tcp_connections_closed_total)
EOF
}

resource "aws_prometheus_rule_group_namespace" "alerting_rules" {
  count = var.pattern_config.enable_alerting_rules ? 1 : 0

  name         = "accelerator-istio-alerting"
  workspace_id = var.pattern_config.managed_prometheus_workspace_id
  data         = <<EOF
  groups:
    - name: "istio.basic.alerting-rules"
      rules:
        - alert: IngressTrafficMissing
          annotations:
            summary: 'ingress gateway traffic missing'
            description: '[Critical]: ingress gateway traffic missing, likely other monitors are misleading, check client logs'
          expr: >
              absent(istio_requests_total{destination_service_namespace=~"service-graph.*",reporter="source",source_workload="istio-ingressgateway"})==1
          for: 5m
        - alert: IstioMetricsMissing
          annotations:
            summary: 'Istio Metrics missing'
            description: '[Critical]: Check prometheus deployment or whether the prometheus filters are applied correctly'
          expr: >
            absent(istio_request_total)==1 or absent(istio_request_duration_milliseconds_bucket)==1
          for: 5m
    - name: "istio.workload.alerting-rules"
      rules:
        - alert: HTTP5xxRateHigh
          annotations:
            summary: '5xx rate too high'
            description: 'The HTTP 5xx errors rate higher than 0.05 in 5 mins'
          expr: >
            sum(irate(istio_requests_total{reporter="destination", response_code=~"5.*"}[5m])) / sum(irate(istio_requests_total{reporter="destination"}[5m])) > 0.05
          for: 5m
        - alert: WorkloadLatencyP99High
          expr: histogram_quantile(0.99, sum(irate(istio_request_duration_milliseconds_bucket{source_workload=~"svc.*"}[5m])) by (source_workload,namespace, le)) > 160
          for: 10m
          annotations:
            description: 'The workload request latency P99 > 160ms '
            message:  "Request duration has slowed down for workload: {{`{{$labels.source_workload}}`}} in namespace: {{`{{$labels.namespace}}`}}. Response duration is {{`{{$value}}`}} milliseconds"
        - alert: IngressLatencyP99High
          expr: histogram_quantile(0.99, sum(irate(istio_request_duration_milliseconds_bucket{source_workload=~"istio.*"}[5m])) by (source_workload,namespace, le)) > 250
          for: 10m
          annotations:
            description: 'The ingress latency P99 > 250ms '
            message:  "Request duration has slowed down for ingress: {{`{{$labels.source_workload}}`}} in namespace: {{`{{$labels.namespace}}`}}. Response duration is {{`{{$value}}`}} milliseconds"
    - name: "istio.infra.alerting-rules"
      rules:
        - alert: ProxyContainerCPUUsageHigh
          expr: (sum(rate(container_cpu_usage_seconds_total{namespace!="kube-system", container=~"istio-proxy", namespace!=""}[5m])) BY (namespace, pod, container) * 100) > 80
          for: 5m
          annotations:
            summary: "Proxy Container CPU usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }})  VALUE = {{ $value }}\n"
            description: "Proxy Container CPU usage is above 80%"
        - alert: ProxyContainerMemoryUsageHigh
          expr: (sum(container_memory_working_set_bytes{namespace!="kube-system", container=~"istio-proxy", namespace!=""}) BY (container, pod, namespace)  / (sum(container_spec_memory_limit_bytes{namespace!="kube-system", container!="POD"}) BY (container, pod, namespace) > 0)* 100) > 80
          for: 5m
          annotations:
            summary: "Proxy Container Memory usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }})  VALUE = {{ $value }}\n"
            description: "Proxy Container Memory usage is above 80%"
        - alert: IngressMemoryUsageIncreaseRateHigh
          expr: avg(deriv(container_memory_working_set_bytes{container=~"istio-proxy",namespace="istio-system"}[60m])) > 200
          for: 180m
          annotations:
            summary: "Ingress proxy Memory change rate, VALUE = {{ $value }}\n"
            description: "Ingress proxy Memory Usage increases more than 200 Bytes/sec"
        - alert: IstiodContainerCPUUsageHigh
          expr: (sum(rate(container_cpu_usage_seconds_total{namespace="istio-system", container="discovery"}[5m])) BY (pod) * 100) > 80
          for: 5m
          annotations:
            summary: "Istiod Container CPU usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }}) VALUE = {{ $value }}\n"
            description: "Isitod Container CPU usage is above 80%"
        - alert: IstiodMemoryUsageHigh
          expr: (sum(container_memory_working_set_bytes{namespace="istio-system", container="discovery"}) BY (pod)  / (sum(container_spec_memory_limit_bytes{namespace="istio-system", container="discovery"}) BY (pod) > 0)* 100) > 80
          for: 5m
          annotations:
            summary: "Istiod Container Memory usage (namespace {{ $labels.namespace }}) (pod {{ $labels.pod }}) (container {{ $labels.container }}) VALUE = {{ $value }}\n"
            description: "Istiod Container Memory usage is above 80%"
        - alert: IstiodMemoryUsageIncreaseRateHigh
          expr: sum(deriv(container_memory_working_set_bytes{namespace="istio-system",pod=~"istiod-.*"}[60m])) > 1000
          for: 300m
          annotations:
            summary: "Istiod Container Memory usage increase rate high, VALUE = {{ $value }}\n"
            description: "Istiod Container Memory usage increases more than 1k Bytes/sec"
    - name: "istio.controlplane.alerting-rules"
      rules:
        - alert: IstiodxdsPushErrorsHigh
          annotations:
            summary: 'istiod push errors is too high'
            description: 'istiod push error rate is higher than 0.05'
          expr: >
            sum(irate(pilot_xds_push_errors{app="istiod"}[5m])) / sum(irate(pilot_xds_pushes{app="istiod"}[5m])) > 0.05
          for: 5m
        - alert: IstiodxdsRejectHigh
          annotations:
            summary: 'istiod rejects rate is too high'
            description: 'istiod rejects rate is higher than 0.05'
          expr: >
            sum(irate(pilot_total_xds_rejects{app="istiod"}[5m])) / sum(irate(pilot_xds_pushes{app="istiod"}[5m])) > 0.05
          for: 5m
        - alert: IstiodContainerNotReady
          annotations:
            summary: 'istiod container not ready'
            description: 'container: discovery not running'
          expr: >
            kube_pod_container_status_running{namespace="istio-system", container="discovery", component=""} == 0
          for: 5m
        - alert: IstiodUnavailableReplica
          annotations:
            summary: 'Istiod unavailable pod'
            description: 'Istiod unavailable replica > 0'
          expr: >
            kube_deployment_status_replicas_unavailable{deployment="istiod", component=""} > 0
          for: 5m
        - alert: Ingress200RateLow
          annotations:
            summary: 'ingress gateway 200 rate drops'
            description: 'The expected rate is 100 per ns, the limit is set based on 15ns'
          expr: >
            sum(rate(istio_requests_total{reporter="source", source_workload="istio-ingressgateway",response_code="200",destination_service_namespace=~"service-graph.*"}[5m])) < 1490
          for: 30m
    EOF
}

resource "kubectl_manifest" "flux_kustomization" {
  count = var.pattern_config.enable_dashboards ? 1 : 0

  yaml_body = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: ${var.pattern_config.flux_kustomization_name}
  namespace: flux-system
spec:
  interval: 1m0s
  path: ${var.pattern_config.flux_kustomization_path}
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${var.pattern_config.flux_gitrepository_name}
  postBuild:
    substitute:
      GRAFANA_ISTIO_CP_DASH_URL: ${var.pattern_config.dashboards.cp}
      GRAFANA_ISTIO_MESH_DASH_URL: ${var.pattern_config.dashboards.mesh}
      GRAFANA_ISTIO_PERF_DASH_URL: ${var.pattern_config.dashboards.performance}
      GRAFANA_ISTIO_SERVICE_DASH_URL: ${var.pattern_config.dashboards.service}
YAML
}
