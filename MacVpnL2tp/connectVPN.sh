#!/bin/bash

# Call with <script> "<VPN Connection Name>"

set -e
#set -x

vpn="$1"

function isnt_connected () {
    scutil --nc status "$vpn" | sed -n 1p | grep -qv Connected
}

function poll_until_connected () {
    let loops=0 || true
    let max_loops=150 # 200 * 0.1 is 20 seconds. Bash doesn't support floats

    while isnt_connected "$vpn"; do
        sleep 0.1 # can't use a variable here, bash doesn't have floats
        let loops=$loops+1
        [ $loops -gt $max_loops ] && break
    done

    [ $loops -le $max_loops ]
}

scutil --nc start "$vpn"

if poll_until_connected "$vpn"; then
    exit 0
else
    echo "Failed to connect to $vpn!"
    exit 1
fi
