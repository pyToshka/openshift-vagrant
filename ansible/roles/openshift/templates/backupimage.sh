#!/bin/bash

# Tag part
podman images | awk 'NR>1 {print $0}' | while read -r line; do

# Main environments
    img_name_old=$(echo "$line"  | awk '{print $1}')
    img_version=$(echo "$line"  | awk '{print $2}')
# Searchh registry
    img_name_docker=$(echo "$line"| awk '{print $1}' | sed 's#docker.io#{repository}#g' )
    img_name_quay=$(echo "$line"| awk '{print $1}' | sed 's#quay.io#{repository}#g' )
    img_name_rh=$(echo "$line"| awk '{print $1}' | sed 's#registry.centos.org#{repository}#g' )

# Patterns for sed
    k8s="k8s.gcr.io"
    docker="docker.io"
    quay="quay.io"
    rh="registry.centos.org"

# Tag commands
    if [[ "$line" == *"$docker"* ]];
    then
        podman tag "$img_name_old":"$img_version" "$img_name_docker":"$img_version"
    fi

    if [[ "$line" == *"$quay"* ]];
    then
        podman tag "$img_name_old":"$img_version" "$img_name_quay":"$img_version"
    fi

    if [[ "$line" == *"$rh"* ]];
    then
        podman tag "$img_name_old":"$img_version" "$img_name_rh":"$img_version"
    fi
done

# Push part
podman images | grep harbor | while read -r line; do

# Main environments
    img_name=$(echo "$line"  | awk '{print $1}')
    img_version=$(echo "$line"  | awk '{print $2}')
# Push commands with creds.
    podman login -u {user} -p {password} {repository}
    podman push  "$img_name":"$img_version"
done