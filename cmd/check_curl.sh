#!/bin/sh
cd /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5
if cluster/kubectl.sh get configmap config-istio -n knative-serving > /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
fi
export IP_ADDRESS=localhost:$(cluster/kubectl.sh get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
curl -H "Host: $1.default.example.com" http://${IP_ADDRESS}  -o /dev/null -w "%{http_code}\n" -s