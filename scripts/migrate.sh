#!/bin/bash

set -Eeuo pipefail

migrate() {
    echo -e "\n Migrating terraform state for module $1... \n"
    terraform -chdir="$1" init -backend-config="../config.s3.tfbackend" -force-copy
}

echo -e "\n Exporting environment variables... \n"

source .env

migrate "infra/$1"