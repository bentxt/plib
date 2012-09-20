package Plib;
use base qw (Exporter);
our @EXPORT = qw(shpipe list hash echo  prn include clos clox arg setasub sref fun cfun xfun clarg ls nth catish reader head sedish replace grepish etch sh scriptpath scriptname args argv ispath d_exists fullpath d_path f_path f_exists envar writer fappend basename d_name f_ext prefix size lst2str);

## base

sub size {
    my @arr = @_;
    my $size = $#arr + 1;
    return $size;
}

sub lst2str{
    my @lns = @_;
    my $str = join('',@lns);
    return $str;
}


## io
#

sub basename{
    use File::Basename;
    return File::Basename->basename(shift);
}
sub dirname{
    use File::Basename;
    return File::Basename->dirname(shift);
}
sub suffix{
    my $file = shift;
    my $sep = shift;
    return substr($file, rindex($file, $sep) + 1);
}
sub prefix{
    my $file = shift;
    my $sep = shift;
    return substr($file, 0, rindex($file, $sep));
}

sub writer{
    my $f = shift;
    my @c = @_;
    open my $handle, '>', $f;
    print $handle @c;
    close $handle;
}
sub fappend{
    my $f = shift;
    my @c = @_;
    open my $handle, '>>', $f;
    print $handle @c;
    close $handle;
}

sub d_path {
    my @dirs=@_;
    use File::Spec; 
    return File::Spec->catdir(@dirs);
}
sub f_path {
    my $dir = shift;
    my $file = shift ;
    use File::Spec; 
    return File::Spec->catpath('', $dir, $file);
}
sub f_exists {
    my $path = shift;
    if ( -e $path ) { return 1 } 
    else { return 0 }
}
sub d_exists {
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
    if ( $v == 0 ){
        $ARGV[0];
    }elsif ( $v == '' ){
        @ARGV;
    }else{
        $ARGV[$v];
    }
}

sub scriptpath {
    use Cwd 'abs_path';
    return abs_path($0);
}
sub scriptname {
    use File::Basename;
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
    open my $handle, '<', $p;
    chomp(my @lines = <$handle>);
    close $handle;
    return @lines;
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
