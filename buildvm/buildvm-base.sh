#!/usr/bin/env bash

export SCRIPT_PATH=$(dirname $(readlink -f "$0"))

export VMNAME=${1:-"dev-${OS_USERNAME}"}
export FLAVOR=${FLAVOR:-"l1.small"}
export DISKSIZE=${DISKSIZE:-false}
export SECGROUPS=${SECGROUPS:-"Management,Diagnostics"}
export NETWORK=${NETWORK:-"Public Internet"}
export KEYNAME=${KEYNAME:-$(openstack keypair list -f value | head -n1 | awk '{ print $1 }')}

function buildvm {
    export IMAGE_ID=$(openstack image list -f value | grep "${IMAGE}" | tail -n1 | awk '{ print $1 }')
    export NET_ID=$(openstack network list -f value | grep "${NETWORK}" | tail -n1 | awk '{ print $1 }')

    export CLOUD_CONFIG_DIR="$SCRIPT_PATH"
    #export CLOUD_CONFIG="cloud-config.txt"
    export CC="${CLOUD_CONFIG_DIR}/${CLOUD_CONFIG}"

    echo "Building $FLAVOR with ${DISKSIZE}GB root disk using ${IMAGE_ID} ${IMAGE}"
    echo "Network is set to ${NET_ID} ${NETWORK}"

    if [[ "${DISKSIZE}" = false ]]; then
    BDM="--image ${IMAGE_ID}"
    else
    BDM="--block-device source=image,id=${IMAGE_ID},dest=volume,size=${DISKSIZE},shutdown=remove,bootindex=0"
    fi

    nova boot \
    --poll \
    --flavor "${FLAVOR}" \
    --key-name "${KEYNAME}" \
    --user-data "${CC}" \
    --security-groups "${SECGROUPS}" \
    $BDM \
    --nic "net-id=${NET_ID}" \
    $VMNAME
}
