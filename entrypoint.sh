#!/bin/bash
# encoding: utf-8
export E2G_ROOT=/opt/etc/e2guardian

if [ -f /var/run/e2guardian.pid ]; then
    rm /var/run/e2guardian.pid
fi

sh /confige2g.sh

E2GUARDIAN_EXEC=/opt/sbin/e2guardian
exec $E2GUARDIAN_EXEC -c ${E2G_ROOT}/e2guardian.conf -N
