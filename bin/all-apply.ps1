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

& "$PSScriptRoot/iam.ps1" "apply"
& "$PSScriptRoot/s3-lambda-packages.ps1" "apply"
& "$PSScriptRoot/lambda-authoriser.ps1" "apply"
& "$PSScriptRoot/lambda-s3-files.ps1" "apply"
& "$PSScriptRoot/api-gateway.ps1" "apply"