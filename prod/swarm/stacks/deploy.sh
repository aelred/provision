#!/bin/bash
set -ex
export DOCKER_HOST="ssh://root@drone.ael.red"

stack="$1"

export USERNAME="aelred"
export EMAIL="aelred717@gmail.com"

# Create an environment variable with the domain where you want to access your
# Portainer instance, e.g.:
export DOMAIN=${DOMAIN:="$stack.ael.red"}
# Make sure that your DNS records point that domain
# (e.g. portainer.sys.example.com) to one of the IPs of the Docker Swarm mode
# cluster.

# Get the Swarm node ID of this (manager) node and store it in an environment
# variable:
export NODE_ID=$(docker info -f '{{.Swarm.NodeID}}')

# Create a tag in this node, so that it's always deployed to the same node and
# uses the existing volume:
docker node update --label-add "$stack.$stack-data=true" $NODE_ID

# Deploy the stack with:
docker stack deploy -c "docker-compose.$stack.yml" $stack
# It will use the environment variables you created above.