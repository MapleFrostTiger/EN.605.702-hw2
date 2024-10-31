#!/bin/bash

# Tag and push images to ECR
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

docker tag frontend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/frontend:latest
docker tag order-processor:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/order-processor:latest

docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/order-processor:latest
