#!/bin/bash
set -ex
export DOCKER_HOST="ssh://root@drone.ael.red"

# Check can connect to SSH
ssh -q "root@drone.ael.red" exit

if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" == "inactive" ]; then
    docker swarm init
fi

[ "$(docker network ls | grep traefik-public)" ] || docker network create --driver=overlay traefik-public
