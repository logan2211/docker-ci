#!/bin/bash

set -e

SYNC_INTERVAL="${SYNC_INTERVAL:-60}"
CONFIGMAP_REVISION=0
KUBE_CACERT_PATH=/run/secrets/kubernetes.io/serviceaccount/ca.crt
KUBE_TOKEN="$(cat /run/secrets/kubernetes.io/serviceaccount/token)"
KUBE_NAMESPACE="$(cat /run/secrets/kubernetes.io/serviceaccount/namespace)"
IPTABLES_RULES_CONFIGMAP="${IPTABLES_RULES_CONFIGMAP:-iptables-rules}"

declare -A CHECKSUMS

declare -A UPDATE_CMD=(
    ["rules.v4"]="iptables-restore"
    ["rules.v6"]="ip6tables-restore"
)

function check_sync_configmap {
    echo "Beginning iptables sync run"
    NEWREV=$(
        curl ${IPTABLES_CURL_OPTIONS:-} \
            -s --cacert "${KUBE_CACERT_PATH}" \
            -H "Authorization: Bearer ${KUBE_TOKEN}" \
            -H 'Accept: application/json' \
            "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/${KUBE_NAMESPACE}/configmaps/${IPTABLES_RULES_CONFIGMAP}" | \
        jq .metadata.resourceVersion -r
    )

    if [[ -z "$NEWREV" ]]; then
        echo "Failed to get configmap revision"
        return
    fi

    if [[ "$CONFIGMAP_REVISION" -ne "$NEWREV" ]]; then
        echo "Configmap revision changed from ${CONFIGMAP_REVISION} to $NEWREV"
        # Revision changed, sync rules
        sync_configmap_rules rules.v4
        sync_configmap_rules rules.v6
        CONFIGMAP_REVISION=$NEWREV
    fi
}

function sync_configmap_rules {
    echo "Running sync for $1 from ${IPTABLES_RULES_CONFIGMAP}"
    local _RULES=$(curl ${IPTABLES_CURL_OPTIONS:-} \
            -s --cacert "${KUBE_CACERT_PATH}" \
            -H "Authorization: Bearer ${KUBE_TOKEN}" \
            -H 'Accept: application/json' \
            "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}/api/v1/namespaces/${KUBE_NAMESPACE}/configmaps/${IPTABLES_RULES_CONFIGMAP}" | \
        jq ".[\"data\"][\"${1}\"]" -r)
    if [ -z "$_RULES" ]; then
        return
    fi

    local _CHECKSUM="$(echo -n \"${_RULES}\" | md5sum - | awk '{ print $1 }')"

    if [[ "$_CHECKSUM" == "${CHECKSUMS[$1]}" ]]; then
        echo "No changes found"
        return
    fi

    # The rules have been updated
    echo "Rules have been updated. Old checksum: ${CHECKSUMS[$1]}, new checksum: $_CHECKSUM"
    echo "$_RULES" > "/tmp/$1"
    if [ -d "/host/iptables" ]; then
        echo "Found host mount, writing rules to host"
        echo "$_RULES" > "/host/iptables/$1"
    fi
    # TODO(logan): Find a way to apply the ruleset without flushing existing
    # rules. --noflush unfortunately creates duplicate rules
    if [ -n "${UPDATE_CMD[$1]}" ]; then
        echo "$_RULES" | ${UPDATE_CMD[$1]}
    fi
    CHECKSUMS[$1]="$_CHECKSUM"
}

while true; do
    check_sync_configmap
    echo "Sync complete. Sleeping for $SYNC_INTERVAL"
    sleep "$SYNC_INTERVAL"
done
