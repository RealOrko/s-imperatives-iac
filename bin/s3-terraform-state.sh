#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

pushd $PWD/terraform/s3/terraform-state

    terraform fmt
    
    if [ ! -d ".terraform" ]; then
        terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    fi
    
    if [ "${1:-}" = "plan" ]; then
        terraform plan
    fi 

    if [ "${1:-}" = "apply" ]; then
        terraform apply -auto-approve
    fi 

    if [ "${1:-}" = "destroy" ]; then
        terraform destroy -auto-approve
    fi 

popd 
