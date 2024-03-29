#!/bin/bash
# encoding: utf-8
export E2G_ROOT=/etc/e2guardian

if [ -f /var/run/e2guardian.pid ]; then
    rm /var/run/e2guardian.pid
fi

E2GUARDIAN_EXEC=/usr/bin/e2guardian
exec $E2GUARDIAN_EXEC -c ${E2G_ROOT}/e2guardian.conf -N
