#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

pushd $PWD/terraform/s3/terraform-state

    terraform fmt
    terraform init
    terraform plan 
    terraform apply -auto-approve

popd 
