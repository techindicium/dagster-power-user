#!/bin/bash

set -Eeuo pipefail

init() {
    echo -e "\n Initializing terraform configuration for module $1... \n"
    terraform -chdir="$1" init -backend-config="../config.s3.tfbackend"
}

destroy() {
    echo -e "\n Retracting terraform configuration for module $1... \n"
    terraform "-chdir=$1" plan -out=tfplan -destroy -var-file="../terraform.tfvars" -compact-warnings
    terraform "-chdir=$1" apply tfplan
}

retract() {
    init $1
    destroy $1
}

echo -e "\n Exporting environment variables... \n"

source .env

retract "infra/$1"
