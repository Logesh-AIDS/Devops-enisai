#!/bin/bash
# Import existing ECS service into Terraform state

set -e

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=${AWS_REGION:-us-east-1}

echo "Importing ECS service into Terraform state..."
echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"

# Import the ECS service
terraform import aws_ecs_service.enisai "arn:aws:ecs:${REGION}:${ACCOUNT_ID}:service/enisai-cluster/enisai-service"

echo "ECS service imported successfully!"
echo "Run 'terraform plan' to verify the import."
