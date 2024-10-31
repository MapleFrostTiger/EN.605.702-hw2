#!/bin/bash

# Update kubeconfig to interact with EKS
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Apply Kubernetes manifests
kubectl apply -f kubernetes/frontend-deployment.yaml
kubectl apply -f kubernetes/order-processor-deployment.yaml
kubectl apply -f kubernetes/postgres-deployment.yaml
kubectl apply -f kubernetes/secrets.yaml
