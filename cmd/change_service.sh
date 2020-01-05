#!/bin/bash
cp=false
echo '' > /home/watanabe/go/src/k8s.io/kubernetes*/checkpoint-list.dat
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
  echo "array=" $array "loop=" $loop "checkpoint=" $cp
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
              cpu: "1000m"
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
      echo 'making checkpoint ...'
      cp_result=""
      rm -r /cp/array-init
      while [ "$cp_result" == "" ] || [ "$cp_result" != "array-init" ];
      do
        echo 'looping'
        sleep 1
        cp_result=`docker checkpoint create $(docker ps -f name=k8s_user-container_array-init -q ) array-init --leave-running --checkpoint-dir /cp`
        echo $cp_result
      done
      echo 'add array-init checkpoint-list.dat'
      echo array-init >> /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/checkpoint-list.dat
  fi


  echo 'start cpumem.sh'
  echo ''
  bash cpumem.sh -n 3

  echo '' > /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/checkpoint-list.dat
  
  done < loop.txt  
done < array.txt