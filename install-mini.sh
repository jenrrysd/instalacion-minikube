#!/bin/bash
## para servidores basados en .rpm corriendo en una maquina virtual

read -s -p "Ingresa tu password, NO se mostrará el password: " passs

echo "$passs" | sudo -S dnf install curl vim -y

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
echo "$passs" | sudo -S mv minikube /usr/local/bin/


echo "$passs" | sudo -S dnf install docker -y
echo "$passs" | sudo -S systemctl start docker
echo "$passs" | sudo -S systemctl enable docker

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
echo "$passs" | sudo -S mv kubectl /usr/local/bin/

echo "$passs" | sudo -S usermod -aG docker $USER && newgrp docker
minikube start --driver=docker --force

#crear un namespace
kubectl create namespace yape-personas

#creacion yml para las replicas
cat > replicas-minikube.yml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: public-interop-transfer-result-v2 #nombre de los pods a crear
  namespace: yape-personas #nombre del namespace a usar
spec:
  replicas: 10  # Número de réplicas que deseas (en este caso, 10)
  selector:
    matchLabels:
      app: public-interop-transfer-result-v2
  template:
    metadata:
      labels:
        app: public-interop-transfer-result-v2
    spec:
      containers:
      - name: nginx-contenedor #le ponemos un nombre del contenedor
        image: nginx:latest #imagen a usar
EOF

#ejecutar el yml para las replicas
kubectl apply -f replicas-minikube.yml

unset $passs
unset passs

#Levantando pods
echo "Esperar un minuto para mostrar los pods creados"
sleep 1m

kubectl get pods -n yape-personas

