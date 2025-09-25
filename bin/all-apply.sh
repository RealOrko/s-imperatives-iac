#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

. $PWD/bin/iam.sh apply
. $PWD/bin/s3-lambda-packages.sh apply
. $PWD/bin/lambda-authoriser.sh apply
. $PWD/bin/lambda-s3-files.sh apply
. $PWD/bin/api-gateway.sh apply
