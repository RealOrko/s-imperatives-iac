#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

. $PWD/bin/iam.sh plan
. $PWD/bin/s3-lambda-packages.sh plan
. $PWD/bin/lambda-s3-files.sh plan
. $PWD/bin/lambda-authoriser.sh plan
. $PWD/bin/api-gateway.sh plan
