#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

use v5.14;

package Thermostat::Controller v0.01.00;
use base 'Mojolicious::Plugin';

use strict;
use warnings;
use autodie;

use Carp;

sub register {
    my ($self, $app) = @_;

    my $r = $app->routes;
    $r->get('/')
        ->to('Master#show', namespace => 'Thermostat::Controller');
}

1;


