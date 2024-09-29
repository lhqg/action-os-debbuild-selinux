# syntax=docker/dockerfile:1
# see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DISTRIBUTION=ubuntu:latest
ARG PLATFORM=amd64

FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}

# set the environment variables that gha sets
ENV INPUT_DISTRIBUTION="${DISTRIBUTION}"
ENV INPUT_PLATFORM="${PLATFORM}"
ENV INPUT_RESULT_DIR="artifacts"

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY optional
ENV DEBCONF_NOWARNINGS yes

# Install build environment
RUN apt-get update
RUN apt-get -y install selinux-basics selinux-policy-dev policycoreutils build-essential debhelper dh-make devscripts

COPY ./build.sh .

RUN chmod u+x build.sh

# Script to execute when the docker container starts up
ENTRYPOINT ["bash", "/build.sh"]
