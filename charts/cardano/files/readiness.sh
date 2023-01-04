#!/bin/bash

EPOCH='"epoch": ([0-9]*)'
PROGRESS='"syncProgress": "([0-9.]*)"'

{{- if eq .Values.environment.name "mainnet" }}
STR=$(cardano-cli query tip --mainnet)
{{- else }}
STR=$(cardano-cli query tip --testnet-magic {{ include "cardano.networkMagic" . }})
{{- end }}

if [[ "$STR" =~ $PROGRESS ]]; then
  val=${BASH_REMATCH[1]}
  echo "progress = $val"
  if [ "$val" = "100.00" ]; then
    exit 0
  fi
  exit 1
else
  if [[ "$STR" =~ $EPOCH ]]; then
    epoch=${BASH_REMATCH[1]}
    echo "epoch = $epoch"
    exit 0
  fi
fi
exit 1  # not fully synced
