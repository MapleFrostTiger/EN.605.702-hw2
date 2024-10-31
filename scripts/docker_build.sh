#!/bin/bash

# Build frontend and order processor images
docker build -t frontend ./docker/frontend
docker build -t order-processor ./docker/order-processor
