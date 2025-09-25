#!/bin/bash

set -euo pipefail

export $(cat .env | xargs)

. $PWD/bin/iam.sh
. $PWD/bin/s3-lambda-packages.sh
. $PWD/bin/lambda-authoriser.sh
. $PWD/bin/lambda-s3-files.sh
. $PWD/bin/api-gateway.sh
