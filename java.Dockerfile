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
	vim 

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
# RUN code-server --install-extension redhat.java \
#   && code-server --install-extension vscjava.vscode-java-debug \
#   && code-server --install-extension vscjava.vscode-java-test \
#   && code-server --install-extension vscjava.vscode-maven

  

  # && code-server --install-extension vscjava.vscode-java-pack \
  # && code-server --install-extension redhat.vscode-xml


# Setup Java Extension
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"


RUN sudo apt-get install -y bsdtar
# RUN mkdir -p ${VSCODE_EXTENSIONS}/redhat.java-latest \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/redhat/vsextensions/java/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java extension

# RUN mkdir -p ${VSCODE_EXTENSIONS}/vscjava.vscode-java-debug-latest \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-debug/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-debugger extension

# RUN mkdir -p ${VSCODE_EXTENSIONS}/java-test \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-test/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/java-test extension

# RUN mkdir -p ${VSCODE_EXTENSIONS}/maven \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-maven/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/maven extension

# RUN mkdir -p ${VSCODE_EXTENSIONS}/vscodeintellicode \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/visualstudioexptteam/vsextensions/vscodeintellicode/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/maven extension

# RUN mkdir -p ${VSCODE_EXTENSIONS}/vscjava.vscode-java-dependency-latest \
#     && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vscjava/vsextensions/vscode-java-dependency/latest/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/maven extension

ENV EXT_VENDOR=redhat EXT_NAME=java EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=vscjava EXT_NAME=vscode-java-debug EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=vscjava EXT_NAME=vscode-java-test EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=vscjava EXT_NAME=vscode-maven EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=visualstudioexptteam EXT_NAME=vscodeintellicode EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=vscjava EXT_NAME=vscode-java-dependency EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension

ENV EXT_VENDOR=pivotal EXT_NAME=vscode-boot-dev-pack EXT_VERSION=latest
RUN mkdir -p ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} \
    && curl -JLs --retry 5 https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${EXT_VENDOR}/vsextensions/${EXT_NAME}/${EXT_VERSION}/vspackage | bsdtar --strip-components=1 -xf - -C ${VSCODE_EXTENSIONS}/${EXT_VENDOR}.${EXT_NAME}-${EXT_VERSION} extension




# code server default port
EXPOSE 8443
# running project default port
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server"]