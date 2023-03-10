#!/bin/sh

echo "\nš¦ Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile polar

echo "\nš Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile polar

sleep 30

echo "\nš¦ Deploying Keycloak..."

kubectl apply -f services/keycloak-config.yml
kubectl apply -f services/keycloak.yml

sleep 5

echo "\nā Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=polar-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-keycloak \
  --timeout=300s

echo "\nš¦ Deploying PostgreSQL..."

kubectl apply -f services/postgresql.yml

sleep 5

echo "\nā Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=polar-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-postgres \
  --timeout=180s

echo "\nš¦ Deploying Redis..."

kubectl apply -f services/redis.yml

sleep 5

echo "\nā Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=180s

echo "\nš¦ Deploying RabbitMQ..."

kubectl apply -f services/rabbitmq.yml

sleep 5

echo "\nā Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=polar-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-rabbitmq \
  --timeout=180s

echo "\nš¦ Deploying Polar UI..."

kubectl apply -f services/polar-ui.yml

sleep 5

echo "\nā Waiting for Polar UI to be deployed..."

while [ $(kubectl get pod -l app=polar-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\nā Waiting for Polar UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=polar-ui \
  --timeout=180s
    
echo "\nāµ Happy Sailing!\n"