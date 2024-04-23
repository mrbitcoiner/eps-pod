#!/usr/bin/env bash
####################
set -e
####################
shutdown() {
	kill -15 "$(cat /data/eps.pid)"
}
####################
shutdown
