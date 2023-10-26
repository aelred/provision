deploy: deploy-infra deploy-swarm

deploy-infra:
    cd prod && terraform apply

deploy-swarm:
    cd prod/swarm && ./init.sh
    cd prod/swarm/stacks && ./deploy.sh traefik
    cd prod/swarm/stacks && ./deploy.sh portainer

stack stack:
    cd stacks/init && ./deploy.sh {{stack}}