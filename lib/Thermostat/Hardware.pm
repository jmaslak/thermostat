#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

use v5.22;

package Thermostat::Hardware v0.01.00;

use strict;
use warnings;
use autodie;

use Moose;

use Carp;
use Convert::Temperature;
use Device::Temperature::TMP102;
use namespace::autoclean;

has 'temp_sensor_bus' => (
    is => 'ro',
    isa => 'Str',
    default => '/dev/i2c-1',
);

has 'temp_sensor_address' => (
    is => 'ro',
    isa => 'Int',
    default => 0x48,
);

has 'temp_server_object' => (
    is => 'ro',
    isa => 'Object',
    builder => 'builder_temp_server_object',
);

sub builder_temp_server_object {
    my $self = shift;

    return Device::Temperature::TMP102->new(
        I2CBusDevicePath => $self->temp_sensor_bus(),
        I2CDeviceAddress => $self->temp_sensor_address()
    );
}

sub current_temp {
    if ($#_ != 0) { confess 'invalid call'; }
    my $self = shift;

    my $temp = $self->temp_server_object->getTemp;

    my $conv = Convert::Temperature->new();
    $temp = $conv->from_cel_to_fahr($temp);

    return $temp;
}

__PACKAGE__->meta->make_immutable;

1;


