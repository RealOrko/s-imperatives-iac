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
    # Change to S3 terraform state directory
    Set-Location "$PSScriptRoot/../../terraform/s3/terraform-state"
    
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
        Write-Host "Destroying S3 Terraform state resources..."
        terraform destroy -auto-approve
    } else {
        Write-Host "Planning S3 Terraform state deployment..."
        terraform plan
        
        Write-Host "Applying S3 Terraform state configuration..."
        terraform apply -auto-approve
    }
    
    Write-Host "S3 Terraform state operation completed successfully"
}
catch {
    Write-Error "S3 Terraform state operation failed: $_"
    exit 1
}
finally {
    # Return to original directory
    Set-Location $OriginalLocation
}