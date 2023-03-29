#!/bin/sh

sysrc conduit_enable="YES"
sysrc nginx_enable="YES"

SERVER_NAME=$(hostname)
if [ -z "$SERVER_NAME" ] ; then
  echo "Using terrible default server name"
  SERVER_NAME=your.server.name
fi
ed /usr/local/etc/conduit.toml << EOF
/server_name/
i
server_name = "$SERVER_NAME"
.
wq
EOF
ed /usr/local/etc/nginx/nginx.conf << EOF
$
-1
i
    server {
        listen      443 ssl;
        server_name $SERVER_NAME;

        ssl_certificate           cert.pem
        ssl_certificat_key        cert.key
        ssl_session_cache         shared:SSL:1m;
        ssl_session_timeout       5m;
        ssl_ciphers               HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        location /_matrix/ {
          proxy_pass http://localhost:6167/;
          include proxy_params;
        }
    }
.
wq
EOF
openssl req -x509 -newkey rsa:4096 \
  -keyout /usr/local/etc/nginx/cert.key \
  -out /usr/local/etc/nginx/cert.pem \
  -days 365 -nodes \
  -subj /CN=$SERVER_NAME \
  -addext "subjectAltName = DNS:conduit,DNS:matrix"

cat << EOM
You will need to set server_name in /usr/local/etc/conduit.toml"
and /usr/local/nginx/nginx.conf, and then run

service conduit start
service nginx start
EOM
