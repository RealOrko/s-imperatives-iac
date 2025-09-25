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

Push-Location "$PSScriptRoot/../terraform/api-gateway"

terraform fmt

if (-not (Test-Path ".terraform")) {
    terraform init -backend-config="envs/$($env:ENVIRONMENT).hcl"
}

if ($args[0] -eq "plan") {
    terraform plan
}

if ($args[0] -eq "apply") {
    terraform apply -auto-approve
}

if ($args[0] -eq "destroy") {
    terraform destroy -auto-approve
}

Pop-Location