#!/bin/bash

# $0 [length] --hash

function usage() {
    echo "Usage: $0 [length] [options]"
    echo "Note: Default length is 16"
    echo "Options:"
    echo "    --type                           Use hash instead of random string"
    echo "    -h, --help                       Show this help message"
}

length=16
type="basic"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --type)
            if [[ "$2" =~ -.* ]] || [[ -z "$2" ]]; then
                echo "Missing argument for $1"
                exit 1
            fi
            type="$2"
            shift
            ;;
        -*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                length=$1
            else
                echo "Unknown argument \"$1\""
            fi
            shift
            ;;
    esac
done

function ceil_sub() {
    local dividend=$1
    local divisor=$2
    local mod=$((dividend % divisor))
    local res=$((dividend / divisor))
    [ $mod -gt 0 ] && res=$((res + 1))
    echo $res
}

function gen_basic() {
    local len=$1
    local res=""
    while [ "${#res}" -lt "$len" ]; do
        res="${res}$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9')"
    done
    echo "${res:0:$len}"
}

function gen_bytes() {
    local len=$1
    local res=$(openssl rand -base64 $len)
    echo "${res}"
}

function gen_hex() {
    local len=$1
    local res=$(openssl rand -hex $len)
    echo "${res}"
}

function gen_base64() {
    local len=$1
    local res=$(openssl rand -base64 $len)
    echo "${res}"
}

case "$type" in
    basic)
        gen_basic $length
        ;;
    byte|bytes)
        gen_bytes $length
        ;;
    hex|hash)
        gen_hex $length
        ;;
    base64)
        gen_base64 $length
        ;;
    *)
        echo "Unknown type \"$type\""
        exit 1
        ;;
esac