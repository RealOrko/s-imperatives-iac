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
Write-Host "Starting complete infrastructure destruction"
Write-Host "Environment: $($env:ENVIRONMENT)"
Write-Host "========================================="

try {
    # Execute destruction scripts in reverse dependency order
    Write-Host "`n1. Destroying API Gateway..."
    & "$PSScriptRoot/api-gateway.ps1" -Action "destroy"
    
    Write-Host "`n2. Destroying Lambda S3 files function..."
    & "$PSScriptRoot/lambda-s3-files.ps1" -Action "destroy"
    
    Write-Host "`n3. Destroying Lambda authoriser function..."
    & "$PSScriptRoot/lambda-authoriser.ps1" -Action "destroy"
    
    Write-Host "`n4. Destroying IAM roles and policies..."
    & "$PSScriptRoot/iam.ps1" -Action "destroy"
    
    Write-Host "`n5. Destroying S3 Lambda packages bucket..."
    & "$PSScriptRoot/s3-lambda-packages.ps1" -Action "destroy"
    
    Write-Host "`n========================================="
    Write-Host "Complete infrastructure destruction successful!"
    Write-Host "All resources have been destroyed in the correct order."
    Write-Host "========================================="
}
catch {
    Write-Error "`n========================================="
    Write-Error "Infrastructure destruction failed: $_"
    Write-Error "Please check the error above and resolve before retrying."
    Write-Error "Some resources may still exist and need manual cleanup."
    Write-Error "========================================="
    exit 1
}