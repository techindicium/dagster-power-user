#!/bin/bash

set -Eeuo pipefail

init() {
    echo -e "\n Initializing terraform configuration for module $1... \n"
    terraform -chdir="$1" init -backend-config="../config.s3.tfbackend"
}

apply() {
    echo -e "\n Deploying terraform configuration for module $1... \n"
    terraform "-chdir=$1" plan -out=tfplan -var-file="../terraform.tfvars"
    terraform "-chdir=$1" apply tfplan
}

deploy() {
    init $1
    apply $1
}

echo -e "\n Exporting environment variables... \n"

source .env

deploy "infra/$1"

