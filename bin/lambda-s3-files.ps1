#!/usr/bin/env pwsh

param(
    [string]$Action = "apply"
)

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
Import-EnvFile

# Store current directory
$OriginalLocation = Get-Location

try {
    # Prepare Lambda code directory
    $lambdaCodePath = "$PSScriptRoot/../../terraform/lambda/s3-files/lambda_code"
    $srcPath = "$PSScriptRoot/../../src/s3-files"
    
    Write-Host "Preparing Lambda S3 files code..."
    
    # Remove existing lambda_code directory if it exists
    if (Test-Path $lambdaCodePath) {
        Remove-Item $lambdaCodePath -Recurse -Force
    }
    
    # New lambda_code directory
    New-Item -ItemType Directory -Path $lambdaCodePath -Force | Out-Null
    
    # Copy source files to lambda_code directory
    Copy-Item "$srcPath/*" $lambdaCodePath -Recurse -Force
    
    # Change to Lambda S3 files terraform directory
    Set-Location "$PSScriptRoot/../../terraform/lambda/s3-files"
    
    # Format Terraform files
    Write-Host "Formatting Terraform files..."
    terraform fmt
    
    # Initialize Terraform if not already done
    if (-not (Test-Path ".terraform")) {
        Write-Host "Initializing Terraform..."
        $envFile = "envs/$($env:ENVIRONMENT).hcl"
        terraform init -backend-config="$envFile"
    }
    
    # Execute action based on parameter
    if ($Action -eq "destroy") {
        Write-Host "Destroying Lambda S3 files resources..."
        terraform destroy -auto-approve
    } else {
        Write-Host "Planning Lambda S3 files deployment..."
        terraform plan
        
        Write-Host "Applying Lambda S3 files configuration..."
        terraform apply -auto-approve
    }
    
    Write-Host "Lambda S3 files operation completed successfully"
}
catch {
    Write-Error "Lambda S3 files operation failed: $_"
    exit 1
}
finally {
    # Return to original directory
    Set-Location $OriginalLocation
}