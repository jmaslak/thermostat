#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

use v5.14;

package Thermostat::Controller::Master v0.01.00;

use strict;
use warnings;
use autodie;

use Mojo::Base 'Mojolicious::Controller';

use Carp;
use Regexp::Common;

my @BASENAV = ();
our $CONFIG;
our $HARDWARE;
our $SETPOINT;

# Main status display
sub show {
    my $self = shift;

    # We don't have any breadcrumbs to follow here
    $self->stash(nav => \@BASENAV);
    $self->stash(base_url => $CONFIG->{'base_url'});

    # Get Old set point temperature
    my $old_setpoint = $SETPOINT->get_setpoint();
    my $new_setpoint = $self->param('settemp') // $old_setpoint;

    if ( !( $new_setpoint =~ m/^$RE{num}{int}{-sign=>''}$/ ) ) {
        $new_setpoint = $old_setpoint;
    }

    if ($new_setpoint < $CONFIG->{'temp_minimum'}) {
        $new_setpoint = $CONFIG->{'temp_minimum'};
    } elsif ($new_setpoint > $CONFIG->{'temp_maximum'}) {
        $new_setpoint = $CONFIG->{'temp_maximum'};
    }

    if ($new_setpoint != $old_setpoint) {
        $SETPOINT->set_setpoint($new_setpoint);
    }
    
    $self->stash(temp => $HARDWARE->current_temp());
    $self->stash(setpoint => $new_setpoint);
    $self->stash(old_setpoint => $old_setpoint);
    $self->stash(temp_setlow => $CONFIG->{'temp_setlow'});
    $self->stash(temp_sethigh => $CONFIG->{'temp_sethigh'});
    $self->stash(heat => $SETPOINT->get_heat());

    # Render template
    $self->res->headers->cache_control('private, max-age=0, no-cache');
    $self->render();
}

1;


