#!/bin/sh
## Smoke test orchestrated cluster

## fd
2>/dev/null >&3 || exec 3>/dev/null

## src
. src/tap.sh

## main

kubectl get nodes --kubeconfig dist/kubeconfig
tap_ok "$?" "it should work with kubectl"
tap_end

