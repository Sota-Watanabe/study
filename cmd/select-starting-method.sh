#!/bin/bash

shopt -s expand_aliases
export PATH=/home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/cluster/:$PATH
alias kubectl='kubectl.sh'
cd $(dirname $0)

check_new_container (){
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
            echo "new ksvc!!=$ksvc_name"
            return 0
        fi
    done
    return 1

}
check_warmstart_condition (){
    return 0
}

echo 'reset container_data.csv'
echo '' > container_data.csv
echo 'reset checkpoint-list.dat'
echo '' > /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/checkpoint-list.dat

ksvc=`kubectl get ksvc -o=jsonpath="{.items[*].metadata.name}"`
echo $ksvc
if [ "$ksvc" != "" ]; then
    echo 'ksvc is not 0'
    exit 
fi
while true
do
    echo 'waiting ... please apply new container'
    sleep 1
    check_new_container
    ret=$?
    if [ $ret -eq 1 ]; then # not found new container
        continue
    fi
    echo "find new container !! ksvc_name = " $ksvc_name
    
    status=''
    while [ "$status" == '' ] || [ "$status" != '200' ];
    do
        echo 'checking_HTTP-200 to '$ksvc_name
        sleep 0.5
        status=`bash check_curl.sh $ksvc_name /Sample1/SimpleServlet`
    done

    
    ksvc_rev=`kubectl get ksvc $ksvc_name -o=jsonpath="{.status.latestCreatedRevisionName}"`
    CID=`docker ps -f name=k8s_user-container_$ksvc_rev  -q`
    echo "CID=$CID"

    MEM="`docker stats $CID --no-stream --format "{{.MemUsage}}"| awk '{print $1}'`"
    CPU_TIME="`docker top $CID |awk 'NR==2'| awk '{print $7}'`"
    CPU_LIMIT=`kubectl get ksvc $ksvc_name -o=jsonpath="{.spec.template.spec.containers[*].resources.limits.cpu}"`

    check_warmstart_condition
    ret=$?
    if [ $ret -eq 0 ]; then # match warmstart_condition
        FULFILL=true
        echo 'start to get checkpoint'
        echo 'get Docker image'
        commit_name=watanabesota/$ksvc_name-cp-from-select-starting-method
        docker commit $CID $commit_name
        echo 'update docker image to cp-from-select-starting-method'
        kubectl patch ksvc $ksvc_name --type=json -p "[ { "op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "$commit_name" } ]" 

        echo 'making checkpoint ...'
        cp_result=""
        rm -rf /cp/$ksvc_name
        while [ "$cp_result" == "" ] || [ "$cp_result" != "$ksvc_name" ];
        do
            echo 'looping'
            sleep 1
            cp_result=`docker checkpoint create $CID $ksvc_name --leave-running --checkpoint-dir /cp`
            echo $cp_result
        done
        echo 'add cat checkpoint-list.dat'
        echo $ksvc_name  >> /home/watanabe/go/src/k8s.io/kubernetes-v1.15.5/checkpoint-list.dat
        echo 'end of warmstart_preparation'
    else 
        FULFILL=false
    fi
    echo "ksvc_name: "$ksvc_name", cpu-limit: "$CPU_LIMIT", CPU_TIME: "$CPU_TIME", MEM: "$MEM", FULFILL: "$FULFILL
    echo $ksvc_name","$CPU_LIMIT","$CPU_TIME","$MEM","$FULFILL >> container_data.csv


done



#kubectl patch ksvc openj9 --type=json -p "[ { "op": "replace", "path": "/spec/template/spec/containers/0/image", "value": "watanabesota/openj9-cp" } ]" 

        #ksvc_name_new=`kubectl get ksvc -o=jsonpath="{.items[*].metadata.name}"`
        #ksvc_cpu=`kubectl get ksvc -o=jsonpath="{.items[*].spec.template.spec.containers[*].resources.limits.cpu}"`