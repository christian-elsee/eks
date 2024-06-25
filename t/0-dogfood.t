#!/bin/sh
## Dog food tap.sh

## src
. src/tap.sh

## main

tap_cmp "chow" "chow" "it should expect dog food"
tap_ok "0" "it should consider dog food"
tap_pass "it should eat dog food"
tap_end
