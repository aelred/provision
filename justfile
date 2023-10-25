deploy:
    cd prod && terraform apply

stack stack:
    cd stacks/init && ./deploy.sh {{stack}}