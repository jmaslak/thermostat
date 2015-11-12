#!/bin/bash

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

export BASE_URL=''
export PORT=3002
if [ -f .environment ] ; then
    . .environment
fi

if [ "$OPTIONS" == "" ] ; then
    OPTIONS="--listen http://127.0.0.1:$PORT --listen http://[::1]:$PORT"
fi

PROD_OPTIONS="$OPTIONS -p "

export MOJO_MODE="$MOJO_ENV"

doit() {
    if [ "$MOJO_ENV" == "DEVELOPMENT" ] ; then
        echo "Starting in development mode"
        morbo script/thermostat $OPTIONS -v
    else
        echo "Starting in production mode"
        perl script/thermostat daemon $PROD_OPTIONS
    fi
}

doit
