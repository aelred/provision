deploy: deploy-infra deploy-swarm init-kubectl

deploy-infra:
    cd prod && terraform apply

deploy-swarm:
    cd prod/swarm && ./init.sh
    cd prod/swarm/stacks && ./deploy.sh traefik
    cd prod/swarm/stacks && ./deploy.sh portainer

init-kubectl:
    cd prod/kube && ./init-kubectl.sh

stack stack:
    cd stacks/init && ./deploy.sh {{stack}}