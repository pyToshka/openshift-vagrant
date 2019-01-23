#!/bin/bash

# Tag part
podman images | awk 'NR>1 {print $0}' | while read -r line; do

# Main environments
    img_name_old=$(echo "$line"  | awk '{print $1}')
    img_version=$(echo "$line"  | awk '{print $2}')
# Searchh registry
    img_name_k8s=$(echo "$line"| awk '{print $1}' | sed 's#k8s.gcr.io##g' )
    img_name_docker=$(echo "$line"| awk '{print $1}' | sed 's#docker.io##g' )
    img_name_quay=$(echo "$line"| awk '{print $1}' | sed 's#quay.io##g' )

# Patterns for sed
    k8s="k8s.gcr.io"
    docker="docker.io"
    quay="quay.io"

# Tag commands
    if  [[ "$line" == *"$k8s"* ]]; 
    then
        podman tag "$img_name_old":"$img_version" "$img_name_k8s":"$img_version"
    fi

    if [[ "$line" == *"$docker"* ]];
    then
        podman tag "$img_name_old":"$img_version" "$img_name_docker":"$img_version"
    fi

    if [[ "$line" == *"$quay"* ]];
    then
        podman tag "$img_name_old":"$img_version" "$img_name_quay":"$img_version"
    fi
done

# Push part
podman images | grep harbor | while read -r line; do

# Main environments
    img_name=$(echo "$line"  | awk '{print $1}')
    img_version=$(echo "$line"  | awk '{print $2}')
# Push commands with creds
    # podman login -u {username} -p {password} {repository}
    podman push --creds {username}:{password} "$img_name":"$img_version"
done