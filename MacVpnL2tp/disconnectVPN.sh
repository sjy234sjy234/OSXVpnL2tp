#!/bin/bash

set -e

vpn="$1"

scutil --nc stop "$vpn"
