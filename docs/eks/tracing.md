# Tracing on Amazon EKS

[Distributed tracing](https://aws-observability.github.io/observability-best-practices/signals/traces/)
helps you have end-to-end visibility between transactions in distributed nodes.
The `eks-monitoring` module is configured  by default to collect traces into
[AWS X-Ray](https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html).

The AWS Distro for OpenTelemetry collector is configured to receive traces
in the OTLP format (OTLP receiver), using the OpenTelemetry SDK or
auto-instrumentation agents.

!!! note
    To disable the tracing configuration, set up `enable_tracing = false` in
    the [module configuration](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring#input_enable_tracing)


## Instrumentation

Let's take a [sample application](https://github.com/aws-observability/aws-otel-community/tree/master/sample-apps/go-sample-app)
that is already instrumented with the OpenTelemetry SDK.

!!! note
    To learn more about instrumenting with OpenTelemetry, please visit the
    [OpenTelemetry documentation](https://opentelemetry.io/docs/instrumentation/)
    for your programming language.

Cloning the repo

```console
git clone https://github.com/aws-observability/aws-otel-community.git
cd aws-otel-community/sample-apps/go-sample-app
```

## Deploying on Amazon EKS

Using the sample application, we will build a container image, create and push
an image on Amazon ECR. We will use a Kubernetes manifest to deploy to an EKS
cluster.

!!! warning
    The following steps require that you have an EKS cluster ready. To deploy
    an EKS cluster, please visit [our example](https://aws-observability.github.io/terraform-aws-observability-accelerator/helpers/new-eks-cluster/).

### Building container image


=== "amd64 linux"

    ```console
    docker build -t go-sample-app .
    ```

=== "cross platform build"

    ```bash
    docker buildx build -t go-sample-app . --platform=linux/amd64
    ```

### Publishing on Amazon ECR


=== "using docker"

    ```console
    export ECR_REPOSITORY_URI=$(aws ecr create-repository --repository go-sample-app --query repository.repositoryUri --output text)
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI
    docker tag go-sample-app:latest "${ECR_REPOSITORY_URI}:latest"
    docker push "${ECR_REPOSITORY_URI}:latest"
    ```


## Deploying on Amazon EKS


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
          image: "${ECR_REPOSITORY_URI}:latest" # make sure to replace this variable
          imagePullPolicy: Always
          env:
          - name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
            value: adot-collector.adot-collector-kubeprometheus.svc.cluster.local:4317
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
  labels:
    app: go-sample-app
spec:
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  selector:
    app: go-sample-app
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

### Deploying and testing

With the Kubernetes manifest ready, run:

```bash
kubectl apply -f eks.yaml
```

You should see the pods running with the command:

```console
kubectl get pods
NAME                              READY   STATUS    RESTARTS        AGE
go-sample-app-67c48ff8c6-bdw74    1/1     Running   0               4s
go-sample-app-67c48ff8c6-t6k2j    1/1     Running   0               4s
```

To simulate some traffic you can forward the service port to your local host
and test a few queries

```console
kubectl port-forward deployment/go-sample-app 8080:8080
```

Test a few endpoints

```
curl http://localhost:8080/
curl http://localhost:8080/outgoing-http-call
curl http://localhost:8080/aws-sdk-call
curl http://localhost:8080/outgoing-sampleapp
```

## Visualizing traces

As this is a basic example, the service map doesn't have a lot of nodes,
but this shows you how to setup tracing in your application and deploying
it on Amazon EKS using the `eks-monitoring` module.

With Flux and Grafana Operator, the `eks-monitoring` module configures
an AWS X-Ray data source on your provided Grafana workspace. Open the
Grafana explorer view and select the X-Ray data source. If you type the query
below, and select `Trace List` for **Query Type**, you should see the list
of traces occured in the selected timeframe.

<img width="1721" alt="Screenshot 2023-07-20 at 21 42 30" src="https://github.com/aws-observability/terraform-aws-observability-accelerator/assets/10175027/bd992a77-05fb-47d2-8ed4-af05d96e951d">

You can add the service map to a dashboard, for example a service focused
dashboard. You can click on any of the traces to view a node map and the traces
details.

There is a button that can take you the CloudWatch console to view the same
data. If your logs are stored on CloudWatch Logs, this page can present
all the logs in the trace details page. The CloudWatch Log Group name should
be added to the trace as an attribute.
Read more about this in our [One Observability Workshop](https://catalog.workshops.aws/observability/en-US/use-cases/trace-to-logs-java-instrumentation/concepts)

![CloudWatch service map](https://user-images.githubusercontent.com/10175027/254973349-1028f428-c2ef-4bd2-8114-0d0961d7cdd8.png)


## Resoures

- [AWS Observability Best Practices](https://aws-observability.github.io/observability-best-practices/)
- [One Observability Workshop](https://catalog.workshops.aws/observability/en-US/)
- [AWS Distro for OpenTelemetry documentation](https://aws-otel.github.io/docs/introduction)
- [AWS X-Ray user guide](https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html)
- [OpenTelemetry documentation](https://opentelemetry.io/docs/what-is-opentelemetry/)
