#!/bin/sh

docker build -t watanabesota/$1 .
docker push watanabesota/$1
docker pull watanabesota/$1
kubectl delete -f service.yaml
kubectl apply -f service.yaml
