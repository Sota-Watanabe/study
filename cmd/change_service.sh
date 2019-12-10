#!/bin/sh
cd $(dirname $0)
while read array
do
  while read loop
  do
  echo "array=" $array "loop=" $loop
  /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/cluster/kubectl.sh delete ksvc/array-init
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

  echo "sloop"
  sleep 10
  
  done < loop.txt  

done < array.txt