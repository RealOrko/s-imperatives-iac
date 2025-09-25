#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

rm -rf $PWD/terraform/lambda/authoriser/lambda_code
mkdir -p $PWD/terraform/lambda/authoriser/lambda_code
cp -r $PWD/src/authoriser/* $PWD/terraform/lambda/authoriser/lambda_code

pushd $PWD/terraform/lambda/authoriser

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
