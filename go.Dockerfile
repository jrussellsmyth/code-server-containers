# ============================================================================================
# GOLANG development environment based on the dockerhub base golang containers
# ============================================================================================
# BUILD WITH 
# docker build -f go.Dockerfile --build-arg GO_VERSION={version} .
# last successfull build `docker build -t jrussellsmyth/code-server-go -f go.Dockerfile --build-arg GO_VERSION=1.11 .`
# ============================================================================================

ARG GO_VERSION=latest
# skip the build, grab the bin from another build. alt is get from the tarfile
FROM jrussellsmyth/code-server:latest as base 

FROM golang:${GO_VERSION}

RUN apt-get update && apt-get install -y \
	net-tools \
	sudo \
	dumb-init \
	vim 

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

ENV GOPATH /home/coder/project
ENV PATH $GOPATH/bin:$PATH



EXPOSE 8443

ENTRYPOINT ["dumb-init", "code-server"]

