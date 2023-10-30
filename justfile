deploy-infra:
    cd prod && terraform apply

deploy-kube: deploy-infra
    echo "Waiting 5 minutes for DNS changes to propagate"
    sleep 300
    cd prod/kube && ./init-kubectl.sh