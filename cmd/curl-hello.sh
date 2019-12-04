#!/bin/sh

if  kubectl get configmap config-istio -n knative-serving &> /dev/null; then
       INGRESSGATEWAY=istio-ingressgateway
fi
export IP_ADDRESS=$(kubectl get node  --output 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system   --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
curl -H "Host: $1.default.example.com" http://${IP_ADDRESS} -v -w "%{time_total}" 
