#!/usr/bin/env bash
####################
set -e
####################
readonly EPS_DATA="${HOME}/eps"
readonly EPS_BIN="${HOME}/.local/bin/electrum-personal-server"
readonly EPS_GIT_REPO='https://github.com/chris-belcher/electrum-personal-server'
readonly EPS_COMMIT_VERSION='c28a90f366039bc23a01a048348c0cee84b710c4'
####################
clone(){
	! [ -e "${EPS_DATA}/repo" ] || return 0
  git clone ${EPS_GIT_REPO} ${EPS_DATA}/repo
  cd ${EPS_DATA}/repo && \
  git checkout ${EPS_COMMIT_VERSION}
}
install(){
	! [ -e "${EPS_BIN}" ] || return 0
  cd ${EPS_DATA}/repo && \
    pip3 install --user . --break-system-packages --no-warn-script-location
}
setup(){
  clone
  install
}
####################
setup

