#!/usr/bin/bash

DISPVM_ID="disp-$CUSTOM_ENV_CI_RUNNER_ID-$CUSTOM_ENV_CI_PROJECT_ID-$CUSTOM_ENV_CI_CONCURRENT_PROJECT_ID-$CUSTOM_ENV_CI_JOB_ID"

disp_cleanup() {
    if qvm-check --quiet "$DISPVM_ID"; then
        qvm-shutdown --wait "$DISPVM_ID"
        qvm-remove -f "$DISPVM_ID"
    fi
}

# exit_clean() {
#     local exit_code="$1"
#     disp_cleanup
#     exit "$exit_code"
# }