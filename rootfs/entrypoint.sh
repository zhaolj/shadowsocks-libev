#!/bin/bash

SS_CONFIG=${SS_CONFIG:-""}
SS_MODULE=${SS_MODULE:-"ss-local"}
KCP_CONFIG=${KCP_CONFIG:-""}
KCP_MODULE=${KCP_MODULE:-"kcpclient"}
KCP_FLAG=${KCP_FLAG:-"false"}
PXY_FLAG=${PXY_FLAG:-"false"}

while getopts "s:b:k:j:x:y" OPT; do
    case $OPT in
        s)
            SS_CONFIG=$OPTARG;;
        b)
            SS_MODULE=$OPTARG;;
        k)
            KCP_CONFIG=$OPTARG;;
        j)
            KCP_MODULE=$OPTARG;;
        x)
            KCP_FLAG="true";;
        y)
            PXY_FLAG="true";;
    esac
done

export SS_CONFIG=${SS_CONFIG}
export SS_MODULE=${SS_MODULE}
export KCP_CONFIG=${KCP_CONFIG}
export KCP_MODULE=${KCP_MODULE}
export KCP_FLAG=${KCP_FLAG}
export PXY_FLAG=${PXY_FLAG}

exec runsvdir -P /etc/service
