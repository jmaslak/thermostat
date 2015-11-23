#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use autodie;

use Carp;
use Device::BCM2835;
use File::Slurper;
use Thermostat::Hardware;
use Thermostat::SetPoint;

my $DEBUG=1;
my $CONFIG;
my $GPIO;
my $SETPOINT;
my $HARDWARE;

my $rate = 0.0;
my $onsince;
my $state = "OFF";
my $lastoff = 0;
my $laststate = 0; # 0 = off
my @rates;
my $last_temp = undef;
my $last_temp_time = undef;

MAIN: {
    $CONFIG = eval(File::Slurper::read_text('thermostat.conf'));
    $SETPOINT = Thermostat::SetPoint->new( { database => $CONFIG->{database} } );
    $HARDWARE = Thermostat::Hardware->new( {
            temp_sensor_bus => $CONFIG->{temp_sensor_bus},
            temp_sensor_address => $CONFIG->{temp_sensor_address}
    } );

    $GPIO = eval($CONFIG->{heat_gpio});
    Device::BCM2835::init();
    Device::BCM2835::gpio_fsel($GPIO, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    
    while (1) {
        thermostat();
        sleep 1;
    }
}

sub thermostat {
    if (scalar(@_) != 0) { confess 'invalid call' }

    my $set = get_setpoint();

    my $temp = get_tempf();
    update_rate($temp, 0);

    $DEBUG and printf("Temp: %6.2fF  Setpoint: %6.2fF  Rate: %6.4fF/sec - $state\n", $temp, $set, $rate);

    if ($temp + $CONFIG->{heat_swing} + ($rate * $CONFIG->{heat_off_delay}) < $set) {
        manage_on();
        if (!($laststate)) {
            # update_rate($temp, 1);
            $laststate = 1;
        }
    } elsif (($temp - $CONFIG->{heat_swing} ) + ($rate * $CONFIG->{heat_off_delay}) >= $set) {
        manage_off();
        if ($laststate) {
            # update_rate($temp, 1);
            $laststate = 0;
        }
    } else {
        ($DEBUG > 1) and print "Maintinaing current conditions\n";
    }
}

sub get_setpoint {
    if (scalar(@_) != 0) { confess 'invalid call' }

    return (0.0 + $SETPOINT->get_setpoint());
}

sub get_tempf {
    if (scalar(@_) != 0) { confess 'invalid call' }

    return $HARDWARE->current_temp();
}

sub manage_on {
    if (scalar(@_) != 0) { confess 'invalid call' }

    if ($lastoff + $CONFIG->{heat_min_off} > time()) {
        ($DEBUG > 1) and print "Delaying turnon";
        return;
    }

    if (!defined($onsince)) {
        $onsince = time();
    }

    if (($onsince + $CONFIG->{heat_recycle} ) < time()) {
        ($DEBUG > 1) and print "Recycling heater\n";
        set_heat(0);
        $onsince = undef;
        $lastoff = time();
        $state = "OFF";
    } else {
        set_heat(1);
        ($DEBUG > 1) and print "Turned on heater\n";
        $lastoff = 0;
        $state = "ON";
    }
}

sub set_heat {
    if (scalar(@_) != 1) { confess 'invalid call' }
    my $val = shift;
   
    $SETPOINT->set_heat($val); 
    Device::BCM2835::gpio_write($GPIO, $val);
}

sub manage_off {
    if (scalar(@_) != 0) { confess 'invalid call' }
    
    set_heat(0);

    $onsince = undef;
    if ($lastoff == 0) { $lastoff = time(); }

    ($DEBUG > 1) and print "Turned off heater\n";
    $state = "OFF";
}

sub update_rate {
    if (scalar(@_) != 2) { confess 'invalid call' }
    my ($temp, $force) = @_;

    if ((!defined($last_temp) or ($force))) {
        $last_temp = $temp;
        $last_temp_time = time();
        @rates = ();
        $rate = 0.0;
        return;
    }

    if ($last_temp_time + $CONFIG->{heat_samples} < time()) {
        push @rates, ($temp - $last_temp);
        $last_temp = $temp;
        $last_temp_time = time();
        if (scalar(@rates) > $CONFIG->{heat_samples}) { shift @rates; }

        my $sum = 0;
        foreach my $i (@rates) {
            $sum += $i;
        }
        $rate = ($sum / (scalar(@rates) + 0.0) / $CONFIG->{heat_samples} );
    }
}

