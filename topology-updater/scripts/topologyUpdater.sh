#!/bin/bash -x
# shellcheck disable=SC2086,SC2034
# shellcheck source=/dev/null
# curl --fail-with-body requires v7.76+

# Description : Helper function to validate that input is a number
#             : $1 = number
isNumber() {
  [[ -z $1 ]] && return 1
  [[ $1 =~ ^[0-9]+$ ]] && return 0 || return 1
}

# Description : Helper function to validate IPv4 address
#             : $1 = IP
isValidIPv4() {
  local ip=$1
  [[ -z ${ip} ]] && return 1
  if [[ ${ip} =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$ || ${ip} =~ ^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then 
    return 0
  fi
  return 1
}

# Description : Helper function to validate IPv6 address, works for normal IPv6 addresses, not dual incl IPv4
#             : $1 = IP
isValidIPv6() {
  local ip=$1
  [[ -z ${ip} ]] && return 1
  ipv6_regex="^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$"
  [[ ${ip} =~ ${ipv6_regex} ]] && return 0
  return 1
}

usage() {
  cat <<-EOF
		Usage: $(basename "$0") [-f] [-p]
		Topology Updater - Build topology with community pools
		-f    Disable fetch of a fresh topology file
		-p    Disable node alive push to Topology Updater API
		
		EOF
  exit 1
}

REDIS_USER=${REDIS_USER:-cardano}
REDIS_HOST=${REDIS_HOST:-localhost}
REDIS_PORT=${REDIS_PORT:-6379}
IP_VERSION=${IP_VERSION:-4}
TOPOLOGY=$(mktemp)
TOPIC=${TOPIC:-topology}
TU_FETCH='Y'
TU_PUSH='Y'

while getopts :fpo: opt; do
  case ${opt} in
    f ) TU_FETCH='N' ;;
    p ) TU_PUSH='N' ;;
    \? ) usage ;;
  esac
done
shift $((OPTIND -1))


# Check if old style CUSTOM_PEERS with colon separator is used, if so convert to use commas
if [[ -n ${CUSTOM_PEERS} && ${CUSTOM_PEERS} != *","* ]]; then
  CUSTOM_PEERS=${CUSTOM_PEERS//[:]/,}
fi

if [[ ${TU_PUSH} = "Y" ]]; then
  fail_cnt=0
  while ! blockNo=$(curl -s -f -m ${EKG_TIMEOUT} "http://${EKG_HOST}:${EKG_PORT}/metrics" 2>/dev/null | grep cardano_node_metrics_blockNum_int | head -n1 | cut -f 2 -d ' ' ); do
    ((fail_cnt++))
    [[ ${fail_cnt} -eq 5 ]] && echo "5 consecutive EKG queries failed, aborting!"
    echo "(${fail_cnt}/5) Failed to grab blockNum from node EKG metrics, sleeping for 30s before retrying... (ctrl-c to exit)"
    sleep 30
  done
fi

if [[ ${TU_PUSH} = "Y" ]]; then
  if [[ ${IP_VERSION} = "4" || ${IP_VERSION} = "mix" ]]; then
    curl -s -f -4 "https://api.clio.one/htopology/v1/?port=${CNODE_PORT}&blockNo=${blockNo}&magic=${NWMAGIC}"
  fi
  if [[ ${IP_VERSION} = "6" || ${IP_VERSION} = "mix" ]]; then
    curl -s -f -6 "https://api.clio.one/htopology/v1/?port=${CNODE_PORT}&blockNo=${blockNo}&magic=${NWMAGIC}"
  fi
fi
if [[ ${TU_FETCH} = "Y" ]]; then
  if [[ ${IP_VERSION} = "4" || ${IP_VERSION} = "mix" ]]; then
    curl -s --fail-with-body -4 -o "${TOPOLOGY}" "https://api.clio.one/htopology/v1/fetch/?max=${MAX_PEERS}&magic=${NWMAGIC}&ipv=${IP_VERSION}"
  else
    curl -s --fail-with-body -6 -o "${TOPOLOGY}" "https://api.clio.one/htopology/v1/fetch/?max=${MAX_PEERS}&magic=${NWMAGIC}&ipv=${IP_VERSION}"
  fi
  if [[ -n "${CUSTOM_PEERS}" ]]; then
    topo="$(cat "${TOPOLOGY}")"
    IFS='|' read -ra cpeers <<< "${CUSTOM_PEERS}"
    for cpeer in "${cpeers[@]}"; do
      IFS=',' read -ra cpeer_attr <<< "${cpeer}"
      case ${#cpeer_attr[@]} in
        2) addr="${cpeer_attr[0]}"
           port=${cpeer_attr[1]}
           valency=1 ;;
        3) addr="${cpeer_attr[0]}"
           port=${cpeer_attr[1]}
           valency=${cpeer_attr[2]} ;;
        *) echo "ERROR: Invalid Custom Peer definition '${cpeer}'. Please double check CUSTOM_PEERS definition"
           exit 1 ;;
      esac
      if [[ ${addr} = *.* ]]; then
        ! isValidIPv4 "${addr}" && echo "ERROR: Invalid IPv4 address or hostname '${addr}'. Please check CUSTOM_PEERS definition" && continue
      elif [[ ${addr} = *:* ]]; then
        ! isValidIPv6 "${addr}" && echo "ERROR: Invalid IPv6 address '${addr}'. Please check CUSTOM_PEERS definition" && continue
      fi
      ! isNumber ${port} && echo "ERROR: Invalid port number '${port}'. Please check CUSTOM_PEERS definition" && continue
      ! isNumber ${valency} && echo "ERROR: Invalid valency number '${valency}'. Please check CUSTOM_PEERS definition" && continue
      topo=$(jq '.Producers += [{"addr": $addr, "port": $port|tonumber, "valency": $valency|tonumber}]' --arg addr "${addr}" --arg port ${port} --arg valency ${valency} <<< "${topo}")
    done
  fi
  redis-cli -h "${REDIS_HOST}" -p "${REDIS_PORT}" PUBLISH "${TOPIC}" "${topo}"
fi
exit 0
