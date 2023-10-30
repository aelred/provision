deploy-infra:
    cd prod && terraform apply

deploy-swarm: deploy-infra
    echo "Waiting 5 minutes for DNS changes to propagate"
    sleep 300
    cd prod/swarm && ./init.sh
    cd prod/swarm/stacks && ./deploy.sh traefik
    cd prod/swarm/stacks && ./deploy.sh portainer

deploy-kube: deploy-infra
    echo "Waiting 5 minutes for DNS changes to propagate"
    sleep 300
    cd prod/kube && ./init-kubectl.sh