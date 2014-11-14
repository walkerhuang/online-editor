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
package EDRu;

use strict;
use Fcntl qw(:DEFAULT :flock);
use Time::HiRes qw(sleep);
use Cwd qw(abs_path);
use File::Path;

# copy a file with same or different file name between two different systems.
sub copy {
    my ($sys_src,$file_src,$sys_dest,$file_dest,$ddoe) = @_;
    my ($msg,$rtn,$trans,$localsys,$basename,$tmpdir,$tmpfile);

    $file_dest||=$file_src;

    # if the source system is same with the destination system
    if (($sys_src->{sys} eq $sys_dest->{sys}) ||
        ($sys_src->{islocal} && $sys_dest->{islocal})) {
        # return if the file is same name
        return 1 if ($file_src eq $file_dest);
        return $sys_src->copyfile($file_src, $file_dest);
    }

    if ($sys_src->{islocal}) {
        $trans=$sys_dest->{transport_obj};
        $rtn=$trans->copy_to_sys($sys_src,$file_src,$sys_dest,$file_dest) if ($trans);
    } elsif ($sys_dest->{islocal}) {
        $trans=$sys_src->{transport_obj};
        $rtn=$trans->copy_to_sys($sys_src,$file_src,$sys_dest,$file_dest) if ($trans);
    } else {
        $localsys=EDR::get('localsys');
        $basename = basename($file_src);
        $tmpdir=EDR::get('tmpdir');
        $tmpfile = "$tmpdir/$basename.". $sys_src->{sys};

        $trans=$sys_src->{transport_obj};
        $rtn=$trans->copy_to_sys($sys_src,$file_src,$localsys,$tmpfile) if ($trans);

        if ($rtn) {
            $rtn='';
            $trans=$sys_dest->{transport_obj};
            $rtn=$trans->copy_to_sys($localsys,$tmpfile,$sys_dest,$file_dest) if ($trans);
        }
    }

    # $ddoe means whether do not die on error
    $ddoe ||= '';
    if (!$rtn) {
        $msg=Msg::new("Failed to copy $file_src from $sys_src->{sys} to $file_dest on $sys_dest->{sys}");
        if ($ddoe eq 'noerr') {
            $msg->log;
        } else {
            ($ddoe) ? $msg->print : $msg->die;
            return 0;
        }
    }
    return 1;
}

# determine size of package or patch on media
sub filesize {
    my $file=shift;
    # Calculate filesize in KB.
    my $size = (stat $file)[7] > 1023 ? (stat $file)[7]/1024 : 1;
    # assume compression of 3x, so *4 as both
    # tarfile and original are there after gunzip
    $size*=4 if (($size) && ($file=~/gz$/m));
    return $size;
}

# read a file
sub readfile {
    my ($file,$lock) = @_;
    my ($line,$msg,$rf,$fd);
    if(!open($fd, '<', $file)) {
        $msg=Msg::new("\nreadfile cannot open $file");
        $msg->die;
    }
    if($lock){
        if(!flock($fd, LOCK_SH)){
            $msg=Msg::new("\ncannot lock $file");
            $msg->die;
        }
    }
    $rf ='';
    while ($line=<$fd>) { $rf.=$line; }
    close($fd);
    return $rf;
}

sub readfile_with_lock {
    my $file = shift;
    return readfile($file,1);
}

# touch a file as sync flag
sub create_flag {
    my $flag_name=shift;
    my $tmpdir=EDR::get('tmpdir');
    my $localsys=Obj::localsys();
    $localsys->createfile("$tmpdir/$flag_name");
    # Push all the flags into $edr->{file_flags}
    EDR::set_value('file_flags','push',$flag_name);
    return '';
}

# check if the flag file exist
sub check_flag {
    my $flag_name=shift;
    my $tmpdir=EDR::get('tmpdir');
    return 1 if (-f "$tmpdir/$flag_name");
    return 0;
}

# wait for the file
sub wait_for_flag {
    my $flag_name=shift;
    my $tmpdir=EDR::get('tmpdir');
    wait_for_file("$tmpdir/$flag_name");
    return '';
}

# write a string to a file
sub writefile {
    my($write,$file)= @_;
    # need two checks here:
    # is the directory created
    # is the filename a directory, if so die because the write will fail
    # should check this earlier, if possible
    my $msg;
    if(!sysopen(WF, "$file", O_RDWR | O_CREAT)){
        $msg=Msg::new("\nwritefile cannot open $file");
        $msg->die;
    }
    flock(WF, LOCK_EX);
    # Now we have acquired the lock, it's safe for I/O
    seek(WF, 0, 0);
    truncate(WF, 0);
    print WF $write;
    close(WF);
    return;
}

# append a newlined string to a file
sub appendfile {
    my($msg,$file)= @_;
    my $fd;
    if(!open($fd, '>>', $file)){
        $msg=Msg::new("\nappendfile cannot open $file");
        $msg->die;
    }
    print $fd "$msg\n";
    close($fd);
    return;
}

# wait for a file
sub wait_for_file {
    my $file=shift;
    while (!-f $file) {
        my $sleep++;
        if ($sleep%6000==0) { # should never hit, but will detect hangs
            Msg::log("Waited $sleep seconds for $file");
        }
        #sleep 1;
        #select(undef,undef,undef,0.01);
        sleep(0.01);
    }
    return '';
}

# wait for a file to be removed
# wait log period is much longer because a long wait is possible during install
sub wait_for_file_rm {
    my $file=shift;
    while (-f $file) {
        my $sleep++;
        if ($sleep%60000==0) { # should rarely hit
            Msg::log("Waited $sleep seconds for $file to be removed");
        }
        #sleep 1;
        #select(undef,undef,undef,0.01);
        sleep(0.01);
    }
    return '';
}

#get the application's current path
sub app_path {
    my ($cwd,$dir);
    $cwd=dirname($0);
    if ($cwd =~ m{^/}) {
        $dir=$cwd;
    } else {
        $dir=abs_path($cwd);
    }
    return $dir;
}

sub mkdir_local_nosys {
    my ($dir) = @_;

    unless (-e $dir) {
        #Msg::log("Creating directory: $dir");
        unless(File::Path::mkpath($dir)) {
            Msg::log("Could not create directory: $dir");
            return 0;
        }
    }
    return 1;
}

sub rmdir_local_nosys {
    my ($dir) = @_;

    if (-e $dir) {
        #Msg::log("Removing directory: $dir");
        unless(File::Path::rmtree($dir)) {
            Msg::log("Could not remove directory: $dir");
            return 0;
        }
    }
    return 1;
}

sub eval_json {
    my ($content) = @_;
    my ($json,$jsonhash);
    $json = JSON->new->allow_nonref;
    eval { $jsonhash = $json->decode($content) };
    if ($@) {
        Msg::log("Failed to parse JSON string\n$@\n$content");
        return 0;
    }
    return $jsonhash;
}

1;
