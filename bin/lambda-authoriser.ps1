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

Remove-Item "$PSScriptRoot/../terraform/lambda/authoriser/lambda_code" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$PSScriptRoot/../terraform/lambda/authoriser/lambda_code" -Force | Out-Null
Copy-Item "$PSScriptRoot/../src/authoriser/*" "$PSScriptRoot/../terraform/lambda/authoriser/lambda_code" -Recurse -Force

Push-Location "$PSScriptRoot/../terraform/lambda/authoriser"

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