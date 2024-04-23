#!/usr/bin/env bash
####################
set -e
####################
readonly TOR_DIR="/data/tor/eps"
####################
set_torrc() {
	[ -e "${TOR_DIR}" ] || (\
		mkdir -p "${TOR_DIR}" \
		&& chmod 700 "${TOR_DIR}" \
	)
	cat << EOF >> /etc/tor/torrc
HiddenServiceDir ${TOR_DIR}
HiddenServicePort ${EPS_LISTEN_PORT} ${EPS_LISTEN_HOST}:${EPS_LISTEN_PORT}
EOF
}
####################
setup() {
	set_torrc
}
####################
setup
