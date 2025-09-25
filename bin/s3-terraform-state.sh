#!/bin/bash

export $(cat .env | xargs)



echo $AWS_DEFAULT_REGION


pushd $PWD/terraform/s3/terraform-state

    terraform fmt
    terraform init
    terraform plan 
    #terraform apply -auto-approve

popd 
