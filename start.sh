#!/bin/bash

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

if [ \! -d data ] ; then
    mkdir data
fi

export BASE_URL=''
export PORT=3002
if [ -f .environment ] ; then
    . .environment
fi

if [ "$TEMP_SENSOR" == "" ] ; then
    TEMP_SENSOR="/dev/i2c-1"
fi

if [ \! -r "$TEMP_SENSOR" ] || [ \! -w "$TEMP_SENSOR" ] ; then
    echo "Cannot read from $TEMP_SENSOR - check permissions" >&2
    exit 1
fi

if [ "$OPTIONS" == "" ] ; then
    OPTIONS="--listen http://127.0.0.1:$PORT --listen http://[::1]:$PORT"
fi

if [ "$PERL " == "" ] ; then
    PERL=perl
fi

if [ "$MORBO" == "" ] ; then
    MORBO=morbo
fi

if [ "$DB" == "" ] ; then
    DB='data/db.sql'
fi

if [ \! -f 'data/db.sql' ] ; then
    cat script/schema*.sql | sqlite3 "$DB"
    if [ $? -ne 0 ] ; then
        echo "Cannot create database $DB" >&2
        exit 2
    fi
fi

PROD_OPTIONS="$OPTIONS -p "

export MOJO_MODE="$MOJO_ENV"

doit() {
    if [ "$MOJO_ENV" == "DEVELOPMENT" ] ; then
        echo "Starting in development mode"
        $MORBO script/thermostat $OPTIONS -v
    else
        echo "Starting in production mode"
        $PERL script/thermostat daemon $PROD_OPTIONS
    fi
}

doit
