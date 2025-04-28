#!/bin/bash

echo "Installing required packages..."
sudo apt update
sudo apt install -y docker.io docker-compose

echo "Creating Judge0 setup..."
mkdir -p ~/judge0
cd ~/judge0

# Create docker-compose.yml
cat > docker-compose.yml <<EOL
x-logging:
  &default-logging
  logging:
    driver: json-file
    options:
      max-size: 100M
services:
  server:
    image: judge0/judge0:latest
    volumes:
      - ./judge0.conf:/judge0.conf:ro
    ports:
      - "2358:2358"
    privileged: true
    <<: *default-logging
    restart: always
  worker:
    image: judge0/judge0:latest
    command: ["./scripts/workers"]
    volumes:
      - ./judge0.conf:/judge0.conf:ro
    privileged: true
    <<: *default-logging
    restart: always
  db:
    image: postgres:16.2
    env_file: judge0.conf
    volumes:
      - data:/var/lib/postgresql/data/
    <<: *default-logging
    restart: always
  redis:
    image: redis:7.2.4
    command: [
      "bash", "-c",
      'docker-entrypoint.sh --appendonly no --requirepass "\$\$REDIS_PASSWORD"'
    ]
    env_file: judge0.conf
    <<: *default-logging
    restart: always
volumes:
  data:
EOL

# Create judge0.conf
cat > judge0.conf <<EOL
DATABASE_URL=postgresql://postgres:postgres@db:5432/postgres
REDIS_URL=redis://:your_redis_password@redis:6379
REDIS_PASSWORD=your_redis_password
SECRET_KEY_BASE=replace_me_with_a_random_secret
EOL

echo "Starting Judge0 containers..."
docker-compose up -d --build

echo "Judge0 API installed successfully!"
