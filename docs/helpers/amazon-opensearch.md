# Creating a new Amazon OpenSearch Domain

This example creates an Amazon OpenSearch Domain within a VPC,
including an EC2 proxy instance to grant access to the domain Dashboards page
from outside of the VPC. It serves the purpose of demonstrating a minimal OpenSearch
domain that will receive observability signals using AWS Distro for FluentBit or
AWS Distro for OpenTelemetry. Mind that a production deployment of Amazon OpenSearch would
require elements that are not present in this example.

## Prerequisites

!!! note
    Make sure to complete the [prerequisites section](https://aws-observability.github.io/terraform-aws-observability-accelerator/concepts/#prerequisites) before proceeding.
    This example is designed to be deployed at the same VPC of the EKS cluster that will be observed. It expects the private and public subnets to have a `Name` tag, with any value that includes either `private` or `public`.

## Setup

### 1. Download sources and initialize Terraform

```
git clone https://github.com/aws-observability/terraform-aws-observability-accelerator.git
cd terraform-aws-observability-accelerator/examples/managed-grafana-workspace
terraform init
```

### 2. AWS Region

Specify the AWS Region where the resources will be deployed:

```bash
export TF_VAR_aws_region=xxx
```

### 3. VPC ID

Specify the id of the VPC where the resources will be deployed:

```bash
export TF_VAR_vpc_id=xxx
```

## Deploy

Simply run this command to deploy the example

```bash
terraform apply
```

## Accessing OpenSearch Dashboards

Get reverse proxy instance public DNS name:

```bash
aws ec2 describe-instances --filter Name=tag:"aws:autoscaling:groupName",Values="reverse_proxy" \
  --output json --query 'Reservations[0].Instances[0].PublicDnsName' --region <region> --no-cli-pager
```

Retrieve OpenSearch Dashboards access credentials:

```bash
# Master user name
aws ssm get-parameter --with-decryption  --output json --no-cli-pager \
  --query "Parameter.Value" --name /terraform-accelerator/opensearch/master-user-name

# Master user password
aws ssm get-parameter --with-decryption  --output json --no-cli-pager \
  --query "Parameter.Value" --name /terraform-accelerator/opensearch/master-user-password
```

Access the URL from Public DNS name and open OpenSearch Dashboards using the retrieved credentials.

## Granting access to FluentBit

To allow FluentBit to ingest logs into the Amazon OpenSearch domain, follow the instructions bellow.

Get FluentBit Role ARN:

```bash
SA=$(
  kubectl -n aws-for-fluent-bit get daemonset aws-for-fluent-bit -o json |
    jq -r .spec.template.spec.serviceAccount)
kubectl -n aws-for-fluent-bit get sa $SA -o json |
  jq -r .metadata.annotations.'"eks.amazonaws.com/role-arn"'
```

Add FluentBut Role ARN as a backend role in OpenSearch:

1. Access OpenSearch Dashboards. In the left menu, select **Security**.
2. In Security, select **Roles**.
3. In Roles, select **all access**.
4. In All access, select the tab **Mapped Users**, and them **Manage mapping**.
5. In Backend roles, click in **Add another backend role**. In the empty field, enter the FluentBit Role ARN retrieved before.

## Granting access to Amazon Managed Grafana

To allow Amazon Managed Grafana to access Amazon OpenSearch domain datasource, follow the instructions bellow.

1. Connect the workspace to the VPC following [these instructions](https://docs.aws.amazon.com/grafana/latest/userguide/AMG-configure-vpc.html).
2. Add access to OpenSearch datasources by following [these instructions](https://docs.aws.amazon.com/grafana/latest/userguide/ES-adding-AWS-config.html).
3. Include the policy for listing OpenSearch collections:
  ```bash
  GRAFANA_WORKSPACE_ID=<grafana workspace id>
  GRAFANA_ROLE_ARN=$(
    aws grafana describe-workspace --workspace-id $GRAFANA_WORKSPACE_ID \
      --output json --no-cli-pager | jq -r .workspace.workspaceRoleArn)
  GRAFANA_ROLE=$(echo $GRAFANA_ROLE_ARN | cut -d/ -f3)
  cat <<EOF > policy.json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "aoss:ListCollections"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF

  aws iam put-role-policy --role-name $GRAFANA_ROLE \
    --policy-name OpenSearchCollections --policy-document file://policy.json
  ```

4. Enable the OpenSearch plugin by following [these instructions](https://docs.aws.amazon.com/grafana/latest/userguide/aws-datasources-plugin.html).
5. Access OpenSearch Dashboards. In the left menu, select **Security**.
6. In Security, select **Roles**.
7. In Roles, select **all access**.
8. In All access, select the tab **Mapped Users**, and them **Manage mapping**.
9. In Backend roles, click in **Add another backend role**. In the empty field, enter the Grafana Role ARN retrieved before.

## Cleanup

To clean up your environment, destroy the Terraform example by running

```sh
terraform destroy
```
