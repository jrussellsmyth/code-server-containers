# ============================================================================================
# Java/Maven development environment based on the dockerhub base maven containers
# ============================================================================================
# BUILD WITH 
# docker build [-t {tag}] -f java.Dockerfile --build-arg JAVA_VERSION={7|8|11|12|13} .
# ============================================================================================
ARG JAVA_VERSION=8
FROM maven:3-jdk-${JAVA_VERSION}

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	net-tools \
	sudo \
	dumb-init \
	vim \
  bsdtar

# docker and docker dependencies - we will need these if we want to build docker containers
RUN apt-get install -y \
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

COPY ./base-resources/install-marketplace-extension /usr/local/bin/install-marketplace-extension
RUN sudo chmod a+x /usr/local/bin/install-marketplace-extension

RUN adduser --gecos '' --disabled-password coder && \
	echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN sudo usermod -aG docker coder

# JAVA sources
# see https://github.com/redhat-developer/vscode-java/issues/689#
#
RUN apt-get install -y openjdk-11-source
RUN cd /usr/lib/jvm/java-11-openjdk-amd64 && rm src.zip && ln -s ../openjdk-11/lib/src.zip

# Install tomcat 8 and 9
RUN curl -JLs --retry 5 http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz | sudo tar xzvf - -C /usr/local/lib
RUN curl -JLs --retry 5 http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.19/bin/apache-tomcat-9.0.19.tar.gz | sudo tar xzvf - -C /usr/local/lib

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
# RUN code-server --install-extension redhat.java \
#   && code-server --install-extension vscjava.vscode-java-debug \
#   && code-server --install-extension vscjava.vscode-java-test \
#   && code-server --install-extension vscjava.vscode-maven
#   && code-server --install-extension vscjava.vscode-java-pack \
#   && code-server --install-extension redhat.vscode-xml

# Setup Java Extension
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"

# Java
RUN install-marketplace-extension redhat java latest \
&& install-marketplace-extension vscjava vscode-java-debug latest \
&& install-marketplace-extension vscjava vscode-java-test latest \
&& install-marketplace-extension vscjava vscode-maven latest \
&& install-marketplace-extension visualstudioexptteam vscodeintellicode latest \
&& install-marketplace-extension vscjava vscode-java-dependency latest 
# Spring
RUN install-marketplace-extension pivotal vscode-spring-boot \
&& install-marketplace-extension pivotal vscode-manifest-yaml \
&& install-marketplace-extension pivotal vscode-concourse \
&& install-marketplace-extension vscjava vscode-spring-initializr \
&& install-marketplace-extension vscjava vscode-spring-boot-dashboard 

# code server default port
EXPOSE 8443
# running project default port
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server"]