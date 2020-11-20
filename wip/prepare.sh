#!/usr/bin/bash

localdir="$(readlink -f "$(dirname "$0")")"
source $localdir/common.sh

set -eo pipefail

trap "exit $SYSTEM_FAILURE_EXIT_CODE" ERR

/usr/bin/python3.8 - <<-EOF
import qubesadmin
app = qubesadmin.Qubes()
app.add_new_vm("DispVM", "$DISPVM_ID", "red", "gitlab-ci-runner")
EOF

qvm-start "$DISPVM_ID"