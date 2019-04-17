Add this to a dockerfile to use nvm to install node. not currently recommended

```Dockerfile
RUN mkdir -p /home/coder/.nvm
ENV NVM_DIR /home/coder/.nvm 
ENV NODE_VERSION 10.15.3

# Install nvm with node and npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default 

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/v$NODE_VERSION/bin:$PATH
```