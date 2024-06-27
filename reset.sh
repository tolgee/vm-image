# Update the package database
apt-get update

# Install necessary packages
apt-get install apt-transport-https ca-certificates curl software-properties-common -y

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Set up the Docker stable repository
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" -y

# Update the package database again
apt-get update

# Install Docker
apt-get install docker-ce docker-ce-cli containerd.io -y

# Add the current user to the docker group
usermod -aG docker azureuser

sudo ./generateConfig.sh

docker compose up -d
