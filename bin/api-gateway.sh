#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

pushd $PWD/terraform/api-gateway

    terraform fmt
    
    if [ ! -d ".terraform" ]; then
        terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    fi
    
    if [ "${1:-}" = "destroy" ]; then
        terraform destroy -auto-approve
    else
        terraform plan 
        terraform apply -auto-approve
    fi

popd 
