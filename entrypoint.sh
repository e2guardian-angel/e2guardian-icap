#!/bin/bash
# encoding: utf-8

if [ -f /var/run/e2guardian.pid ]; then
    rm /var/run/e2guardian.pid
fi

E2GUARDIAN_EXEC=/usr/sbin/e2guardian
exec /usr/sbin/e2guardian
