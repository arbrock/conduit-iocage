#!/bin/sh

pw add user -n conduit -C Conduit -s /bin/nologin -m

sysrc conduit_enable="YES"

service conduit start
