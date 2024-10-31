# Launch an Amazon Linux EC2 instance with t2.micro instance type and 30 GB EBS storage
# Update and install dependencies
sudo yum update -y
sudo yum install wget -y
sudo yum install java-17-amazon-corretto -y

# Create application directory and download Nexus
sudo mkdir /app && cd /app
sudo wget -O nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
sudo tar -xvf nexus.tar.gz
sudo mv nexus-3* nexus

# Create Nexus user and set permissions
sudo adduser nexus
sudo chown -R nexus:nexus /app/nexus
sudo mkdir /app/sonatype-work
sudo chown -R nexus:nexus /app/sonatype-work

# Configure Nexus to run as the "nexus" user
echo "run_as_user=nexus" | sudo tee /app/nexus/bin/nexus.rc

# Create Nexus systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=Nexus Repository Manager
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
EOL

# Enable and start Nexus service
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Check Nexus service status
sudo systemctl status nexus
