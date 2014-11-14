#
# $Copyright: Copyright (c) 2014 Symantec Corporation.
# All rights reserved.
#
# THIS SOFTWARE CONTAINS CONFIDENTIAL INFORMATION AND TRADE SECRETS OF
# SYMANTEC CORPORATION.  USE, DISCLOSURE OR REPRODUCTION IS PROHIBITED
# WITHOUT THE PRIOR EXPRESS WRITTEN PERMISSION OF SYMANTEC CORPORATION.
#
# The Licensed Software and Documentation are deemed to be commercial
# computer software as defined in FAR 12.212 and subject to restricted
# rights as defined in FAR Section 52.227-19 "Commercial Computer
# Software - Restricted Rights" and DFARS 227.7202, "Rights in
# Commercial Computer Software or Commercial Computer Software
# Documentation", as applicable, and any successor regulations. Any use,
# modification, reproduction release, performance, display or disclosure
# of the Licensed Software and Documentation by the U.S. Government
# shall be solely in accordance with the terms of this Agreement.  $
#
use Transport::SSH;
use Transport::RSH;
use Transport::VOM;
use Transport::WMI;
use Transport::Wire;
use Transport::VCSCLI;
use Transport::VMWare;

package Transport;
use strict;
use Obj;
@Transport::ISA = qw(Obj);

use constant {
    # The server could not be pingable
    ESERVERNOTPINGABLE   => 1,

    # The service daemon not started on remote machine, like rshd or sshd.
    ESERVICENOTAVAILABLE => 2,

    # The command binary is not available
    EBINARYNOTAVAILABLE  => 3,

    # The connection is denied when run connection command, like rsh or ssh
    ECONNECTIONDENIED    => 4,

    # The password is not correct when setup connection
    EINVALIDPASSWORD     => 5,

    # Other unknown errors
    EUNKNOWNERROR        => 99,
};

sub init {
    my $self=shift;
    my $transport=$self->{class};
    $transport=~s/^Transport\:://;
    $self->{transport}=$transport;

    $self->init_transport(@_);
    return;
}

sub init_transport {}

# Check the connection. return 1 if the transport connection is working.
sub check_sys {}

# Setup the connection
sub setup_sys {}

# Unsetup the connection
sub unsetup_sys {}

# Execute command through the transportation
sub cmd_sys {}

# Copy file on different systems through the transportation
sub copy_to_sys {}


# Private methods

sub set_error_sys {
    my ($trans,$sys,$error_no,$error_msg)=@_;
    my $transport=$trans->{transport};

    if (defined $error_no) {
        $sys->set_value("transport_error_no,$transport", $error_no);
    }

    if (defined $error_msg) {
        if (ref($error_msg) =~ m/^Msg/) {
            $error_msg=$error_msg->{msg};
        }
        $sys->set_value("transport_error_msg,$transport", $error_msg);
    }
    return 1;
}

# Public methods

sub is_supported_transport {
    my $transport=shift;

    return if (!$transport);

    my @supported_transports=qw(SSH RSH VOM WMI Wire VCSCLI VMWare);
    for my $trans (@supported_transports) {
        return $trans if ($transport=~/^$trans$/i);
    }
    return;
}

sub check_connection_sys {
    my $sys=shift;
    my $transports=shift;

    for my $transport (split(/[|;]/, $transports)) {
        $transport=is_supported_transport($transport);
        next if (!$transport);

        my $trans="Transport\::$transport"->new();
        return $trans if ($trans->check_sys($sys, @_));
    }

    return;
}

sub setup_connection_sys {
    my $sys=shift;
    my $transport=shift;

    $transport=is_supported_transport($transport);
    return if (!$transport);

    my $trans="Transport\::$transport"->new();
    return $trans if ($trans->setup_sys($sys, @_) &&
                      $trans->check_sys($sys, @_));
    return;
}

sub unsetup_connection_sys {
    my $sys=shift;
    my $transport=shift;

    $transport=is_supported_transport($transport);
    return 1 if (!$transport);

    my $trans="Transport\::$transport"->new();
    return $trans->unsetup_sys($sys, @_);
}

sub get_connection_error_sys {
    my $sys=shift;
    my $transport=shift;
    my ($error_no,$error_msg);

    $transport=is_supported_transport($transport);
    if ($transport) {
        if (defined $sys->{transport_error_no}{$transport}) {
            $error_no=$sys->{transport_error_no}{$transport};
        }
        if (defined $sys->{transport_error_msg}{$transport}) {
            $error_msg=$sys->{transport_error_msg}{$transport};
        }
    }

    $error_no||=0;
    $error_msg||='';
    return ($error_no,$error_msg);
}

1;
