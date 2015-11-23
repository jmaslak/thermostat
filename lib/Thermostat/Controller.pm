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
use Thermostat::Controller::Master;
use Thermostat::Hardware;
use Thermostat::SetPoint;

sub register {
    my ($self, $app) = @_;

    my $config = $app->config;

    $Thermostat::Controller::Master::CONFIG = $app->config;
    $Thermostat::Controller::Master::HARDWARE =
        Thermostat::Hardware->new( {
            temp_sensor_bus => $config->{temp_sensor_bus},
            temp_sensor_address => $config->{temp_sensor_address}
        } );
    $Thermostat::Controller::Master::SETPOINT =
        Thermostat::SetPoint->new( {
            database => $config->{database}
        } );

    my $r = $app->routes;
    $r->get('/')
        ->to('Master#show', namespace => 'Thermostat::Controller');
}

1;


