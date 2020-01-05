#!/bin/bash
cd /home/watanabe/go/src/k8s.io/kubernetes*
if cluster/kubectl.sh get configmap config-istio -n knative-serving > /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
fi
export IP_ADDRESS=localhost:$(cluster/kubectl.sh get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
start_time=$(date +"%s.%3N")
echo looping ...
while :
do
  stats=`curl -H "Host: $1.default.example.com" http://${IP_ADDRESS}$2  -o /dev/null -w "%{http_code}\n" -s`
  if [ "$stats" = "200" ] ; then
    # echo '200 OK'
    break
  fi
  echo looping ...
done
end_time=$(date +"%s.%3N")
# time=$((end_time - start_time))

echo "scale=1; $end_time - $start_time" | bc
# while getopts "c" OPT
# do
#   case $OPT in
#     c) docker checkpoint create $(docker ps -f name=user -q --no-trunc) array-init --checkpoint-dir=/cp;;
#   esac
# done
