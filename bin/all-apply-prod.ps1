#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

# Override environment for production deployment
$env:ENVIRONMENT = "prod"
$env:TF_VAR_environment = "prod"

# Load other environment variables from .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$' -and $matches[1] -ne "ENVIRONMENT" -and $matches[1] -ne "TF_VAR_environment") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

Write-Host "=== Starting production deployment ==="
Write-Host "Environment: $env:ENVIRONMENT"

& "$PSScriptRoot/iam.ps1" "apply"
& "$PSScriptRoot/s3-lambda-packages.ps1" "apply"
& "$PSScriptRoot/lambda-authoriser.ps1" "apply"
& "$PSScriptRoot/lambda-s3-files.ps1" "apply"
& "$PSScriptRoot/api-gateway.ps1" "apply"

Write-Host "=== Production deployment completed successfully ==="