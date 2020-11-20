#!/usr/bin/env bash

localdir="$(readlink -f "$(dirname "$0")")"
source $localdir/common.sh

# trap 'exit_clean' 0 1 2 3 6 15

disp_cleanup