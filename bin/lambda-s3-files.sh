#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

rm -rf $PWD/terraform/lambda/s3-files/lambda_code
mkdir -p $PWD/terraform/lambda/s3-files/lambda_code
cp -r $PWD/src/s3-files/* $PWD/terraform/lambda/s3-files/lambda_code

pushd $PWD/terraform/lambda/s3-files

    terraform fmt
    terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    terraform plan 
    terraform apply -auto-approve

popd 
