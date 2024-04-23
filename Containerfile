FROM docker.io/library/debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN \
	set -e; \
	apt update; \
	apt install -y --no-install-recommends \
	git python3 python3-pip tor

COPY scripts /static/scripts

RUN \
	set -e; \
	/static/scripts/build-eps.sh

ENTRYPOINT ["/static/scripts/init.sh"]
