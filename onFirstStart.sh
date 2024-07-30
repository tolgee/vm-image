#!/bin/bash

set -e

(cd /tolgee && sudo bash ./generateConfig.sh)

(cd /tolgee && docker compose up -d)

(cd /tolgee && sudo bash ./cleanup.sh)

username=$(getent group sudo | cut -d: -f4)

echo "Adding the current user to the docker group..."
usermod -aG docker "$username"
