To retrieve code-server from another docker image - official, or self built - add before your actual build FROM line

FROM {{image}} as base 

then inside your docker build (after your real FROM) add

# get code-server binary from built docker 
COPY --from=base /usr/local/bin/code-server /usr/local/bin/code-server
