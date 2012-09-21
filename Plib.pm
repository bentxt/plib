package Plib;
use base qw (Exporter);
use File::Find 'find';
use File::Copy qw( cp );
use File::Spec::Functions qw (catfile catdir catpath splitdir splitpath); 
use File::Basename qw(basename dirname);
    use Cwd 'abs_path';
our @EXPORT = qw(shpipe list hash echo  prn include clos clox arg setasub sref fun cfun xfun clarg ls nth catish reader head sedish replace  extract grepish etch sh scriptpath scriptname args argv ispath isdir isfile fullpath envar redir basename d_name f_ext filename filext size tostr find catdir catpath catfile splitdir  splitpath basename dirname tree matches cp cpdir);

## base

sub size {
    my @arr = @_;
    my $size = $#arr + 1;
    return $size;
}

sub tostr{
    my @lns = @_;
    my $str = join('',@lns);
    return $str;
}

## io
sub filext{
    my $file = shift;
    return substr($file, rindex($file, '.') + 1);
}
sub filename{
    my $file = shift;
    my $sep = shift;
    return substr($file, 0, rindex($file, '.'));
}

sub redir{
    my $op = shift;
    my $f = shift;
    my @c = @_;
    if ( $op eq '>' ){
        open my $handle, '>', $f;
        print $handle @c;
        close $handle;
    } elsif ( $op eq '>>' ){
        open my $handle, '>>', $f;
        print $handle @c;
        close $handle;
    } elsif ( $op eq '<' ){
        open my $handle, '<', $f;
        chomp(my @lines = <$handle>);
        close $handle;
        return @lines;
    } else{
        die ("ERR: Couldn't redirect");
    }
}

sub tree{
    my $dir = shift;
    my @list;
    my $clos = sub { push(@list, $File::Find::name)};
    find($clos, $dir);
    return @list;
}

sub cpdir{
    use File::Copy;
    my ($from_dir, $to_dir ) = @_;
    opendir my($dh), $from_dir or die "Could not open dir '$from_dir': $!";
    for my $entry (readdir $dh) {
        next if $entry =~ /^\.+\.*$/;
        my $source = "$from_dir/$entry";
        my $destination = "$to_dir/$entry";
        if( not -d $to_dir ){ mkdir $to_dir ; } 
        if (-d $source) {
            mkdir $destination or die "mkdir '$destination' failed: $!" if not -e $destination;
            cpdir($source, $destination );
        } else {
            copy($source, $destination) or die "copy failed: $!";
        }
    }
    closedir $dh;
    return;
}
sub cpdirx{
    my ($from_dir, $to_dir, $regex) = @_;
    opendir my($dh), $from_dir or die "Could not open dir '$from_dir': $!";
    for my $entry (readdir $dh) {
        next if $entry =~ /$regex/;
        my $source = "$from_dir/$entry";
        my $destination = "$to_dir/$entry";
        if (-d $source) {
            mkdir $destination or die "mkdir '$destination' failed: $!" if not -e $destination;
            copy_recursively($source, $destination, $regex);
        } else {
            copy($source, $destination) or die "copy failed: $!";
        }
    }
    closedir $dh;
    return;
}



sub isfile {
    my $path = shift;
    if ( -f $path ) { return 1 } 
    else { return 0 }
}
sub isdir{
    my $path = shift;
    if ( -d $path ) { 
        return 1 ;
    } else { 
        return 0 ;
    }
}
sub ispath {
    my $path = shift;
    my $res = 0;
    if ( -f $path ) { 
        $res = 1;
    } elsif ( -l $path ) {
        $res = 1;
    } elsif ( -f $path ) {
        $res = 1;
    } else { return 0 }
}

## REgex
#
sub args {
    scalar @ARGV;
}
sub argv {
    my $v = shift;
    if ( not defined $v  ){
        @ARGV;
    }elsif ( $v == 0 ){
        return abs_path($0);
    }else{
        $v--;
        $ARGV[$v];
    }
}

sub scriptpath {
    return abs_path($0);
}
sub scriptname {
    return basename($0);
}

sub grepish{
    my $regx = shift;
    my $txt = shift;
    my @buf = split /^/m, $txt;
    my @lines = grep (/$regx/, @buf);
    my $str = join('',@lines);
    return $str;

}
sub etch{
    my $regx= shift;
    my @buf = @_;
    my @lines = grep (/$regx/, @buf);

    my @buffer = ();
    for $l (@lines){
        $l =~ s/$regx/''/e ;
        push(@buffer, $l);
    }
    my $text = join('',@buffer);
    return $text;
}
sub sedish{
    my $regx= shift;
    my $cr = shift;
    my $text =shift; 
    my $tor=q("). $cr . q(");
    my $regto = sub { eval $tor } ;
    $text =~ s/$regx/$regto->()/e ;
    #$text =~ s/> url: //g ;
    return $text;
}
sub replace{
    my $regx= shift;
    my $cr = shift;
    my $ln = shift;

    my $tor=q("). $cr . q(");
    my $regto = sub { eval $tor } ;
    $ln =~ s/$regx/$regto->()/e ;
    return $ln;
}
sub extract{
    my $ln = shift;
    my $regx= shift;
    my $q = shift;

    my @x = ($ln =~ /$regx/) ;
    return @x;
}

sub matches{
    my $ln = shift;
    my $regx= shift;
    my $q = shift;
    if ($ln =~ /$regx/) {
        return 1;
    }else{
        return 0;
    }
}

## Prelude


sub sref {
    return \$_[0];
}

sub list{
    return @_;
}
sub hash{
    return @_;
}
sub echo{
    print "@_ \n";
}
sub include{
    use Plib;
}


sub nth {
    my $i = shift;
    my @l = @_;
    return $l[$i];
}

## Shutils
sub sh{
    my $cmd = shift;
    my @outp=();
    @outp=`$cmd `;
    die "This command failed: $incmd \n"  unless (($?>>8)==0);
    @outp;
}

sub envar {
    my $cmd = shift;
    if ( $cmd == 'HOME'){
        my @r = sh('printf $HOME');
        return $r[0]; 
    }
}

sub ls {
    my $dirname = shift;
    opendir my($dh), $dirname or die "Couldn't open dir '$dirname': $!";
    #my @files = readdir $dh;
    @files = grep !/^\.\.?$/, readdir($dh);
    closedir $dh;
    return @files;
}

sub reader{
    my $p = shift;
}
sub catish {
    my $p = shift;
    open my $handle, '<', $p;
    chomp(my @lines = <$handle>);
    # my $document = do {
    #     local $/ = undef;
    #     open my $fh, "<", $p or die "could not open $p: $!";
    #     <$fh>;
    # };
    #return $document;
    return @lines;
}

sub head {
    my $p = shift;
    open my $handle, '<', $p;
    chomp(my @lines = <$handle>);
    close $handle;
    return $lines[0];
}



## Closure stuff
sub arg {  ## because in sleep we have to diff
    my $i = shift;
    my @l = @_;
    return $l[$i];
}

sub clos {
    my $c=shift;
    return sub { eval $c  };
}

sub clox {
    my $c = shift;
    my @args = @_;
    $c->(@args);
}

1;
