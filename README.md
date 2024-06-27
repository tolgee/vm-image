# Tolgee VM Image tools

This repository contains tools for creating and managing Tolgee VM images.
Currently, this repository is tailored to Azure Virtual Machines.

## The setup (for Azure)
When creating the new VM you need to
1. Create the new Virtual Machine in Azure
2. Clone contents of this repo to the `/tolgee` directory
   ```bash 
   sudo git clone https://github.com/tolgee/vm-image.git /tolgee
   cd tolgee
   sudo chown -R $USER:$USER .
   ```
3. Run the `sudo bash ./install.sh`. It
   - installs the docker
   - setup service, which will run initialization script `onFirstStart.sh` when the VM starts for the first time

## The `onFirstStart.sh` 
- create configs (`docker-compose.yaml` and `congig.yaml`) with generated postgres password
- run the docker containers
- runs cleanup script (which also removes the onFirstStart script and service)

## The reset script

The reset script is useful for debugging. It removes the containers and all the data and rerun the configs generating
script.

```bash
./reset.sh
```
