#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# on startup check for left over files in source directory and add them to the queue
#find /app/source -type f -exec /app/pushsource.sh {} \;

SOURCEQUEUE=${SOURCEQUEUE:-"sourcequeue"}
BLOCKSIZE=${BLOCKSIZE:-100}
NUMPROCESSES=${NUMPROCESSES:-4}
REDISCLI=$(which redis-cli)
TRIM="$(which tr) -d '\n'"

while true; do
	echo "${__base}[${BASHPID}]: blocking wait for source file in the processing queue..."
	SOURCEFILE="$(${REDISCLI} --raw BLPOP ${SOURCEQUEUE} 0 | tr -d '\n')"
	SOURCEFILE="${SOURCEFILE#${SOURCEQUEUE}}"
	echo $SOURCEFILE
	QUEUESIZE=""
	while [[ $QUEUESIZE != "$(${REDISCLI} LLEN ${SOURCEQUEUE})" ]];  do
		QUEUESIZE="$(${REDISCLI} LLEN ${SOURCEQUEUE})"
	        echo "${__base}[${BASHPID}]: waiting for more files"
		sleep 3
	done
	export SOURCELIST="${SOURCEFILE} $(${REDISCLI} --raw -r ${BLOCKSIZE} LPOP ${SOURCEQUEUE} | xargs)"
	echo "${__base}[${BASHPID}]: start processing the following files: ${SOURCELIST}"
	make -C /app -j ${NUMPROCESSES} --output-sync all
	unset SOURCELIST
done

        
