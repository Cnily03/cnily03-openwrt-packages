#!/bin/bash

function usage() {
    echo "Usage: $0 <string> [length] [salt]"
    echo "Note: if length is not specified or illegal, it will output the full hash"
}

str="$1"
length=$2
salt="$3"

[ -z "$str" ] && usage && exit 1

appendix=""
[ -n "$salt" ] && appendix=".$salt"

res=`echo "$str$appendix" | sha256sum | sed 's/[^0-9a-zA-Z]//g'`
if [[ "$length" =~ ^[0-9]+$ ]]; then
    echo "${res:0:$length}"
else
    echo "$res"
fi