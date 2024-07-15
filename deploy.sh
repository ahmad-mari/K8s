#!/bin/bash

# Download and install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add Helm repositories
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Create hello-kubernetes-first.yaml file
cat <<EOF > hello-kubernetes-first.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-first
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes-first
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes-first
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes-first
  template:
    metadata:
      labels:
        app: hello-kubernetes-first
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.10
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: Hello from the first deployment!
EOF

echo "hello-kubernetes-first.yaml created successfully."

# Create hello-kubernetes-second.yaml file
cat <<EOF > hello-kubernetes-second.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-kubernetes-second
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: hello-kubernetes-second
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-kubernetes-second
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-kubernetes-second
  template:
    metadata:
      labels:
        app: hello-kubernetes-second
    spec:
      containers:
      - name: hello-kubernetes
        image: paulbouwer/hello-kubernetes:1.10
        ports:
        - containerPort: 8080
        env:
        - name: MESSAGE
          value: Hello from the second deployment!
EOF

echo "hello-kubernetes-second.yaml created successfully."

# Apply both YAML files with kubectl
kubectl apply -f hello-kubernetes-first.yaml -f hello-kubernetes-second.yaml

# Create hello-kubernetes-ingress.yaml file
cat <<EOF > hello-kubernetes-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-kubernetes-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - hw1.al7oot.site
    - hw2.al7oot.site
    secretName: hello-kubernetes-tls
  rules:
  - host: hw1.al7oot.site
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: hello-kubernetes-first
            port:
              number: 80
  - host: hw2.al7oot.site
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: hello-kubernetes-second
            port:
              number: 80
EOF

echo "hello-kubernetes-ingress.yaml created successfully."

# Apply Ingress with kubectl
kubectl apply -f hello-kubernetes-ingress.yaml

# Create cert-manager namespace
kubectl create namespace cert-manager

# Install cert-manager with Helm
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.10.1 \
  --set installCRDs=true

echo "Cert-manager installed successfully."

# Create production_issuer.yaml file
cat <<EOF > production_issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: a.mari@eskadenia.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-private-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

echo "production_issuer.yaml created successfully."

# Apply production issuer with kubectl
kubectl apply -f production_issuer.yaml

echo "Deployment completed successfully."
