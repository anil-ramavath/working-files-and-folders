#!/bin/bash

set -e

# Update system
sudo yum update -y

# Create application directory
sudo mkdir -p /app
cd /app

# Download Nexus
sudo wget -O nexus.tar.gz \
https://download.sonatype.com/nexus/3/nexus-3.96.0-09-linux-x86_64.tar.gz

# Verify archive
file nexus.tar.gz

# Extract
sudo tar -xzf nexus.tar.gz

# Rename extracted directory
sudo mv nexus-3.96.0-09 nexus

# Create Nexus user
sudo useradd --system --home /app/nexus --shell /bin/bash nexus 2>/dev/null || true

# Set ownership
sudo chown -R nexus:nexus /app/nexus

# Nexus data directory
sudo mkdir -p /app/sonatype-work
sudo chown -R nexus:nexus /app/sonatype-work

# Run Nexus as nexus user
echo 'run_as_user="nexus"' | sudo tee /app/nexus/bin/nexus.rc

# Systemd service
sudo tee /etc/systemd/system/nexus.service > /dev/null <<'EOF'
[Unit]
Description=Nexus Repository
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable and start
sudo systemctl enable nexus
sudo systemctl start nexus

# Status
sudo systemctl status nexus --no-pager
