
#!/bin/bash

set -x -o pipefail

# Wait for cloud-init race condition
timeout 180 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'


# TODO: need to setup proper iptables rules
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X

# Make debian quiet
export DEBIAN_FRONTEND="noninteractive"

# Packages
sudo apt-get update && \
sudo apt-get -y upgrade && \
sudo apt-get -y install wget ca-certificates zip net-tools vim nano tar netcat curl

# Install node_exporter binaries
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.0/node_exporter-1.2.0.linux-amd64.tar.gz
tar xvf node_exporter-1.2.0.linux-amd64.tar.gz
sudo cp node_exporter-1.2.0.linux-amd64/node_exporter /usr/local/bin
sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown -R node_exporter:node_exporter /var/lib/node_exporter/textfile_collector
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo rm -rf node_exporter-1.2.0.linux-amd64.tar.gz node_exporter-1.2.0.linux-amd64

cat << EOF > /tmp/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network.target
After=network.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
 
[Install]
WantedBy=multi-user.target
EOF

# Enable node_exporter as a service
sudo mv /tmp/node_exporter.service /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sleep 10
curl -s 0.0.0.0:9100/metrics

echo "FINISH !"