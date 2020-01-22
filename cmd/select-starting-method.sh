#!/bin/bash

shopt -s expand_aliases
export PATH=/home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/cluster/:$PATH
alias kubectl='kubectl.sh'
cd $(dirname $0)

check_new_container (){
    #echo 'start check_new_container'
    container_data_list=()
    while read row; do
        column1=`echo ${row} | cut -d , -f 1`
        container_data_list=("${container_data_list[@]}" $column1)
    done < container_data.csv

    ksvc_names=`kubectl get ksvc -o=jsonpath="{.items[*].metadata.name}"`
    ksvc_list=(${ksvc_names// / })
    
    for ksvc_name in ${ksvc_names[@]}
    do       
        if ! `echo ${container_data_list[@]} | grep -q "$ksvc_name"` ; then
            #echo "new ksvc!!"
            return 0
        fi
    done
    return 1

}

while true
do
    sleep 1
    check_new_container
    ret=$?
    #echo "result=${ret}"
    if [ $ret -eq 1 ]; then # not found new container
        continue
    fi
    echo "find new container !! ksvc_name = " $ksvc_name
    
    #$status=''
    while [ "$status" == '' ] || [ "$status" != '200' ];
    do
        echo 'checking_HTTP-200 to '$ksvc_name
        sleep 0.5
        status=`bash check_curl.sh array-init`
    done

done





        #ksvc_name_new=`kubectl get ksvc -o=jsonpath="{.items[*].metadata.name}"`
        #ksvc_cpu=`kubectl get ksvc -o=jsonpath="{.items[*].spec.template.spec.containers[*].resources.limits.cpu}"`