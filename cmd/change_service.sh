#!/bin/sh
cd $(dirname $0)
echo 'Start after 3 seconds'
sleep 3
while read array
do
  while read loop
  do
  
  NUM=`docker ps -f name=user| wc -l`
  while [ $NUM != '1' ];
  do
    echo 'still running'
    sleep 1
    NUM=`docker ps -f name=user| wc -l`
  done

  echo 'if container running, delete container'
  /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/cluster/kubectl.sh delete ksvc/array-init
  echo ''
  echo 'Start up under the following conditions'
  echo "array=" $array "loop=" $loop
  echo ''
cat << EOF | /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/cluster/kubectl.sh  apply -f -
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: array-init
  namespace: default
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/target: "10"
    spec:
      containers:
      - image: docker.io/watanabesota/array-init-commit
        env:
        - name: CHECKPOINT
          value: "True"
        - name: ARRAY
          value: "$array"
        - name: LOOP
          value: "$loop"
EOF
  sleep 5
  NUM=`docker ps -f name=user| wc -l`
  while [ $NUM != '1' ];
  do
    echo 'still running'
    sleep 1
    NUM=`docker ps -f name=user| wc -l`
  done
  echo 'end of container'
  sleep 5
  bash cpumem.sh

  done < loop.txt  

done < array.txt