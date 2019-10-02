#!/bin/bash

set -x

set -eo pipefail

ARGS=""

ARGS="$ARGS --port 8080"

ARGS="$ARGS --log-to-terminal"

ARGS="$ARGS --access-log"

if [ x"$MOD_WSGI_PROCESSES" != x"" ]; then
    ARGS="$ARGS --processes $MOD_WSGI_PROCESSES"
fi

if [ x"$MOD_WSGI_THREADS" != x"" ]; then
    ARGS="$ARGS --threads $MOD_WSGI_THREADS"
fi

if [ x"$MOD_WSGI_MAX_CLIENTS" != x"" ]; then
    ARGS="$ARGS --max-clients $MOD_WSGI_MAX_CLIENTS"
fi

if [ x"$MOD_WSGI_RELOAD_ON_CHANGES" != x"" ]; then
    ARGS="$ARGS --reload-on-changes"
fi

exec mod_wsgi-express start-server $ARGS wsgi.py
