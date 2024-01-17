# Monitoring NVIDIA GPU Workloads

GPUs play an integral part in data intensive workloads. The base infrastructure module of the Observability Accelerator proivdes the ability to deploy the NVIDIA DCGM Exporter Dashboard
The dashboard utilizes metrics scraped from the '/metrics' endpoint that are exposed when running the nvidia gpu operator.

!!!note
    In order to make use of this dashboard, you will need to have a GPU backed EKS cluster and deploy the [GPU operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/amazon-eks.html)
    The recommended way of deploying the GPU operator is the [Data on EKS Blueprint](https://github.com/aws-ia/terraform-aws-eks-data-addons/blob/main/nvidia-gpu-operator.tf)

## Deployment

This is enabled by default in the [base infrasturcture module](https://aws-observability.github.io/terraform-aws-observability-accelerator/eks/).


