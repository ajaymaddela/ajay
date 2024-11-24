#!/bin/bash

# Navigate to the directory containing the docker-compose.yaml file
cd "$(dirname "$0")"

# Run Docker Compose
docker compose up -d