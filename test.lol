#!/bin/bash -e
lxcinfo=$(lxc-info $1 | grep "State\:" | awk ' BEGIN { FS = "          " } ; { print $2 }')
if [[ $lxcinfo = "RUNNING" ]]; then
    echo "lol"
fi
