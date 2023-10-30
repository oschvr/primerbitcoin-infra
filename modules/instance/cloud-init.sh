
#!/bin/bash

# Wait for lock
if ! pgrep apt >/dev/null; then
  rm /var/lib/dpkg/lock
  rm /var/lib/apt/lists/lock
  rm /var/cache/apt/archives/lock
  rm /var/lib/dpkg/lock-frontend
  echo "Lock files deleted successfully."
else
  echo "Apt process is still running. Lock files cannot be deleted."
fi

# Make debian quiet
export DEBIAN_FRONTEND="noninteractive"

# Configure dpkg lock timeout
apt-get  -o DPkg::Lock::Timeout=30 update

# Allow 443
iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
/sbin/iptables-save > /etc/iptables/rules.v4

# Install packages
apt-get update -y && \
apt-get -y upgrade && \
apt-get -y install wget \
                  ca-certificates \
                  zip \
                  net-tools \
                  vim \
                  tar \
                  netcat \
                  curl \
                  duf \
                  jq \
                  build-essential \
                  net-tools \
                  nginx \
                  apache2-utils 

# Install go
wget "https://go.dev/dl/go1.21.3.linux-amd64.tar.gz"
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
rm go1.21.3.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
go version

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
mv /tmp/node_exporter.service /etc/systemd/system/node_exporter.service

# Install node_exporter binaries
NODE_EXPORTER_VERSION="1.3.1"
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

tar xvfz "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
mv "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
rm -rf "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64" "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
useradd -rs /sbin/nologin node_exporter
systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
sleep 5
curl http://0.0.0.0:9100/metrics

# Create primerbitcoin user
useradd -m -d /home/primerbitcoin -s /bin/bash primerbitcoin

# Log in as user
su - primerbitcoin

# Create ssh key 
mkdir ~/.ssh
ssh-keygen -t ed25519 -N '' -C primerbitcoin -f ~/.ssh/primerbitcoin

# Make sure you can see public key
cat ~/.ssh/primerbitcoin.pub

# Add ssh key for user in authorized_keys
echo $(cat ~/.ssh/primerbitcoin.pub) >> ~/.ssh/authorized_keys

# Change mode for ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# You need to retrieve the private key
# cat ~/.ssh/primerbitcoin

# Install primerbitcoin
# Pull the binary (compile it here? from local computer)
# Allow primerbitcoin user to sudo restart only this service
# Check service and metrics are working internally
# Check metrics can be pulled externally