#!/usr/bin/env pwsh

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Function to load environment variables from .env file
function Import-EnvFile {
    param([string]$FilePath = ".env")
    
    if (Test-Path $FilePath) {
        Get-Content $FilePath | ForEach-Object {
            if ($_ -match '^([^#][^=]*)=(.*)$') {
                $name = $Matches[1].Trim()
                $value = $Matches[2].Trim()
                [Environment]::SetEnvironmentVariable($name, $value, "Process")
                Write-Host "Loaded environment variable: $name"
            }
        }
    } else {
        throw "Environment file '$FilePath' not found"
    }
}

# Load environment variables
Write-Host "Loading environment configuration..."
Import-EnvFile

Write-Host "========================================="
Write-Host "Starting complete infrastructure deployment"
Write-Host "Environment: $($env:ENVIRONMENT)"
Write-Host "========================================="

try {
    # Execute deployment scripts in dependency order
    Write-Host "`n1. Deploying IAM roles and policies..."
    & "$PSScriptRoot/iam.ps1"
    
    Write-Host "`n2. Deploying S3 Lambda packages bucket..."
    & "$PSScriptRoot/s3-lambda-packages.ps1"
    
    Write-Host "`n3. Deploying Lambda authoriser function..."
    & "$PSScriptRoot/lambda-authoriser.ps1"
    
    Write-Host "`n4. Deploying Lambda S3 files function..."
    & "$PSScriptRoot/lambda-s3-files.ps1"
    
    Write-Host "`n5. Deploying API Gateway..."
    & "$PSScriptRoot/api-gateway.ps1"
    
    Write-Host "`n========================================="
    Write-Host "Complete infrastructure deployment successful!"
    Write-Host "All resources have been deployed in the correct order."
    Write-Host "========================================="
}
catch {
    Write-Error "`n========================================="
    Write-Error "Infrastructure deployment failed: $_"
    Write-Error "Please check the error above and resolve before retrying."
    Write-Error "========================================="
    exit 1
}