#!/bin/bash

set -e

vpn="$1"

function isnt_connected () {
    scutil --nc status "$vpn" | sed -n 1p | grep -qv Connected
}

if isnt_connected "$vpn"; then
  exit 1
else
  exit 0
fi
