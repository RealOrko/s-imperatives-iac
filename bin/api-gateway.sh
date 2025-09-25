#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

pushd $PWD/terraform/api-gateway

    terraform fmt
    terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    terraform plan 
    terraform apply -auto-approve

popd 
