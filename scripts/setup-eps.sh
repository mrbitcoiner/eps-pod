#!/usr/bin/env bash
####################
set -e
####################
readonly EPS_LOGFILE='/data/eps.log'
readonly EPS_CERTS_PATH="/data/certs/eps"
####################
gen_certs(){
  ! [ -e "${EPS_CERTS_PATH}" ] || return 0
  mkdir -p "${EPS_CERTS_PATH}"
  cd ${EPS_CERTS_PATH}
  openssl req -nodes -newkey rsa:2048 -keyout server.key -out server.csr -subj "/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=NA"
  openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt
}
set_log() {
	[ -e "${EPS_LOGFILE}" ] || touch "${EPS_LOGFILE}"
	[ -e "/tmp/electrumpersonalserver.log" ] \
	|| ln -s ${EPS_LOGFILE} /tmp/electrumpersonalserver.log
}
setup(){
  gen_certs
	set_log
}
####################
setup
