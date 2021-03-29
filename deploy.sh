#!/bin/bash
set -e
## Deploy infrastructure to AWS:

cd terraform
echo "Initialising Terraform Modules..."
terraform init
echo "Executing Terraform Plan..."
terraform plan
echo "Executing Terraform Apply and creating infrastructure..."
terraform apply --auto-approve
