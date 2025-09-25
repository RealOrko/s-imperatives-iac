#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

rm -rf $PWD/terraform/lambda/s3-files/lambda_code
mkdir -p $PWD/terraform/lambda/s3-files/lambda_code
cp -r $PWD/src/s3-files/* $PWD/terraform/lambda/s3-files/lambda_code

pushd $PWD/terraform/lambda/s3-files

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
