#!/bin/bash
set -ex

# Get remote Kubernetes config
remote_k3s=$(mktemp)
sftp root@kube.ael.red:/etc/rancher/k3s/k3s.yaml "$remote_k3s"

# Modify config
KUBECONFIG="$remote_k3s" kubectl config set-cluster default --server=https://kube.ael.red:6443

# Merge config with existing config
merged_k3s=$(mktemp)
KUBECONFIG="$remote_k3s:~/.kube/config" kubectl config view --flatten > "$merged_k3s"

# Replace existing config with merged config (separate step so we don't clobber the file mid-read)
mv "$merged_k3s" ~/.kube/config