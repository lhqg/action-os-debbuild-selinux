# syntax=docker/dockerfile:1
# see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DISTRIBUTION=ubuntu
ARG DISTRO_VERSN=latest
ARG PLATFORM=amd64

FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}:${DISTRO_VERSN}

# set the environment variables that gha sets
ENV INPUT_BUILDROOT=""
ENV INPUT_PKG_VERSION=""
ENV INPUT_OUTPUT_DIR="artifacts"
ENV INPUT_SIGNING_KEY_NAME=""
ENV INPUT_SIGNING_KEY_ID=""
ENV INPUT_SIGNING_KEY_FILE=""

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=optional
ENV DEBCONF_NOWARNINGS=yes

# Install build environment
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
	selinux-basics selinux-policy-dev policycoreutils \
	build-essential debhelper dh-make devscripts

COPY ./build.sh .

RUN chmod u+x build.sh

# Script to execute when the docker container starts up
ENTRYPOINT ["bash", "/build.sh"]
