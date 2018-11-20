#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

REDISCLI=$(which redis-cli)
SOURCEFILE="${1:-}"

echo "${__base}[${BASHPID}]: adding source file ${SOURCEFILE} to the processing queue"
echo "RPUSH sourcequeue ""${SOURCEFILE}""" | ${REDISCLI} > /dev/null
