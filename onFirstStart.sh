#!/bin/bash

set -e

(cd /tolgee && sudo bash ./generateConfig.sh)

(cd /tolgee && docker compose up -d)

(cd /tolgee && sudo bash ./cleanup.sh)
