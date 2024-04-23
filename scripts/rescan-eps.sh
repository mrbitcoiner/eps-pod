#!/usr/bin/env bash
####################
set -e
####################
readonly EPS_BIN="${HOME}/.local/bin/electrum-personal-server"
readonly EPS_CONFIG="/data/config.ini"
####################
rescan() {
	"${EPS_BIN}" --rescan "${EPS_CONFIG}"
}
####################
rescan
