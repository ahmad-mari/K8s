Before we start here, you will find a file called k8s-installation-on-all-nodes.sh, clone it on all nodes and run it, after that we can start with the following.

curl -sf https://raw.githubusercontent.com/ahmad-mari/K8s/main/k8s-installation-on-all-nodes.sh | bash 

#run the Following on **MASTER** node only 
sudo kubeadm init

#After this it will result a kubeadm join code paste it on **WORKERS** nodes only
EX: kubeadm join <Master_IP_Adress>:6443 --token <TOKEN> \
        --discovery-token-ca-cert-hash <HASH>

#Now run this on **MASTER** only 

mkdir -p $HOME/.kube; sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config; sudo chown $(id -u):$(id -g) $HOME/.kube/config; kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
