#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

rm -rf $PWD/terraform/lambda/authoriser/lambda_code
mkdir -p $PWD/terraform/lambda/authoriser/lambda_code
cp -r $PWD/src/authoriser/* $PWD/terraform/lambda/authoriser/lambda_code

pushd $PWD/terraform/lambda/authoriser

    terraform fmt
    terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    terraform plan 
    terraform apply -auto-approve

popd 
