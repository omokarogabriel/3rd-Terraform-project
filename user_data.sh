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



