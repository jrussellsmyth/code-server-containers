

# first -v maps local project folder to "project"
# second -v maps local extension folder to the container, to allow persistence and 

docker run -d -t -p 127.0.0.1:8444:8443 -v "/Users/jrussell/code:/root/project" -v "/Users/jrussell/code/code-server-node/extensions:/root/.local/share/code-server/extensions" jrussellsmyth/code-server-node:curl WebComponentTodo --allow-http --no-auth && chromeapp http://localhost:8444

# for debuggers to work, need to remove some seccomp restrictions - for now, removing all.
# for go project, mount go workspace to /home/coder/project
docker run -d --security-opt seccomp=unconfined -p 127.0.0.1:8443:8443 -v "${PWD}:/home/coder/project" --name go-ide jrussellsmyth/code-server-go --allow-http --no-auth


# extensions for js.. [WIP]
eamodio.gitlens-9.5.1
esbenp.prettier-vscode-1.8.1
humao.rest-client-0.21.2
mgmcdermott.vscode-language-babel-0.0.21