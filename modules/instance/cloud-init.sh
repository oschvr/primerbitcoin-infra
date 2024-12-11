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
apt-get -y update && \
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
                  apache2-utils \
                  sqlite \
                  gnupg \
                  git \
                  cron \
                  moreutils \
                  rsyslog

# Enable syslogs
sudo systemctl enable rsyslog
sudo systemctl start rsyslog


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

# Install primerbitcoin
# Move from tmp to final location
mv /tmp/primerbitcoin /home/primerbitcoin/primerbitcoin
chmod +x /home/primerbitcoin/primerbitcoin

# Move env + yml files
mv /tmp/.env-init /home/primerbitcoin/.env
mv /tmp/application.yaml-init /home/primerbitcoin/application.yaml

# Create systemd unit
cat << EOF > /etc/systemd/system/primerbitcoin.service
[Unit]
Description=PrimerBitcoin
Documentation=https://github.com/oschvr/primerbitcoin
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=primerbitcoin
Group=primerbitcoin
WorkingDirectory=/home/primerbitcoin
ExecStart=/home/primerbitcoin/primerbitcoin

[Install]
WantedBy=multi-user.target
EOF

# Allow primerbitcoin user to sudo start/stop/restart only this service
echo "primerbitcoin ALL=(ALL) NOPASSWD: /bin/systemctl restart primerbitcoin" > /etc/sudoers
echo "primerbitcoin ALL=(ALL) NOPASSWD: /bin/systemctl start primerbitcoin" > /etc/sudoers
echo "primerbitcoin ALL=(ALL) NOPASSWD: /bin/systemctl stop primerbitcoin" > /etc/sudoers
echo "primerbitcoin ALL=(ALL) NOPASSWD: /bin/systemctl status primerbitcoin" > /etc/sudoers

# Create ssh key 
SSH_DIR="/home/primerbitcoin/.ssh"
mkdir "${SSH_DIR}"
ssh-keygen -t ed25519 -N '' -C primerbitcoin -f "${SSH_DIR}/primerbitcoin"

# Make sure you can see public key
cat "${SSH_DIR}/primerbitcoin.pub"

# Add ssh key for user in authorized_keys
echo $(cat "${SSH_DIR}/primerbitcoin.pub") >> "${SSH_DIR}/authorized_keys"

# Change mode for ssh
chown -R primerbitcoin: "${SSH_DIR}"
chmod 700 "${SSH_DIR}"
chmod 600 "${SSH_DIR}/authorized_keys"

# enable and start
sudo systemctl enable primerbitcoin
sudo systemctl start primerbitcoin

# Create encryption secret
echo "export ENCRYPTION_KEY=$(openssl rand -base64 32)" >> /home/primerbitcoin/.bashrc
echo "export GITHUB_TOKEN=<GH_TOKEN>" >> /home/primerbitcoin/.bashrc
#echo "export GITHUB_TOKEN=github_pat_***" >> /home/primerbitcoin/.bashrc

# Configure global git
git config --global user.email "oschvr@protonmail.com"
git config --global user.name "primerbitcoin"

# Install cronjob that will encrypt & backup db
cat << EOF > /home/primerbitcoin/database_backup.sh
#!/bin/bash

# Move to home dir
cd /home/primerbitcoin/

# Make sure we have all env vars present
source  /home/primerbitcoin/.bashrc

# Copy daily backup
PB_BACKUP_NAME=$(echo "primerbitcoin.sqlite.$(date +%s)")
cp -v primerbitcoin.sqlite $PB_BACKUP_NAME

# Encrypt using gpg
cat "${PB_BACKUP_NAME}" | gpg -c --batch --passphrase "${ENCRYPTION_KEY}" -o primerbitcoin.sqlite.gpg -

# Clone repo into folder /pb
git clone https://oauth2:"${GITHUB_TOKEN}"@github.com/oschvr/primerbitcoin pb

# Copy encrypted db into /pb
mv primerbitcoin.sqlite.gpg pb/primerbitcoin.sqlite.gpg

# Get in cloned repo
cd pb

# Commit db 
git add primerbitcoin.sqlite.gpg
git status 
git commit -m "[auto] Backup encrypted db $PB_BACKUP_NAME"
git push origin main

# Cleanup
cd ..
rm -rf pb
rm "${PB_BACKUP_NAME}"
EOF

# Update script to run nightly
chmod +x /home/primerbitcoin/database_backup.sh

# Add to crontab
# Redirect stderr to stdout 2>&1
# Append stdout to logfile
(crontab -l ; echo "0 0 * * * bash /home/primerbitcoin/database_backup.sh | ts '[\%Y-\%m-\%d \%H:\%M:\%S]' >> /home/primerbitcoin/primerbitcoin.db_backup.log 2>&1") | crontab -

# TODO: Script to pull and unencrypt (restore backup)
# gpg -d --batch --passphrase ${ENCRYPTION_KEY} "${PG_BACKUP_NAME}.gpg" > primerbitcoin.sqlite.1

# Check service and metrics are working internally
sleep 10
curl localhost:2112/metrics
