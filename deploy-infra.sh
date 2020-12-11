#!/bin/bash

# deploy-infra.sh

# CLI_PROFILE:       the profile to use, defined in ~/.aws/config
#
# EC2_INSTANCE_TYPE: an instance type in the free tier
#
# STACK_NAME:        the name that CloudFormation will use to refer to the
#                    group of resources it will manage

CLI_PROFILE=awsbootstrap
EC2_INSTANCE_TYPE=t2.micro
REGION=us-west-1
STACK_NAME=miguelc-awsbootstrap

# Programmatically get the AWS account ID from the AWS CLI
AWS_ACCOUNT_ID='aws sts get-caller-identity --profile awsboostrap \
                    --query "Account" --output text'

# S3 buckets most be globally unique across all AWS customers.
# So here we add our account ID to the bucket name to help prevent
# bucket naming collisions.
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

# Deploy static resources before CloudFormation stack
echo -e "\n\n=========== Deploying setup.yml ==========="
aws cloudformation deploy \
  --stack-name $STACK_NAME-setup \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabiliites CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodePipelineBucket=$CODEPIPELINE_BUCKET \
  --profile $CLI_PROFILE \
  --region $REGION

# Deploy the CloudFormation template
echo -e "\n\n=========== Deploying main.yml ==========="
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --template-file main.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EC2InstanceType=$EC2_INSTANCE_TYPE \
  --profile $CLI_PROFILE \
  --region $REGION

# If the deploy succeeded, print the app endpoint
if [ $? -eq 0 ]; then
  aws cloudformation list-exports \
    --profile $CLI_PROFILE \
    --query "Exports[?Name=='MyInstanceEndpoint'].Value"
fi
