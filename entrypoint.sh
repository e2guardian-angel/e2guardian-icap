#!/bin/bash
# encoding: utf-8

if [ -f /var/run/e2guardian.pid ]; then
    rm /var/run/e2guardian.pid
fi

E2GUARDIAN_EXEC=/opt/e2guardian/sbin/e2guardian
exec $E2GUARDIAN_EXEC -c /opt/e2guardian/etc/e2guardian/e2guardian.conf -N
