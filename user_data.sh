#!/bin/bash

# This script is used to install and configure user data for a Linux system.

# Update the system
echo "Updating the system..."
sudo apt-get update -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y git apache2 awscli

# Start and enable Apache service
echo "Starting and enabling Apache service..."
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a sample HTML file
echo "Creating a sample HTML file..."
echo "<html><body><h1>Hello, World!</h1></body></html>" | sudo tee /var/www/html/index.html

# Set permissions for the web directory
echo "Setting permissions for the web directory..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html


# Install CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    dpkg -i -E ./amazon-cloudwatch-agent.deb

    # Fetch config from SSM Parameter Store
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -c ssm:${aws_ssm_parameter.cw_agent_config.name} -s



