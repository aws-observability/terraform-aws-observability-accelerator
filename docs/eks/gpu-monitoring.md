# Monitoring NVIDIA GPU Workloads

GPUs play an integral part in data intensive workloads. The eks-monitoring module of the Observability Accelerator provides the ability to deploy the NVIDIA DCGM Exporter Dashboard.
The dashboard utilizes metrics scraped from the `/metrics` endpoint that are exposed when running the nvidia gpu operator with the [DCGM exporter](https://developer.nvidia.com/blog/monitoring-gpus-in-kubernetes-with-dcgm/) and NVSMI binary.

!!!note
    In order to make use of this dashboard, you will need to have a GPU backed EKS cluster and deploy the [GPU operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/amazon-eks.html)
    The recommended way of deploying the GPU operator is the [Data on EKS Blueprint](https://github.com/aws-ia/terraform-aws-eks-data-addons/blob/main/nvidia-gpu-operator.tf)

## Deployment

This is enabled by default in the [eks-monitoring module](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/).

## Dashboards

In order to start producing diagnostic metrics you must first deploy the nvidia SMI binary. nvidia-smi (also NVSMI) provides monitoring and management capabilities for each of NVIDIA’s devices from Fermi and higher architecture families. We can now deploy the nvidia-smi binary, which shows diagnostic information about all GPUs visible to the container:

```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nvidia-smi
spec:
  restartPolicy: OnFailure
  containers:
  - name: nvidia-smi
    image: "nvidia/cuda:11.0.3-base-ubuntu20.04"
    args:
    - "nvidia-smi"
    resources:
      limits:
        nvidia.com/gpu: 1
EOF
```
After producing the metrics they should populate the DCGM exporter dashboard:

![image](https://github.com/aws-observability/terraform-aws-observability-accelerator/assets/97046295/66e8ae83-3a78-48b8-a9fc-4460a5a4d173)
