# Tolgee VM Image tools

This repository contains tools for creating and managing Tolgee VM images.
Currently, this repository is tailored to Azure Virtual Machines.

## How does it work?
This toolset contains a script `generateAzureImage.sh`, which creates a new VM on azure, setups Tolgee and creates 
an image from it. This image is used to be stored in the image gallery and can be used in 
partner center to create the offer.
