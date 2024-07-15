#!/bin/bash

set -Eeuo pipefail

reset() {
    echo -e "\n Resetting terraform state for module $1... \n"
    terraform -chdir="$1" init -backend-config="../config.s3.tfbackend" -reconfigure
}

echo -e "\n Exporting environment variables... \n"

source .env

reset "infra/$1"
