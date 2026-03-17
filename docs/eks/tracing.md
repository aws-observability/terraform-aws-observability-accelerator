# Tracing on Amazon EKS

[Distributed tracing](https://aws-observability.github.io/observability-best-practices/signals/traces/)
helps you have end-to-end visibility between transactions in distributed nodes.

## How tracing works in v3

The `eks-monitoring` module configures traces collection depending on the
collector profile:

| Profile | Traces support | Exporter |
|---------|---------------|----------|
| `self-managed-amp` | Yes (toggle with `enable_tracing`) | OTLP → AWS X-Ray |
| `cloudwatch-otlp` | Yes (always enabled) | OTLP → AWS X-Ray |
| `managed-metrics` | No (metrics only) | — |

The OpenTelemetry Collector receives traces via the OTLP protocol (gRPC on
port 4317, HTTP on port 4318) and exports them to AWS X-Ray.

!!! note
    To disable tracing in the `self-managed-amp` profile, set
    `enable_tracing = false` in the
    [module configuration](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring#input_enable_tracing).

## Instrumentation

Applications send traces to the OTel Collector using the OpenTelemetry SDK.
Point your application's OTLP exporter at the collector service:

```yaml
env:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: "http://otel-collector.otel-collector.svc.cluster.local:4317"
```

!!! note
    To learn more about instrumenting with OpenTelemetry, visit the
    [OpenTelemetry documentation](https://opentelemetry.io/docs/instrumentation/)
    for your programming language.

## Example: Go sample application

Let's use a [sample application](https://github.com/aws-observability/aws-otel-community/tree/master/sample-apps/go-sample-app)
that is already instrumented with the OpenTelemetry SDK.

```bash
git clone https://github.com/aws-observability/aws-otel-community.git
cd aws-otel-community/sample-apps/go-sample-app
```

### Building and publishing the container image

=== "amd64 linux"

    ```bash
    docker build -t go-sample-app .
    ```

=== "cross platform build"

    ```bash
    docker buildx build -t go-sample-app . --platform=linux/amd64
    ```

Publish to Amazon ECR:

```bash
export ECR_REPOSITORY_URI=$(aws ecr create-repository --repository go-sample-app --query repository.repositoryUri --output text)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI
docker tag go-sample-app:latest "${ECR_REPOSITORY_URI}:latest"
docker push "${ECR_REPOSITORY_URI}:latest"
```

### Deploying on Amazon EKS

```yaml title="eks.yaml" linenums="1"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-sample-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: go-sample-app
  template:
    metadata:
      labels:
        app: go-sample-app
    spec:
      containers:
        - name: go-sample-app
          image: "${ECR_REPOSITORY_URI}:latest" # replace with your ECR URI
          imagePullPolicy: Always
          env:
          - name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
            value: otel-collector.otel-collector.svc.cluster.local:4317
          resources:
            limits:
              cpu:  300m
              memory: 300Mi
            requests:
              cpu: 100m
              memory: 180Mi
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: go-sample-app
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: go-sample-app
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
```

Deploy and test:

```bash
kubectl apply -f eks.yaml
kubectl port-forward deployment/go-sample-app 8080:8080
```

```bash
curl http://localhost:8080/
curl http://localhost:8080/outgoing-http-call
curl http://localhost:8080/aws-sdk-call
```

## Visualizing traces

Open your Amazon Managed Grafana workspace and add the AWS X-Ray data source.
In the Grafana Explorer view, select the X-Ray data source and use **Query
Type: Trace List** to browse traces.

You can also view traces in the
[CloudWatch console](https://docs.aws.amazon.com/xray/latest/devguide/xray-console.html),
which provides a service map and trace detail views. If your logs are stored in
CloudWatch Logs, the trace detail page can correlate logs automatically.

## Resources

- [AWS Observability Best Practices](https://aws-observability.github.io/observability-best-practices/)
- [One Observability Workshop](https://catalog.workshops.aws/observability/en-US/)
- [AWS X-Ray user guide](https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html)
- [OpenTelemetry documentation](https://opentelemetry.io/docs/what-is-opentelemetry/)
