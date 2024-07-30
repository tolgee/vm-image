#!/bin/bash

set -e

echo "Updating the package database..."
apt-get update

echo "Installing required packages..."
apt-get install apt-transport-https ca-certificates curl software-properties-common -y

echo "Adding Docker’s official GPG key..."
# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "Setting up the Docker stable repository..."
# Set up the Docker stable repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y

echo "Updating the package database again..."
# Update the package database again
apt-get update

echo "Installing Docker..."
# Install Docker
apt-get install docker-ce docker-ce-cli containerd.io -y

echo "Enabling startup script..."
# Enable startup script so it's run on the first start
chmod +x onFirstStart.sh
cp onFirstStart.service /etc/systemd/system/onFirstStart.service
sudo systemctl enable onFirstStart.service
