#!/bin/bash

# using kubesec docker image for scanning
scan_result=$(docker run -i kubesec/kubesec scan /dev/stdin < k8s_deployment_service.yaml)
scan_message=$(docker run -i kubesec/kubesec scan /dev/stdin < k8s_deployment_service.yaml | jq .[0].message -r)
scan_score=$(docker run -i kubesec/kubesec scan /dev/stdin < k8s_deployment_service.yaml | jq .[0].score)
	
    # Kubesec scan result processing
    # echo "Scan Score : $scan_score"

if [ $scan_score -ge 5 ] 
then
    echo "Score is $scan_score"
    echo "Kubesec Scan $scan_message"
else
    echo "Score is $scan_score, which is less than or equal to 5."
    echo "Scanning Kubernetes Resource has Failed"
    exit 1;
fi;
