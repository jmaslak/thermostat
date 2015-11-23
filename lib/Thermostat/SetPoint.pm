#!/usr/bin/perl

#
# Copyright (C) 2015 Joel C. Maslak
# All Rights Reserved - See License
#

use v5.22;

package Thermostat::SetPoint v0.01.00;

use strict;
use warnings;
use autodie;

use Moose;

use Carp;
use DBI;
use namespace::autoclean;

has 'database' => (
    is => 'rw',
    isa => 'Str',
    default => 'data/db.sql',
);

sub get_setpoint {
    if ($#_ != 0) { confess 'invalid call'; }
    my $self = shift;

    my $dbh = DBI->connect("dbi:SQLite:dbname=".$self->database, '', '')
        or die(DBI->errstr);
    my $sth = $dbh->prepare('
        SELECT  set_point
        FROM    config
        LIMIT 1;
    ') or die ($dbh->errstr);

    $sth->execute() or die($sth->errstr);
    my @result = $sth->fetchrow_array();
    if (scalar(@result) != 1) { die 'No results returned from database'; }

    my $temp = $result[0];
    return $temp;
}

sub set_setpoint {
    if ($#_ != 1) { confess 'invalid call'; }
    my $self = shift;
    my ($temp) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=".$self->database, '', '')
        or die(DBI->errstr);
    my $sth = $dbh->prepare('
        UPDATE  config
           SET  set_point=?;
    ') or die ($dbh->errstr);

    $sth->execute($temp) or die($sth->errstr);
}

sub get_heat {
    if ($#_ != 0) { confess 'invalid call'; }
    my $self = shift;

    my $dbh = DBI->connect("dbi:SQLite:dbname=".$self->database, '', '')
        or die(DBI->errstr);
    my $sth = $dbh->prepare('
        SELECT  heat
        FROM    config
        LIMIT 1;
    ') or die ($dbh->errstr);

    $sth->execute() or die($sth->errstr);
    my @result = $sth->fetchrow_array();
    if (scalar(@result) != 1) { die 'No results returned from database'; }

    my $temp = $result[0];
    return $temp;
}

sub set_heat {
    if ($#_ != 1) { confess 'invalid call'; }
    my $self = shift;
    my ($temp) = @_;

    my $dbh = DBI->connect("dbi:SQLite:dbname=".$self->database, '', '')
        or die(DBI->errstr);
    my $sth = $dbh->prepare('
        UPDATE  config
           SET  heat=?;
    ') or die ($dbh->errstr);

    $sth->execute($temp) or die($sth->errstr);
}

__PACKAGE__->meta->make_immutable;

1;


