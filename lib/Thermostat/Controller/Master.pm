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

my @BASENAV = ();

# Main status display
sub show {
    my $self = shift;

    # We don't have any breadcrumbs to follow here
    $self->stash(nav => \@BASENAV);

    # We aren't going to do anything with parameters yet, but in the
    # future we will validate them here
    
    $self->stash(temp => 77); # XXX Just use 77 for now.

    # Render template
    $self->res->headers->cache_control('private, max-age=0, no-cache');
    $self->render();
}

1;


