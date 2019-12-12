#!/bin/sh
cp=false
while getopts "c" OPT
do
  case $OPT in
    c) cp=true;;
  esac
done

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
  sleep 1
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
            value: "$cp"
          - name: ARRAY
            value: "$array"
          - name: LOOP
            value: "$loop"
          resources:
            limits:
              cpu: "1500m"
EOF

  status=`check_curl.sh array-init`
  while [ $status != '200' ];
  do
    echo 'making init container'
    sleep 0.5
    status=`check_curl.sh array-init`
  done
  echo 'Completion of Container registration'
  if "${cp}"; then
      rm -r /cp/array-init
      echo 'makeing checkpoint ...'
      docker checkpoint create $(docker ps -f name=k8s_user-container_array-init -q ) array-init --leave-running --checkpoint-dir /cp
  fi



  echo 'start cpumem.sh'
  bash cpumem.sh

  done < loop.txt  

done < array.txt