#!/bin/bash

export $(cat .env | xargs)



echo $AWS_DEFAULT_REGION


pushd $PWD/terraform/s3/lambda-packages

    terraform fmt
    terraform init -backend-config="envs/${ENVIRONMENT}.hcl"
    terraform plan 
    terraform apply -auto-approve

popd 
