#!/bin/sh

sysrc conduit_enable="YES"
sysrc nginx_enable="YES"

SERVER_NAME=your.server.name
ed /usr/local/etc/conduit.toml << EOF
/server_name/
o
server_name = "$SERVER_NAME"
.
wq
EOF
ed /usr/local/nginx/nginx.conf << EOF
$
-1
i
    server {
        listen      443 ssl;
        server_name $SERVER_NAME;
        location /_matrix/ {
          proxy_pass http://localhost:6167/;
          include proxy_params;
        }
    }
.
wq
EOF

echo "You will need to set server_name in /usr/local/etc/conduit.toml and then run

service conduit start"
