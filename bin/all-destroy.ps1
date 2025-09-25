#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

# Load environment variables from .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^([^#=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

& "$PSScriptRoot/api-gateway.ps1" "destroy"
& "$PSScriptRoot/lambda-s3-files.ps1" "destroy"
& "$PSScriptRoot/lambda-authoriser.ps1" "destroy"
& "$PSScriptRoot/s3-lambda-packages.ps1" "destroy"
& "$PSScriptRoot/iam.ps1" "destroy"