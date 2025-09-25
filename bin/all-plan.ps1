# PowerShell script for Terraform validation and planning
param(
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

# Load environment variables from .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^=]+)=(.*)$") {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
        }
    }
}

Write-Host "=== Starting Terraform validation and planning for all modules ===" -ForegroundColor Green

# Function to validate and plan a terraform module
function Plan-Module {
    param(
        [string]$ModulePath
    )
    
    $ModuleName = Split-Path $ModulePath -Leaf
    
    Write-Host "=== Processing module: $ModuleName ===" -ForegroundColor Yellow
    
    Push-Location $ModulePath
    
    try {
        Write-Host "Running terraform fmt for $ModuleName..." -ForegroundColor Cyan
        terraform fmt -check
        
        Write-Host "Running terraform validate for $ModuleName..." -ForegroundColor Cyan
        if (!(Test-Path ".terraform")) {
            terraform init -backend-config="envs/$Environment.hcl"
        }
        
        terraform validate
        
        Write-Host "Running terraform plan for $ModuleName..." -ForegroundColor Cyan
        terraform plan
        
        Write-Host "=== Completed module: $ModuleName ===" -ForegroundColor Green
        Write-Host ""
    }
    finally {
        Pop-Location
    }
}

# Plan all modules in the correct order
Write-Host "Planning S3 terraform state module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/s3/terraform-state"

Write-Host "Planning IAM module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/iam"

Write-Host "Planning S3 lambda packages module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/s3/lambda-packages"

Write-Host "Planning Lambda authoriser module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/lambda/authoriser"

Write-Host "Planning Lambda s3-files module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/lambda/s3-files"

Write-Host "Planning API Gateway module..." -ForegroundColor Magenta
Plan-Module "$PSScriptRoot/../terraform/api-gateway"

Write-Host "=== All terraform modules validation and planning completed successfully ===" -ForegroundColor Green