#!/bin/bash

IPC=/ipc/node.socket

filter() {
  jq '.stateBefore.esLState.delegationState.pstate."pParams pState"[] | select(.metadata != null)' "$1" | \
    jq -s .
}

vet() {
  bash poolVet.sh "$1" | jq -s .
}

while true;
do
  echo 'checking readiness'
  stat "$IPC"
  result=$?;
  if [ $result -eq 0 ]; then
    {{- if eq .Values.environment.name "testnet" }}
    progress=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r .syncProgress)
    {{- else }}
    progress=$(cardano-cli query tip --mainnet | jq -r .syncProgress)
    {{- end }}
    if [ "$progress" = "100.00" ]; then
      break;
    fi;
  fi;
  echo "...not ready yet; sleeping 3 seconds before retry. Progress = $progress"; >&2
  sleep 3;
done

{{- if eq .Values.environment.name "testnet" }}
cardano-cli query ledger-state --testnet-magic 1097911063 > /p2p/state.json
{{- else }}
cardano-cli query ledger-state --mainnet > /p2p/state.json
{{- end }}

filtered=$(mktemp)
verified=$(mktemp)
filter /p2p/state.json > "$filtered"
vet "$filtered" > "$verified"
jq -s 'flatten | group_by(.publicKey) | map(reduce .[] as $x ({}; . * $x))' "$filtered" "$verified" > /p2p/pools.json

echo 'completed' >&2
