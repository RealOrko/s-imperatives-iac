#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

. $PWD/bin/api-gateway.sh destroy
. $PWD/bin/lambda-s3-files.sh destroy
. $PWD/bin/lambda-authoriser.sh destroy
. $PWD/bin/iam.sh destroy
. $PWD/bin/s3-lambda-packages.sh destroy
