docker compose down
sudo rm -rf ./data
./generateConfig.sh
docker compose up -d
