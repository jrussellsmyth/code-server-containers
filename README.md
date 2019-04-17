# first -v maps local project folder to "project"
# second -v maps local extension folder to the container, to allow persistence and 

docker run -d -t -p 127.0.0.1:8444:8443 -v "/Users/jrussell/code:/root/project" -v "/Users/jrussell/code/code-server-node/extensions:/root/.local/share/code-server/extensions" jrussellsmyth/code-server-node:curl WebComponentTodo --allow-http --no-auth && chromeapp http://localhost:8444