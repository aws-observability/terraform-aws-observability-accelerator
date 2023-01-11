#!/bin/sh

sudo yum -y update

sudo yum -y install jq

# Update to AWS ClI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

wget https://aws-otel-collector.s3.amazonaws.com/amazon_linux/amd64/latest/aws-otel-collector.rpm

sudo rpm -Uvh  ./aws-otel-collector.rpm

export AWS_REGION=us-east-2
export AMP_WORKSPACES_JSON=`aws amp list-workspaces`
export AMP_WORKSPACE_ID=`jq -r '.workspaces[0].workspaceId' <<< $AMP_WORKSPACES_JSON`

aws amp describe-workspace --workspace-id=$AMP_WORKSPACE_ID

export AMP_WORKSPACE_JSON=`aws amp describe-workspace --workspace-id $AMP_WORKSPACE_ID`
export PROM_ENDPOINT=`jq -r '.workspace.prometheusEndpoint' <<< $AMP_WORKSPACE_JSON`
export PROM_ENDPOINT_WRITE=$PROM_ENDPOINT'api/v1/remote_write'
export PROM_ENDPOINT_QUERY=$PROM_ENDPOINT'api/v1/query'


printf \
"extensions:
  sigv4auth:
    region: \"$AWS_REGION\"
    service: \"aps\"
receivers:
  prometheus:
    config:
      scrape_configs:
      - job_name: otel-collector-metrics
        scrape_interval: 60s
        static_configs:
        - targets: ['localhost:9100']
exporters:
  prometheusremotewrite:
    endpoint: \"$PROM_ENDPOINT_WRITE\"
    auth:
      authenticator: sigv4auth
    retry_on_failure:
      enabled: true
      initial_interval: 1s
      max_interval: 10s
      max_elapsed_time: 30s
service:
  extensions: [sigv4auth]
  pipelines:
    metrics:
      receivers: [prometheus]
      exporters: [prometheusremotewrite]" \
> ./config.yaml

sudo mv /opt/aws/aws-otel-collector/etc/config.yaml /opt/aws/aws-otel-collector/etc/config.yaml.orig

sudo mv ./config.yaml /opt/aws/aws-otel-collector/etc/config.yaml

sudo cat /opt/aws/aws-otel-collector/etc/config.yaml

sudo /opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a stop
sudo /opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a start
sudo /opt/aws/aws-otel-collector/bin/aws-otel-collector-ctl -a status

pip3 install awscurl 