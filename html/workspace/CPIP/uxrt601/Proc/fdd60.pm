use strict;

package Proc::fdd60::Common;
@Proc::fdd60::Common::ISA = qw(Proc);

sub init_common {
    my $proc=shift;
    $proc->{proc}='fdd';
    $proc->{name}='fdd name';
    $proc->{desc}='fdd description';
    return;
}

package Proc::fdd60::AIX;
@Proc::fdd60::AIX::ISA = qw(Proc::fdd60::Common);

package Proc::fdd60::HPUX;
@Proc::fdd60::HPUX::ISA = qw(Proc::fdd60::Common);

package Proc::fdd60::Linux;
@Proc::fdd60::Linux::ISA = qw(Proc::fdd60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::fdd60::SunOS;
@Proc::fdd60::SunOS::ISA = qw(Proc::fdd60::Common);

# load to kernel
sub start_sys {
    my ($proc,$sys)=@_;
    $sys->padv->load_driver_sys($sys,$proc->{proc});
    return 1;
}

# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    $sys->cmd('echo vxfdd_nounload/W0 | adb -k -w > /dev/null 2>&1');
    $sys->padv->unload_driver_sys($sys,$proc->{proc});
    return 1;
}

# check whether mod is loaded
# 1 means loaded, 0 means not loaded
sub check_sys {
    my ($proc,$sys)=@_;
    my $rtn=$sys->padv->driver_sys($sys,$proc->{proc});
    return ($rtn?1:0);
}

package Proc::fdd60::Sol11sparc;
@Proc::fdd60::Sol11sparc::ISA = qw(Proc::fdd60::SunOS);
 
# unload from kernel
sub stop_sys {
    my ($proc,$sys)=@_;
    my ($mod,$cmd,$driver);
    $driver=$proc->{proc};
    $sys->cmd('echo vxfdd_nounload/W0 | adb -k -w > /dev/null 2>&1');
    $mod=$sys->padv->driver_sys($sys, $driver);
    if ($mod) {
        # To avoid Solaris 11 aggressive module auto load mechanism
        $cmd="_cmd_rmdrv $driver 2>/dev/null";
        for my $mod_id (split(/\s+/m,$mod)) {
            $cmd.=";_cmd_modunload -i $mod_id 2>/dev/null";
        }
        $sys->cmd("$cmd");
    }
 
    return 1;
}
 
package Proc::fdd60::Sol11x64;
@Proc::fdd60::Sol11x64::ISA = qw(Proc::fdd60::Sol11sparc);

1;
