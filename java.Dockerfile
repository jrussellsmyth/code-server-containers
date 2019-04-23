# ============================================================================================
# Java/Maven development environment based on the dockerhub base maven containers
# ============================================================================================
# BUILD WITH 
# docker build -f java.Dockerfile --build-arg JAVA_VERSION={7|8|11|12|13} .
# last successfull build `docker build -t jrussellsmyth/code-server-go -f go.Dockerfile --build-arg GO_VERSION=1.11 .`
# ============================================================================================
ARG JAVA_VERSION=8
FROM maven:3-jdk-${JAVA_VERSION}

RUN apt-get update && apt-get upgrade && apt-get install -y \
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

# language specific extensions extensions
RUN code-server --install-extension vscjava.vscode-java-pack \
  && code-server --install-extension redhat.vscode-xml

# code server default port
EXPOSE 8443
# running project default port
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server"]