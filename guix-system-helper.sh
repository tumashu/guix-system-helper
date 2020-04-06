#!/bin/bash

set -e

GUIX_GIT_URL="https://github.com/guix-mirror/guix"
GUIX_SUBSTITUTE_URLS="http://141.80.181.40"
GUIX_MAX_SILENT_TIME="200"
GUIX_SYSTEM_CONFIG_DIR=$(dirname "${BASH_SOURCE[0]}")
GUIX_SYSTEM_CONFIG_FILE="${GUIX_SYSTEM_CONFIG_DIR}/guix-system-helper.scm"

GUIX_PULL=""
GUIX_SYSTEM_RECONFIGURE=""

function repeatcmd() {
    set +e
    count=0
    while [ 0 -eq 0 ]
    do
        echo "Run $@ ..."
        $@
        if [ $? -eq 0 ]; then
            break;
        else
            count=$[${count}+1]
            if [ ${count} -eq 100 ]; then
                echo 'Timeout and exit.'
                exit 1;
            fi
            echo "Retry ..."
            sleep 3
        fi
    done
    set -e
}

function guix_pull() {
    repeatcmd guix pull \
              --keep-going \
              --max-silent-time=${GUIX_MAX_SILENT_TIME} \
              --url=${GUIX_GIT_URL} \
              --substitute-urls=${GUIX_SUBSTITUTE_URLS}
}

function guix_system_reconfigure() {
    repeatcmd sudo guix system reconfigure \
              --max-silent-time=${GUIX_MAX_SILENT_TIME} \
              --substitute-urls=${GUIX_SUBSTITUTE_URLS} \
              ${GUIX_SYSTEM_CONFIG_FILE}
}

function display_usage() {
    cat <<HELP
用法: bash ./guix-system-helper.sh [选项]
选项:
    -p, --pull            guix pull
    -r, --reconfigure     guix system reconfigure
HELP
}

function main() {
    while true
    do
        case "$1" in
            -h|--help)
                display_usage;
                exit 0
                ;;
            -p|--pull)
                guix_pull;
                ;;
            -r|--reconfigure)
                guix_system_reconfigure;
                ;;
            *)
                echo "错误的选项！"
                exit 1
        esac
    done
}

# 选项
ARGS=$(getopt -o hpr --long help,pull,reconfigure -n "$0" -- "$@")


if [[ $? != 0 ]]; then
    echo "错误的选项！"
    display_usage
    exit 1
fi

eval set -- "${ARGS}"

main "$@"
