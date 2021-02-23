/*
  After provisioning the cluster, you can run this to copy the kubeconfig:

  PUBLIC_IP_KUBE1=$(terraform output -json | jq '.kube_ips.value[0]' -r)
  scp root@${PUBLIC_IP_KUBE1}:/etc/kubernetes/admin.conf ~/.kube/config
  kubectl config set-cluster kubernetes --server=https://${PUBLIC_IP_KUBE1}:6443
*/
output kube_ips {
  value = module.provider.public_ips
}