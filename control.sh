#!/usr/bin/env bash
####################
set -e
####################
readonly RELDIR="$(dirname ${0})"
####################
eprintln() {
	! [ -z "${1}" ] || eprintln 'eprinln: undefined message'
	printf "${1}\n" 1>&2
	return 1
}
check_env() {
	[ -e "${RELDIR}/.env" ] || eprintln 'you must copy .env.example to .env'
	source "${RELDIR}/.env"
	! [ -z "${BITCOIND_EPS_WALLET_NAME}" ] || eprintln 'undefined env: BITCOIND_EPS_WALLET_NAME'
	! [ -z "${BITCOIND_RPC_USER}" ] || eprintln 'undefined env: BITCOIND_RPC_USER'
	! [ -z "${BITCOIND_RPC_PASSWORD}" ] || eprintln 'undefined env: BITCOIND_RPC_PASSWORD'
	! [ -z "${BITCOIND_RPC_HOST}" ] || eprintln 'undefined env: BITCOIND_RPC_HOST'
	! [ -z "${BITCOIND_RPC_PORT}" ] || eprintln 'undefined env: BITCOIND_RPC_PORT'
	! [ -z "${EPS_RESCAN}" ] || eprintln 'undefined env: EPS_RESCAN'
	! [ -z "${EPS_LISTEN_HOST}" ] || eprintln 'undefined env: EPS_LISTEN_HOST'
	! [ -z "${EPS_LISTEN_PORT}" ] || eprintln 'undefined env: EPS_LISTEN_PORT'
}
epscfg() {
	[ -e "${RELDIR}/config.ini" ] \
	|| eprintln 'you must copy config.ini.example to config.int and add your wallet configuration'
	"${RELDIR}/scripts/setup-epsconfig.sh"
}
common() {
	mkdir -p "${RELDIR}/data"
	chmod +x "${RELDIR}/scripts"/*.sh
	check_env
}
rescan() {
	podman exec -it eps /static/scripts/rescan-eps.sh
}
build() {
	common
	podman build \
		-f ${RELDIR}/Containerfile \
		--tag="eps" \
		"${RELDIR}"
}
up() {
	common
	epscfg
	podman run \
		--rm \
		--env-file="${RELDIR}/.env" \
		-v="${RELDIR}/data:/data" \
		-p="${EPS_LISTEN_PORT}:${EPS_LISTEN_PORT}" \
		--name="eps" \
		"localhost/eps" &
}
down() {
	podman exec -it eps /static/scripts/eps-shutdown.sh || true
	podman stop eps
}
clean() {
	printf 'are you sure? This will delete all container data (Y/n): '
	read v
	[ "${v}" == "Y" ] || eprintln 'abort!'
	rm -rf "${RELDIR}/data"
}
addresses() {
	common
	printf "IPV4: ${EPS_LISTEN_HOST}:${EPS_LISTEN_PORT}\n"
	printf "Onion: $(cat ${RELDIR}/data/tor/eps/hostname):${EPS_LISTEN_PORT}\n"
}
####################
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	addresses) addresses ;;
	rescan) rescan ;;
	clean) clean ;;
	*) eprintln 'usage: < build | up | down | addresses | rescan | clean | help >' ;;
esac
