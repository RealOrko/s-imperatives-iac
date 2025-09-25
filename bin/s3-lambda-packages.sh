#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

pushd $PWD/terraform/s3/lambda-packages

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
