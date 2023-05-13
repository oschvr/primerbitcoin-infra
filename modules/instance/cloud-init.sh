
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
sudo apt-get -y install wget ca-certificates zip net-tools vim tar netcat curl duf jq

# Set node_exporter service
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

# Install node_exporter binaries
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo rm -rf node_exporter-1.3.1.linux-amd64 node_exporter-1.3.1.linux-amd64.tar.gz
sudo useradd -rs /sbin/nologin node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sleep 5
curl http://0.0.0.0:9100/metrics

# Install Prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus
sudo mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done
mkdir -p /tmp/prometheus && cd /tmp/prometheus
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
tar xvf prometheus*.tar.gz
cd prometheus*/
sudo mv prometheus promtool /usr/local/bin/
prometheus --version
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo mv consoles/ console_libraries/ /etc/prometheus/
cd $HOME

sudo tee /etc/prometheus/prometheus.yml<<EOF
global:
  scrape_interval:    60s # Set the scrape interval to 1 minute.
  evaluation_interval: 60s # Evaluate rules every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['localhost:9100']
EOF


sudo tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

for i in rules rules.d files_sd; do sudo chown -R prometheus:prometheus /etc/prometheus/${i}; done
for i in rules rules.d files_sd; do sudo chmod -R 775 /etc/prometheus/${i}; done
sudo chown -R prometheus:prometheus /var/lib/prometheus/

sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus