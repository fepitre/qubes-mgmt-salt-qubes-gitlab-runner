#!/usr/bin/env bash

localdir="$(readlink -f "$(dirname "$0")")"
source $localdir/common.sh

if ! qvm-run-vm -p "$DISPVM_ID" "${1}"; then
    exit "$BUILD_FAILURE_EXIT_CODE"
fi
