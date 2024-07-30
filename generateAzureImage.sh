#!/bin/bash

set -e

export LC_CTYPE=C
export LANG=C

is_cleanup=${IS_CLEANUP:-"true"}
resource_group_name="vm-creation"

random_string=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 5 || true)
vm_name="vm-$random_string"

cleanup(){
  if [ "$is_cleanup" != "false" ]; then

  echo "Cleaning up resources in resource group: $resource_group_name.
  If this fails, you can do it manually by deleting all resources in that group."

  echo "Deleting VM"
  az vm delete --resource-group "$resource_group_name" --name "$vm_name" --yes

  echo "Deleting VM resources"
  # Get list of all resources in the resource group
  resources=$(az resource list --resource-group "$resource_group_name" --query "[].id" -o tsv)

  # Loop through and delete each resource
  for resource in $resources; do
      echo "Deleting resource: $resource"
      az resource delete --ids "$resource" --verbose
  done


  echo "Deleting image"
  az image delete --resource-group "$resource_group_name" --name "$image_name"

  fi
}

# Cleanup on exit
trap cleanup EXIT
trap cleanup TERM
trap cleanup INT

if [ -z "$RESOURCE_GROUP_NAME" ]; then
  az group create --name "$resource_group_name" --location francecentral

  az vm create \
    --resource-group "$resource_group_name" \
    --name "$vm_name" \
    --image Canonical:ubuntu-24_04-lts:server:latest \
    --size Standard_B2s \
    --admin-username azureuser \
    --ssh-key-value ~/.ssh/id_rsa.pub
fi

## Wait until the VMs ip is ready by polling it for 5 minutes every 2 seconds
for i in {1..150}; do
  ip=$(az vm show --resource-group "$resource_group_name" --name "$vm_name" --show-details --query publicIps -o tsv)
  if [ -n "$ip" ]; then
    break
  fi
  sleep 2
done

## Wait until I can ssh into the VM
for i in {1..150}; do
  if ssh -o StrictHostKeyChecking=no azureuser@$ip "echo 'SSH is ready'"; then
    break
  fi
  sleep 2
done

## Define function allows me to execute script via ssh on the target ip
function ssh_exec {
  ssh -o StrictHostKeyChecking=no azureuser@$ip "$1"
}

echo "Copying files to the VM"
ssh_exec "sudo mkdir /tolgee && sudo chown -R \$USER:\$USER /tolgee"
scp -o StrictHostKeyChecking=no -r ./templates ./cleanup.sh ./generateConfig.sh ./install.sh ./onFirstStart.sh ./onFirstStart.service azureuser@$ip:/tolgee

echo "Executing the install script"
ssh_exec "cd /tolgee && sudo bash ./install.sh"

echo "Deprovisioning the VM usin waagent"
ssh_exec "sudo waagent -deprovision+user -force"

echo "Dealocating and generalizing the VM"
az vm deallocate --resource-group "$resource_group_name" --name "$vm_name"
az vm generalize --resource-group "$resource_group_name" --name "$vm_name"

subscription_id=$(az account show --query "id" --output tsv)
image_name="tolgee-$random_string"

echo "Creating image from the VM"
az image create --resource-group vm-test-2_group --name "$image_name" \
--source "/subscriptions/$subscription_id/resourceGroups/$resource_group_name/providers/Microsoft.Compute/virtualMachines/"$vm_name"" \
--hyper-v-generation V2

GALLERY_NAME="marketplace_gallery_2"
gallery_resource_group="vm-test-2_group"

# Get the latest version number
latest_version=$(az sig image-version list --resource-group "$gallery_resource_group" --gallery-name $GALLERY_NAME --gallery-image-definition tolgee --query "[].name" -o tsv | sort -V | tail -n 1)

echo "Latest version: $latest_version"

# Increment the version number
IFS='.' read -r major minor patch <<< "$latest_version"
new_patch=$((patch + 1))
new_version="$major.$minor.$new_patch"

echo "New version: $new_version"

echo "Creating image version in the gallery"
az sig image-version create \
--resource-group "$gallery_resource_group" \
--gallery-name "$GALLERY_NAME" \
--gallery-image-definition tolgee \
--gallery-image-version "$new_version" \
--managed-image "/subscriptions/$subscription_id/resourceGroups/vm-test-2_group/providers/Microsoft.Compute/images/$image_name" \
--location francecentral
