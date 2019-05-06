#!/bin/bash
docker build -t jrussellsmyth/code-server-java -f java.Dockerfile --build-arg JAVA_VERSION=11 .
docker build -t jrussellsmyth/code-server-js -f node.Dockerfile --build-arg NODE_VERSION=lts .
docker build -t jrussellsmyth/code-server-go -f go.Dockerfile --build-arg GO_VERSION=latest .