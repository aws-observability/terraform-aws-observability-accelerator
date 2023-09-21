# Troubleshooting guide for Amazon EKS monitoring module

Depending on your setup, you might face a few errors. If you encounter an error
not listed here, please open an issue in the [issues section](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues)

These guide applies to the [eks-monitoring Terraform module](https://github.com/aws-observability/terraform-aws-observability-accelerator/tree/main/modules/eks-monitoring)


## Cluster authentication issue

### Error message

```console
╷
│ Error: cluster-secretstore-sm failed to create kubernetes rest client for update of resource: Get "https://FINGERPRINT.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": dial tcp: lookup F867DE6CE883F9595FC8A73D84FB9F83.gr7.us-east-1.eks.amazonaws.com on 192.168.4.1:53: no such host
│
│   with module.eks_monitoring.module.external_secrets[0].kubectl_manifest.cluster_secretstore,
│   on ../../modules/eks-monitoring/add-ons/external-secrets/main.tf line 59, in resource "kubectl_manifest" "cluster_secretstore":
│   59: resource "kubectl_manifest" "cluster_secretstore" {
│
╵
╷
│ Error: grafana-operator/external-secrets-sm failed to create kubernetes rest client for update of resource: Get "https://FINGERPRINT.gr7.us-east-1.eks.amazonaws.com/api?timeout=32s": dial tcp: lookup F867DE6CE883F9595FC8A73D84FB9F83.gr7.us-east-1.eks.amazonaws.com on 192.168.4.1:53: no such host
│
│   with module.eks_monitoring.module.external_secrets[0].kubectl_manifest.secret,
│   on ../../modules/eks-monitoring/add-ons/external-secrets/main.tf line 89, in resource "kubectl_manifest" "secret":
│   89: resource "kubectl_manifest" "secret" {
```

### Resolution


To provision the `eks-monitoring` module, the environment where you are running
Terraform apply needs to be authenticated against your cluster and be your
current context. To verify, you can run a single `kubectl get nodes` command
to ensure you are using the correct Amazon EKS cluster.

To login agains the correct cluster, run:

```console
aws eks update-kubeconfig --name <cluster name> --region <aws region>
```

## Missing Grafana dashboards

Terraform apply can run without apparent errors and your Grafana workspace
won't present any dashboards. Many situations could lead to this as described
below. The best place to start would be checking the logs of `grafana-operator`,
`external-secrets` and `flux-system` pods.


### Wrong Grafana workspace

It might happen that you provide the wrong Grafana workspace. One way to verify
this is to run the following command:

```bash
kubectl describe grafanas external-grafana -n grafana-operator
```

You should see an output similar to this (truncated for brevity). Validate that
you have the correct URL. If that's the case, re-running Terraform with the
correct workspace ID, API key should fix this issue.

```console
...
Spec:
  External:
    API Key:
      Key:   GF_SECURITY_ADMIN_APIKEY
      Name:  grafana-admin-credentials
    URL:     https://g-workspaceid.grafana-workspace.eu-central-1.amazonaws.com
Status:
  Admin URL:  https://g-workspaceid.grafana-workspace.eu-central-1.amazonaws.com
  Dashboards:
    grafana-operator/apiserver-troubleshooting-grafanadashboard/V3y_Zcb7k
    grafana-operator/apiserver-basic-grafanadashboard/R6abPf9Zz
    grafana-operator/java-grafanadashboard/m9mHfAy7ks
    grafana-operator/grafana-dashboards-adothealth/reshmanat
    grafana-operator/apiserver-advanced-grafanadashboard/09ec8aa1e996d6ffcd6817bbaff4db1b
    grafana-operator/nginx-grafanadashboard/nginx
    grafana-operator/kubelet-grafanadashboard/3138fa155d5915769fbded898ac09fd9
    grafana-operator/cluster-grafanadashboard/efa86fd1d0c121a26444b636a3f509a8
    grafana-operator/workloads-grafanadashboard/a164a7f0339f99e89cea5cb47e9be617
    grafana-operator/grafana-dashboards-kubeproxy/632e265de029684c40b21cb76bca4f94
    grafana-operator/nodes-grafanadashboard/200ac8fdbfbb74b39aff88118e4d1c2c
    grafana-operator/node-exporter-grafanadashboard/v8yDYJqnz
    grafana-operator/namespace-workloads-grafanadashboard/a87fb0d919ec0ea5f6543124e16c42a5
```


### Grafana API key expired

Check on the logs on your grafana operator pod using the below command :

```bash
kubectl get pods -n grafana-operator
```

Output:

```console
NAME                                READY   STATUS    RESTARTS   AGE
grafana-operator-866d4446bb-nqq5c   1/1     Running   0          3h17m
```

```bash
kubectl logs grafana-operator-866d4446bb-nqq5c -n grafana-operator
```

Output:

```console
1.6857285045556655e+09	ERROR	error reconciling datasource	{"controller": "grafanadatasource", "controllerGroup": "grafana.integreatly.org", "controllerKind": "GrafanaDatasource", "GrafanaDatasource": {"name":"grafanadatasource-sample-amp","namespace":"grafana-operator"}, "namespace": "grafana-operator", "name": "grafanadatasource-sample-amp", "reconcileID": "72cfd60c-a255-44a1-bfbd-88b0cbc4f90c", "datasource": "grafanadatasource-sample-amp", "grafana": "external-grafana", "error": "status: 401, body: {\"message\":\"Expired API key\"}\n"}
github.com/grafana-operator/grafana-operator/controllers.(*GrafanaDatasourceReconciler).Reconcile
```

If you observe, the the above `grafana-api-key error` in the logs,
your grafana API key is expired.

Please use the operational procedure to update your `grafana-api-key` :

- Create a new Grafana API key, you can use [this step](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/#6-grafana-api-key)
and make sure the API key duration is not too short.

- Run Terraform with the new API key. Terraform will modify the AWS SSM
Parameter used by `externalsecret`.

- If the issue persists, you can force the synchronization by deleting the
`externalsecret` Kubernetes object.

```bash
kubectl delete externalsecret/external-secrets-sm -n grafana-operator
```

### Git repository errors

[Flux](https://fluxcd.io/flux/components/source/gitrepositories/) is responsible
to regularly pull and synchronize [dashboards and artifacts](https://github.com/aws-observability/aws-observability-accelerator)
into your EKS cluster. It might happen that its state gets corrupted.

You can verify those errors by using this command. You should see an error if
Flux is not able to pull correctly:

```bash
kubectl get gitrepositories -n flux-system
NAME                            URL                                                                  AGE     READY   STATUS
aws-observability-accelerator   https://github.com/aws-observability/aws-observability-accelerator   6d12h   True    stored artifact for revision 'v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d'
```

Depending on the error, you can delete the repository and re-run Terraform and
force the synchronization.

```bash
k delete gitrepositories aws-observability-accelerator  -n flux-system
```

If you believe this is a bug, please open an issue [here](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues).


### Flux Kustomizations

After Flux pulls the repository in the cluster state, it will apply [Kustomizations](https://fluxcd.io/flux/components/kustomize/kustomizations/)
to create Grafana data sources, folders and dashboards.

- Check the kustomization objects. Here you should see the dashboards you have
enabled

```bash
k get kustomizations.kustomize.toolkit.fluxcd.io -A
NAMESPACE     NAME                                AGE   READY   STATUS
flux-system   grafana-dashboards-adothealth       18d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
flux-system   grafana-dashboards-apiserver        18d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
flux-system   grafana-dashboards-infrastructure   10d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
flux-system   grafana-dashboards-java             18d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
flux-system   grafana-dashboards-kubeproxy        10d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
flux-system   grafana-dashboards-nginx            18d   True    Applied revision: v0.2.0@sha1:c4819a990312f7c2597f529577471320e5c4ef7d
```

- To have more infos on an error, you can view the Kustomization controller logs

```bash
kubectl get pods -n flux-system
NAME                                          READY   STATUS    RESTARTS      AGE
helm-controller-65cc46469f-nsqd5              1/1     Running   2 (13d ago)   27d
image-automation-controller-d8f7bfcb4-k2m9j   1/1     Running   2 (13d ago)   27d
image-reflector-controller-68979dfd49-wh25h   1/1     Running   2 (13d ago)   27d
kustomize-controller-767677f7f5-c5xsp         1/1     Running   5 (13d ago)   63d
notification-controller-55d8c759f5-7df5l      1/1     Running   5 (13d ago)   63d
source-controller-58c66d55cd-4j6bl            1/1     Running   5 (13d ago)   63d
```

```bash
kubectl logs -f -n flux-system kustomize-controller-767677f7f5-c5xsp
```

If you believe there is a bug, please open an issue [here](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues).

- Depending on the error, delete the kustomization object and re-apply Terraform

```bash
kubectl delete kustomizations -n flux-system grafana-dashboards-apiserver
```

### Grafana dashboards errors

If all of the above seem normal, finally inspect deployed dashboards by
running this command:

```bash
kubectl get grafanadashboards -A
NAMESPACE          NAME                                         AGE
grafana-operator   apiserver-advanced-grafanadashboard          18d
grafana-operator   apiserver-basic-grafanadashboard             18d
grafana-operator   apiserver-troubleshooting-grafanadashboard   18d
grafana-operator   cluster-grafanadashboard                     10d
grafana-operator   grafana-dashboards-adothealth                18d
grafana-operator   grafana-dashboards-kubeproxy                 10d
grafana-operator   java-grafanadashboard                        18d
grafana-operator   kubelet-grafanadashboard                     10d
grafana-operator   namespace-workloads-grafanadashboard         10d
grafana-operator   nginx-grafanadashboard                       18d
grafana-operator   node-exporter-grafanadashboard               10d
grafana-operator   nodes-grafanadashboard                       10d
grafana-operator   workloads-grafanadashboard                   10d
```

- You can dive into the details of a dashboard by running:

```bash
kubectl describe grafanadashboards grafana-dashboards-kubeproxy -n grafana-operator
```

- Depending on the error, you can delete the dashboard object. In this case,
you don't need to re-run Terraform as the Flux Kustomization will force its
recreation through the Grafana operator

```bash
kubectl describe grafanadashboards grafana-dashboards-kubeproxy -n grafana-operator
```

If you believe there is a bug, please open an issue [here](https://github.com/aws-observability/terraform-aws-observability-accelerator/issues).

## Upgrade from to v2.5 or earlier

v2.5.0 removes the dependency to the Terraform Grafana provider in the EKS
monitoring module. As Grafana Operator manages and syncs the Grafana contents,
Terraform is not required anymore in this context.

However, if you migrate from earlier versions, you might leave some data
orphan as the Grafana provider is dropped.
Terraform will throw an error. We have released v2.5.0-rc.1 which removes all
the Grafana resources provisioned by Terraform in the EKS context,
without removing the provider configurations.

- Step 1: migrate to v2.5.0-rc.1 and run apply
- Step 2: migrate to v2.5.0 or above
