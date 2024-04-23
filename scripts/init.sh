#!/usr/bin/env bash
####################
set -e
####################
EPS_BIN="${HOME}/.local/bin/electrum-personal-server"
EPS_CONFIG="/data/config.ini"
####################
log() {
	! [ -z "${1}" ] || eprintln 'undefined log message'
	local loglvl="LOG"
	[ -z "${2}" ] || local loglvl="ERR"
	printf "[$(date +%F_%H-%M-%S)] | ${loglvl} | ${1}\n"
}
start_tor() {
	/static/scripts/setup-tor.sh
	tor 1>/dev/null &
}
start_eps() {
	/static/scripts/setup-eps.sh
	[ "${EPS_RESCAN}" == "disabled" ] \
	|| (\
		log 'started in rescan mode (call ./control.sh rescan)' \
		&& tail -f /dev/null \
	)

	"${EPS_BIN}" "${EPS_CONFIG}" 1>/dev/null &
	local eps_pid="${!}"
	printf "${eps_pid}" > /data/eps.pid
	tail -f /data/eps.log &
	while kill -0 "${eps_pid}" 1>/dev/null 2>&1; do
		sleep 1
	done
}
init() {
	log 'starting eps pod'
	start_tor
	start_eps || tail -f /dev/null
}
####################
init
