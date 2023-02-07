## Create a new eks cluster with vpc using the accelerator 'eks-cluster-with-vpc' example.

We want a nice clean cluster to work from.

## Once the cluster has been created, run the 'existing cluster base and infra' example in the accelerator. Create everything new, do not reuse anything pre-existing.

At this point you should have

1. An EKS Cluster
2. A managed prometheus workspace
3. A managed grafana workspace

## The next thing we will do is run the prometheus server helm deployment instructions.

1. Add new helm chart repos for prometheus

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update
```

2. Create a prometheus namespace in your kubernetes cluster.

```
kubectl create namespace charlie-prometheus
```

3. Set up new prometheus configuration

Create a yaml file names 'config.yaml' . It should contain the following.

```
global:
  scrape_interval: 30s

scrape_configs:
- job_name: ingress
  honor_timestamps: true
  scrape_interval: 1m
  scrape_timeout: 1m
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - ingress-prometheus.default.svc.cluster.local:80
server:
  remoteWrite:
    - url: $AMP_REMOTE_WRITE_ENDPOINT
      sigv4:
        region: $REGION
      queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500
```

4. Deploy prometheus server using config

```
helm install prometheus-nginx prometheus-community/prometheus -n charlie-prometheus \
-f config.yaml
```

5. Install Nginx-Ingress Controller

```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install controller  nginx-stable/nginx-ingress --set prometheus.create=true --set prometheus.port=9901
```

6. Create a kubernetes service that listens on the port for the nginx metrics.

Make a file called service-monitor.yaml In the file put the following yaml

```
apiVersion: v1
kind: Service
metadata:
  name: ingress-prometheus
  namespace: service-monitor
spec:
  ports:
  - name: ingress-prometheus
    port: 80
    protocol: TCP
    targetPort: 9901
  selector:
    app: controller-nginx-ingress
  type: ClusterIP
```

```
kubectl apply -f service-monitor.yaml
```

7. Go to grafana and hit 'explore' on the left hand side. Go to the accelerator AMP datasource and browse for metrics. Hopefully you should now see nginx metrics although they might be 0 because we have not thrown any traffic at the nginx controller.




