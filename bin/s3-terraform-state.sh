#!/bin/bash

export $(cat .env | xargs)



echo $AWS_DEFAULT_REGION


pushd $PWD/s3/terraform-state

    terraform init
    terraform plan 
    terraform apply -auto-approve

popd 
