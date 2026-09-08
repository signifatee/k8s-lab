cp kubeconfig ~/.kube/k8s-lab.conf
export KUBECONFIG=~/.kube/k8s-lab.conf

kubectl get secret -n cert-manager lab-ca-key-pair \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | \
  sudo tee /usr/local/share/ca-certificates/lab-ca.crt
sudo update-ca-certificates

