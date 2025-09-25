#!/bin/bash

# Script to recursively delete all .terraform folders
# This will forcefully remove all Terraform state and cached files

echo "Starting cleanup of .terraform folders..."

# Find and delete all .terraform directories recursively
find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null

echo "Cleanup complete! All .terraform folders have been removed."