#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

use v5.22;

package Thermostat;

use strict;
use warnings;
use autodie;

use Carp;

use Mojo::Base 'Mojolicious';

our $CONFIG;

# This method will run once at server start
sub startup {
    my $self = shift;

    if (defined($ENV{MOJO_ENV})) {
        $self->mode(lc($ENV{MOJO_ENV}));
    }

    $self->plugin('Config', {file => 'thermostat.conf'} );
    $CONFIG = $self->config;

    my $prefix = $ENV{'BASE_URL'};
    $prefix //= '';

    $self->secrets(['lfasjlkfd8VJlasjl459vsdavj8sodGJdiflFLIsdf9f32l']);

    # Serve TFF & WOFF2 files properly
    $self->types->type(ttf => 'font/ttf');
    $self->types->type(woff2 => 'font/woff2');

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('example#welcome');

    # Allow caching of static stuff
    $self->hook(after_static => sub {
        my $tx = shift;
        my $code = $tx->res->code;
        my $type = $tx->res->headers->content_type;

        # Was the response static?
        return unless $code && ($code == 304 || $type);

        # If so, remove cookies and/or caching instructions
        $tx->res->headers->remove('Cache-Control');
        $tx->res->headers->remove('Set-Cookie');

        # Decide on an expiry date
        my $e = Mojo::Date->new(time+86400);
        $tx->res->headers->header("Cache-Control" => "public");
        $tx->res->headers->header(Expires => $e);
    });

}

1;
