# ============================================================================================
# GOLANG development environment based on the dockerhub base golang containers
# ============================================================================================
# BUILD WITH 
# docker build -f go.Dockerfile --build-arg GO_VERSION={version} .
# last successfull build `docker build -t jrussellsmyth/code-server-go -f go.Dockerfile --build-arg GO_VERSION=1.11 .`
# ============================================================================================
ARG GO_VERSION=latest
FROM golang:${GO_VERSION}

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	net-tools \
	sudo \
	dumb-init \
	vim 

# docker and docker dependencies - we will need these if we want to build docker containers
RUN sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common 
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - 
RUN sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" 
RUN sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io 

# Get the code-server binary 
ARG CODE_SERVER_VERSION=1.939-vsc1.33.1
RUN curl -L https://github.com/codercom/code-server/releases/download/${CODE_SERVER_VERSION}/code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz | tar xzv  -f - --strip-components=1 -C /usr/local/bin/ "code-server${CODE_SERVER_VERSION}-linux-x64/code-server"

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN sudo usermod -aG docker coder

USER coder
# We create first instead of just using WORKDIR as when WORKDIR creates, the user is root.
RUN mkdir -p /home/coder/project && \
    chmod g+rw /home/coder/project;

WORKDIR /home/coder/project

# This assures we have a volume mounted even if the user forgot to do bind mount.
# XXX: Workaround for GH-459 and for OpenShift compatibility.
VOLUME [ "/home/coder/project" ]


# language specific configuration
# Temporarily set gopath for tools install
ENV GOPATH /home/coder/.goTools
RUN mkdir -p /home/coder/.goTools \
	&& go get -u -v github.com/ramya-rao-a/go-outline \
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

# Set gopath for development
ENV GOPATH /home/coder/project
ENV PATH $GOPATH/bin:$PATH

# Preconfigured settings for go extension
RUN mkdir -p /home/coder/.local/share/code-server/User && chmod g+rw /home/coder/.local/share/code-server/User
COPY ./go-resources/user-settings.json /home/coder/.local/share/code-server/User/settings.json

# language specific extensions extensions
RUN code-server --install-extension ms-vscode.go

# code server default port
EXPOSE 8443
# running project default port
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server"]