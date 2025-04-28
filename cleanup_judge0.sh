#!/bin/bash

echo "Stopping and removing Judge0 containers..."
docker-compose down --volumes --remove-orphans || true
docker stop $(docker ps -q --filter ancestor=judge0/judge0) || true
docker rm $(docker ps -a -q --filter ancestor=judge0/judge0) || true

echo "Removing Judge0 images..."
docker rmi judge0/judge0 || true
docker rmi postgres:16.2 || true
docker rmi redis:7.2.4 || true

echo "Pruning Docker system (containers, volumes, networks, etc.)..."
docker system prune -a --volumes -f

echo "Deleting old Judge0 folders..."
rm -rf ~/judge0

echo "Cleanup finished!"
