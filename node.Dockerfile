# ============================================================================================
# node.js development environment based on the dockerhub base node containers
# ============================================================================================
# BUILD WITH 
# docker build -f node.base.Dockerfile --build-arg NODE_VERSION={version} .
# ============================================================================================

ARG NODE_VERSION=latest
# skip the build, grab the bin from another build. alt is get from the tarfile
FROM jrussellsmyth/code-server:latest as base 

FROM node:${NODE_VERSION}

RUN apt-get update && apt-get upgrade && apt-get install -y \
	net-tools \
	locales \
	sudo \
	dumb-init \
	vim 

RUN locale-gen en_US.UTF-8
# We unfortunately cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.
ENV LC_ALL=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

USER coder
# We create first instead of just using WORKDIR as when WORKDIR creates, the user is root.
RUN mkdir -p /home/coder/project && \
    chmod g+rw /home/coder/project;

WORKDIR /home/coder/project

# This assures we have a volume mounted even if the user forgot to do bind mount.
# XXX: Workaround for GH-459 and for OpenShift compatibility.
VOLUME [ "/home/coder/project" ]

# get code-server binary from built docker 
COPY --from=base /usr/local/bin/code-server /usr/local/bin/code-server

EXPOSE 8443

ENTRYPOINT ["dumb-init", "code-server"]




