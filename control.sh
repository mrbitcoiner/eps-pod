#!/usr/bin/env bash
####################
set -e
####################
readonly RELDIR="$(dirname ${0})"
readonly IMAGE_NAME="eps"
####################
eprintln() {
	! [ -z "${1}" ] || eprintln 'eprinln: undefined message'
	printf "${1}\n" 1>&2
	return 1
}
check_env() {
	[ -e "${RELDIR}/.env" ] || eprintln 'you must copy .env.example to .env'
	source "${RELDIR}/.env"
	! [ -z "${CONTAINER_NAME}" ] || eprintln 'undefined env: CONTAINER_NAME'
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
	podman exec -it ${CONTAINER_NAME} /static/scripts/rescan-eps.sh
}
build() {
	podman build \
		-f ${RELDIR}/Containerfile \
		--tag="${IMAGE_NAME}" \
		"${RELDIR}"
}
mk_systemd() {
	! [ -e "/etc/systemd/system/${CONTAINER_NAME}.service" ] \
		|| eprintln "service ${CONTAINER_NAME} already exists"
	local user="${USER}"
	sudo bash -c "cat << EOF > /etc/systemd/system/${CONTAINER_NAME}.service
[Unit]
Description=Electrum Personal Server Pod
After=network.target

[Service]
Environment=\"PATH=/usr/local/bin:/usr/bin:/bin:${PATH}\"
User=${user}
Type=forking
ExecStart=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh up\"
ExecStop=/bin/bash -c \"cd ${PWD}/${RELDIR}; ./control.sh down\"
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF
"
	sudo systemctl enable "${CONTAINER_NAME}".service
}
rm_systemd() {
	[ -e "/etc/systemd/system/${CONTAINER_NAME}.service" ] || return 0
	sudo systemctl stop "${CONTAINER_NAME}".service || true
	sudo systemctl disable "${CONTAINER_NAME}".service
	sudo rm /etc/systemd/system/"${CONTAINER_NAME}".service
}
up() {
	epscfg
	podman run \
		--rm \
		--env-file="${RELDIR}/.env" \
		-v="${RELDIR}/data:/data" \
		-p="${EPS_LISTEN_PORT}:${EPS_LISTEN_PORT}" \
		--name="${CONTAINER_NAME}" \
		"localhost/${IMAGE_NAME}" &
}
down() {
	podman exec -it ${CONTAINER_NAME} /static/scripts/eps-shutdown.sh || true
	podman stop ${CONTAINER_NAME} || true
}
clean() {
	printf 'are you sure? This will delete all container data (Y/n): '
	read v
	[ "${v}" == "Y" ] || eprintln 'abort!'
	rm -rf "${RELDIR}/data"
}
addresses() {
	printf "IPV4: ${EPS_LISTEN_HOST}:${EPS_LISTEN_PORT}\n"
	printf "Onion: $(cat ${RELDIR}/data/tor/eps/hostname):${EPS_LISTEN_PORT}\n"
}
####################
common
case ${1} in
	build) build ;;
	up) up ;;
	down) down ;;
	addresses) addresses ;;
	rescan) rescan ;;
	mk-systemd) mk_systemd ;;
	rm-systemd) rm_systemd ;;
	clean) clean ;;
	*) eprintln 'usage: < build | up | down | addresses | rescan | mk-systemd | rm-systemd | clean | help >' ;;
esac
