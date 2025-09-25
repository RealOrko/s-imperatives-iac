#!/bin/bash

set -euo pipefail

# Override environment for production deployment
export ENVIRONMENT=prod
export TF_VAR_environment=prod

# Load other environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | grep -v '^ENVIRONMENT' | grep -v '^TF_VAR_environment' | xargs)
fi

echo "=== Starting production deployment ==="
echo "Environment: $ENVIRONMENT"

. $PWD/bin/iam.sh apply
. $PWD/bin/s3-lambda-packages.sh apply
. $PWD/bin/lambda-authoriser.sh apply
. $PWD/bin/lambda-s3-files.sh apply
. $PWD/bin/api-gateway.sh apply

echo "=== Production deployment completed successfully ==="