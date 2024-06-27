#!/bin/bash

rm README.md
rm -rf templates
rm .gitignore
rm -rf .git
rm -rf reset.sh
rm -rf cleanup.sh
rm -rf install.sh
rm -rf generateConfig.sh
rm onFirstStart.sh
rm onFirstStart.service

systemctl disable onFirstStart.service

rm /etc/systemd/system/onFirstStart.service
systemctl daemon-reload

echo "Cleanup completed"
