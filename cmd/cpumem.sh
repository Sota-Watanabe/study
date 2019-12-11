#!/bin/bash
cd /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/
times=1
while getopts "tn:" OPT
do
  case $OPT in
    t) times=10;;
    n) times=$OPTARG
  esac
done

for((i = 0; i<$times; i++)); do

  NUM=`docker ps -f name=user| wc -l`
  while [ $NUM != '1' ];
  do
    echo 'still running'
    sleep 1
    NUM=`docker ps -f name=user| wc -l`
  done
  if cluster/kubectl.sh get configmap config-istio -n knative-serving > /dev/null; then
        INGRESSGATEWAY=istio-ingressgateway
  fi
  export IP_ADDRESS=localhost:$(cluster/kubectl.sh get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
  OUTPUT=`curl -H "Host: array-init.default.example.com" http://${IP_ADDRESS}  -w "%{time_total}" `
  echo ''

  NUM=`docker ps -f name=user| wc -l`
  while [ $NUM != '2' ];
  do
    echo 'not only one'
    sleep 1
    NUM=`docker ps -f name=user| wc -l`
  done
  CID=`docker ps -f name=user -q --no-trunc`
  CPU_TIME="`docker top $CID |awk 'NR==2'| awk '{print $7}'`"
  MEM="`docker stats $CID --no-stream --format "{{.MemUsage}}"| awk '{print $1}'`"

  echo $OUTPUT | while read array loop version checkpoint latency; do
    echo  ${checkpoint#*=} $latency $CPU_TIME $MEM ${array#*=} ${loop#*=}  >> evaluation.log
    echo  ${checkpoint#*=} $latency $CPU_TIME $MEM ${array#*=} ${loop#*=}
  done;
  
done