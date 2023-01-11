#!/bin/sh

sudo useradd --no-create-home node_exporter

wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz

tar xzf node_exporter-1.4.0.linux-amd64.tar.gz
sudo cp node_exporter-1.4.0.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.4.0.linux-amd64.tar.gz node_exporter-1.4.0.linux-amd64

printf \
  '[Unit]
Description=Prometheus Node Exporter Service
After=network.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
[Install]
WantedBy=multi-user.target' \
> /tmp/node-exporter.service

sudo mv /tmp/node-exporter.service /etc/systemd/system/node-exporter.service

sudo systemctl daemon-reload
sudo systemctl enable node-exporter
sudo systemctl start node-exporter
sudo systemctl status node-exporter