# ============================================================================================
# Java 11/Maven development environment based on the dockerhub base maven containers
# ============================================================================================
# BUILD WITH 
# docker build [-t {tag}] -f java.Dockerfile 
# ============================================================================================
FROM jrussellsmyth/code-server-base

# ============================================================================================
# ============================================================================================
# jdk
# ============================================================================================
# ============================================================================================
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM buildpack-deps:stretch-scm

# A few reasons for installing distribution-provided OpenJDK:
#
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#     really hairy.
#
#     For some sample build times, see Debian's buildd logs:
#       https://buildd.debian.org/status/logs.php?pkg=openjdk-11

RUN apt-get update && apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils \
	&& rm -rf /var/lib/apt/lists/*

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

# do some fancy footwork to create a JAVA_HOME that's cross-architecture-safe
RUN ln -svT "/usr/lib/jvm/java-11-openjdk-$(dpkg --print-architecture)" /docker-java-home
ENV JAVA_HOME /docker-java-home

ENV JAVA_VERSION 11.0.3
ENV JAVA_DEBIAN_VERSION 11.0.3+1-1~bpo9+1

RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
# ca-certificates-java does not work on src:openjdk-11 with no-install-recommends: (https://bugs.debian.org/914860, https://bugs.debian.org/775775)
# /var/lib/dpkg/info/ca-certificates-java.postinst: line 56: java: command not found
	ln -svT /docker-java-home/bin/java /usr/local/bin/java; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		openjdk-11-jdk="$JAVA_DEBIAN_VERSION" \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	rm -v /usr/local/bin/java; \
	\
# ca-certificates-java does not work on src:openjdk-11: (https://bugs.debian.org/914424, https://bugs.debian.org/894979, https://salsa.debian.org/java-team/ca-certificates-java/commit/813b8c4973e6c4bb273d5d02f8d4e0aa0b226c50#d4b95d176f05e34cd0b718357c532dc5a6d66cd7_54_56)
	keytool -importkeystore -srckeystore /etc/ssl/certs/java/cacerts -destkeystore /etc/ssl/certs/java/cacerts.jks -deststoretype JKS -srcstorepass changeit -deststorepass changeit -noprompt; \
	mv /etc/ssl/certs/java/cacerts.jks /etc/ssl/certs/java/cacerts; \
	/var/lib/dpkg/info/ca-certificates-java.postinst configure; \
	\
# verify that "docker-java-home" returns what we expect
	[ "$(readlink -f "$JAVA_HOME")" = "$(docker-java-home)" ]; \
	\
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'


# ============================================================================================
# ============================================================================================
# maven
# ============================================================================================
# ============================================================================================

ARG MAVEN_VERSION=3.6.1
ARG USER_HOME_DIR="/root"
ARG SHA=b4880fb7a3d81edd190a029440cdf17f308621af68475a4fe976296e71ff4a4b546dd6d8a58aaafba334d309cc11e638c52808a4b0e818fc0fd544226d952544
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

# Maven fails with 'Can't read cryptographic policy directory: unlimited'
# because it looks for $JAVA_HOME/conf/security/policy/unlimited but it is in
# /etc/java-9-openjdk/security/policy/unlimited
RUN ln -s /etc/java-11-openjdk /usr/lib/jvm/java-11-openjdk-$(dpkg --print-architecture)/conf

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/
# ============================================================================================
# ============================================================================================




# JAVA sources
RUN apt-get install -y openjdk-11-source
RUN cd /usr/lib/jvm/java-11-openjdk-amd64 && rm src.zip && ln -s ../openjdk-11/lib/src.zip

# Install tomcat 8 and 9
RUN curl -JLs --retry 5 http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.40/bin/apache-tomcat-8.5.40.tar.gz | sudo tar xzvf - -C /usr/local/lib
RUN curl -JLs --retry 5 http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.19/bin/apache-tomcat-9.0.19.tar.gz | sudo tar xzvf - -C /usr/local/lib

# Get the code-server binary 
ARG CODE_SERVER_VERSION=1.939-vsc1.33.1
RUN curl -L https://github.com/codercom/code-server/releases/download/${CODE_SERVER_VERSION}/code-server${CODE_SERVER_VERSION}-linux-x64.tar.gz | tar xzv  -f - --strip-components=1 -C /usr/local/bin/ "code-server${CODE_SERVER_VERSION}-linux-x64/code-server"

COPY ./base-resources/install-marketplace-extension /usr/local/bin/install-marketplace-extension
RUN sudo chmod a+x /usr/local/bin/install-marketplace-extension

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
#   && code-server --install-extension vscjava.vscode-java-pack \
#   && code-server --install-extension redhat.vscode-xml

# Setup Extensions
ENV VSCODE_EXTENSIONS "/home/coder/.local/share/code-server/extensions"

# Generic Extensions
RUN install-marketplace-extension eamodio gitlens

# Java
RUN install-marketplace-extension redhat java latest 
RUN install-marketplace-extension vscjava vscode-java-debug latest 
RUN install-marketplace-extension vscjava vscode-java-test latest 
RUN install-marketplace-extension vscjava vscode-maven latest 
RUN install-marketplace-extension visualstudioexptteam vscodeintellicode latest 
RUN install-marketplace-extension vscjava vscode-java-dependency latest
RUN install-marketplace-extension adashen vscode-tomcat 
# Spring
RUN install-marketplace-extension pivotal vscode-spring-boot 
RUN install-marketplace-extension pivotal vscode-manifest-yaml 
RUN install-marketplace-extension pivotal vscode-concourse 
RUN install-marketplace-extension vscjava vscode-spring-initializr 
RUN install-marketplace-extension vscjava vscode-spring-boot-dashboard 

# code server default port
EXPOSE 8443
# running project default port
EXPOSE 8080

ENTRYPOINT ["dumb-init", "code-server"]