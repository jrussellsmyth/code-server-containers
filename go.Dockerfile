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

# go tools for go extension
RUN mkdir -p /home/coder/.goTools
ENV GOPATH /home/coder/.goTools
RUN go get -u -v github.com/ramya-rao-a/go-outline \
	github.com/acroca/go-symbols \
	github.com/mdempsky/gocode \
	github.com/rogpeppe/godef \
	golang.org/x/tools/cmd/godoc \
	github.com/zmb3/gogetdoc \
	golang.org/x/lint/golint \
	github.com/fatih/gomodifytags \
	golang.org/x/tools/cmd/gorename \
	sourcegraph.com/sqs/goreturns \
	golang.org/x/tools/cmd/goimports \
	github.com/cweill/gotests/... \
	golang.org/x/tools/cmd/guru \
	github.com/josharian/impl \
	github.com/haya14busa/goplay/cmd/goplay \
	github.com/uudashr/gopkgs/cmd/gopkgs \
	github.com/davidrjenni/reftools/cmd/fillstruct \
	github.com/tylerb/gotype-live \
	golang.org/x/tools/cmd/gopls \
	github.com/alecthomas/gometalinter \
	github.com/go-delve/delve/cmd/dlv \
	&& $GOPATH/bin/gometalinter --install

# Preconfigured settings for go extension
RUN mkdir -p /home/coder/.local/share/code-server/User && chmod g+rw /home/coder/.local/share/code-server/User
COPY ./go-resources/user-settings.json /home/coder/.local/share/code-server/User/settings.json

# instal go extension
RUN code-server --install-extension ms-vscode.go

ENV GOPATH /home/coder/project
ENV PATH $GOPATH/bin:$PATH

EXPOSE 8443

ENTRYPOINT ["dumb-init", "code-server"]

