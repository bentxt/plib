package Plib;
use base qw (Exporter);
use Scalar::Util qw(looks_like_number);
use File::Find 'find';
use File::Path qw( mkpath rmtree );
use File::Copy qw( cp move );
use File::Spec::Functions qw (catfile catdir catpath splitdir splitpath); 
use File::Basename qw(basename dirname);
use List::Util qw(min max);
use Archive::Extract;
use Cwd qw(getcwd abs_path);
our @EXPORT = qw(
  readfile 
  rfile
  wfile
  afile
  apply
  applyfile
  fileiter
  iter
  iterator
  yterator
  yielditer
  yield
  cycle
  shpipe 
  untar
  list 
  hash 
  echo  
  prn 
  mv
  wget
  include 
  lambda 
  clox 
  cc
  ccc
  arg 
  setasub 
  fun 
  lsall 
  lsdirs 
  nth 
  cat 
  reader 
  head 
  ln_s
  cd
  sedish replace  extract grepstr etch sh scriptpath scriptname args argv ispath isdir isfile path getenv envar redir basename d_name f_ext filename filext size tostr str find catdir catpath catfile splitdir  splitpath basename dirname ls_r matches cp cp_r min max rm trim writefile pwd mkpath rm_rf mkdir_p touch hopper);

## base


sub getenv {
  my $t = shift;
  return $ENV{$t};
}

sub path {
  my @p = @_;
  my $f = catfile(@p);
  chomp($f);
  $f=trim($f);
  return $f;
}

sub size {
    my @arr = @_;
    my $size = $#arr + 1;
    return $size;
}

sub str{
    my @lns = @_;
    my $str = join('',@lns);
    chomp($str);
    return $str;
}

# shell

sub rm_rf {
  my $dir = shift;
  rmtree($dir, 0, 0);
}

sub mkdir_p {
  my $dir = shift;
  File::Path::mkpath($dir,0,0777);
}

sub cd {
  my $dir = shift;
  chdir $dir;
}

sub pwd {
  return Cwd::getcwd;
}

sub ln_s {
  my $src = shift;
  my $tgt = shift;

 # On systems that don't support symbolic links, raises an exception. To check for that, use eval:

  $symlink_exists = eval { symlink("",""); 1 };
  if ($symlink_exists){
    symlink($src,$tgt);
  } else{
    die "ERR: symlink not supported on this system";
  }
}

*mv = \&move;
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
    if ( $op eq '>>' ){
        open my $handle, '>>', $f;
        print $handle @c;
        close $handle;
    }elsif ( $op eq '>' ){
        open my $handle, '>', $f;
        print $handle @c;
        close $handle;
    } elsif ( $op eq '<' ){
        open my $handle, '<', $f;
        chomp(my @lines = <$handle>);
        close $handle;
        if (size (@lines) == 1 ){
          return str(@lines);
        } elsif ( @lines >= 1 ){
          return @lines;
        } else{
          return 0;
        }
    } else{
        die ("ERR: Couldn't redirect");
    }
}

sub appendr{
    my $op = shift;
    my $f = shift;
    my @c = @_;
    open my $handle, '>>', $f;
    print $handle @c;
    close $handle;
}
sub writefile{
    my $f = shift;
    my @c = @_;
    open my $handle, '>', $f;
    print $handle @c;
    close $handle;
}

sub touch {
  my $file = shift;
  open(FILE,">>$file") || die "Cannot write $file:$!";
  close(FILE);
  utime($t,$t,$file);
}




sub rfile {
    my $f = shift;
    my @c = @_;
    open my $handle, '<', $f;
    chomp(my @lines = <$handle>);
    close $handle;
    if (size (@lines) == 1 ){
      return str(@lines);
    } elsif ( @lines >= 1 ){
      return \@lines;
    } else{
      return 0;
    }
}
sub applyfile {
  my $codetxt = shift;
  my $fname = shift;
  my $code = sub {eval $codetxt};
  open ( my $fh, '<', $fname );
  my @result = ();
    while  (<$fh>)  {
    # Create copy so $_ can be modified safely.
       for (my $s = $_) {
         chomp($s);
          push @result, $_ if $code->($s);
       }
  }
  close $fh;
  return @result;
}
 sub yield {
   my $ctxt = shift;
   my $code = sub {eval $ctxt};
 return $ctxt;
}

sub iterator {
  my $ctx = shift;
  my $funtxt = shift;
  my $arg = shift;
  my $codetxt =  $ctx . 'return sub {' . $funtxt . '}';
use Data::Dumper;
  my $code = sub { eval $codetxt };
  my $gen = $code->($arg);
  return sub {
    my $i;
    if($i = $gen->())  {
        chomp($i);
        return ($i);
       }else{
      return undef;
    }
  }
}

sub iter {
  my $ctxt = shift;
  my $gen = shift;
  my $code = sub {eval $ctxt};
  my ($current_state, $done);
  return sub {
    if($i = $gen->())  {
        chomp($i);
        return $code->($i);
       }else{
      return undef;
    }
  }
}
sub cycle {
  my $ctxt = shift;
  my $gen = shift;
  my $code = sub {eval $ctxt};
  my @result = ();
  my $res ;
  while  (my $i = $gen->())  {
      chomp($i);
      $res = $code->($i);
      push @result,  $res;
     }
  return \@result;
}

sub fileiter {
  my $fname = shift;
    open ( my $fh, '<', $fname );
    my ($current, $done);
    return sub {
      my $code = shift;
      my $next;
      if($next = <$fh>){
        return $current = $next; 
      } else{
        close $fh;
        return undef ;
      }
  }
}

sub applyx (&$){
  my $code = shift;
  my $arg = shift;

  if (-f $arg) {
    my $fname = $arg;
    open ( my $fh, '<', $fname );
    my @result = ();
    while  (<$fh>)  {
    # Create copy so $_ can be modified safely.
       for (my $s = $_) {
          push @result, $_ if $code->();
       }
  }
  close $fh;
  return @result;
  }
}
sub ls_r{
    my $dir = shift;
    my @list;
    my $clos = sub { push(@list, $File::Find::name)};
    find($clos, $dir);
    return @list;
}

sub rm {
    unlink @_;
}
sub cp_r{
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

sub grepish2{
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
sub sedish2{
    my $regx= shift;
    my $cr = shift;
    my $text =shift; 

    my $tor=q("). $cr . q(");
    my $regto = sub { eval $tor } ;
    $text =~ s/$regx/$regto->()/e ;
    #$text =~ s/> url: //g ;
    return $text;
}
sub sedish{
    my $ln = shift;
    my $regx= shift;
    my $cr = shift;

    my $tor=q("). $cr . q(");
    my $regto = sub { eval $tor } ;
    $ln =~ s/$regx/$regto->()/e ;
    return $ln;
}
sub extract {
    my $regx= shift;
    my @lns = @_;

    
    my @res = ();
    my @r = '';
    foreach $l (@lns){
      if ($l =~ /$regx/){ 
        @r = ($l =~ /$regx/) ;
        push(@res,$r[0]);
      }
    }
    if (size (@res) == 1 ){
      return str(@res);
    } elsif ( @res >= 1 ){
      return @res;
    } else{
      return undef;
    }
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
    return \@_;
}
sub lst2str {
  my $lref = shift;

  my $sep = shift;
  $sep = ' ' unless $sep;
  my $str = join($sep, @{$lref});
  return $str;
}

sub hash{
    return @_;
}
sub echo{
  my $arg = shift;
  my $str ='@(';
  if(ref($arg) eq 'ARRAY') {
    my $fst  ;
    foreach $s (@$arg){
      if ($fst){
        if(looks_like_number($s)){
          $str = $str . ", " . $s ;
        }else{
          $str = $str . ", '" . $s . "'";
        }
      } else{
        if(looks_like_number($s)){
          $str = $str .  $s ;
        }else{
          $str = $str . "'" . $s . "'";
        }
      }
      $fst = 1;
    }
    print( $str . ')' . "\n");
  } else {
    print "$arg\n";
  }
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
    if (size (@outp) == 1 ){
      return str(@outp);
    } elsif ( @outp >= 1 ){
      return @outp;
    } else{
      return 0;
    }
}
sub cmd {
    my $cmd = shift;
    my @outp=();
    @outp=`$cmd `;
    die "This command failed: $incmd \n"  unless (($?>>8)==0);
    if (size (@outp) == 1 ){
      return str(@outp);
    } elsif ( @outp >= 1 ){
      return @outp;
    } else{
      return 0;
    }
}

sub envar {
    my $cmd = shift;
    if ( $cmd == 'HOME'){
        my @r = sh('printf $HOME');
        return $r[0]; 
    }
}

sub trim{
  my $string = shift;
  my $l = length($string);
  $string = reverse unpack("A$l",reverse unpack("A$l",$string));
  return $string;
}

sub lsall {
    my $path = shift;
    $path = trim($path);

  opendir(DIR, $path);
  @files = grep !/^\.\.?$/, readdir(DIR);
  closedir(DIR);

    return \@files;

}
sub lsdirs {
    my $path = shift;
    $path = trim($path);

  opendir(DIR, $path);
  @files = grep !/^\.\.?$/, readdir(DIR);
  my @dirs = grep -d $_, @files;
  closedir(DIR);
    return \@dirs;
}

sub reader{
    my $p = shift;
}
sub cat {
    my $fname = shift;
    open my $fh, '<', $fname;
    while (<$fh>) {
      print;
    }
    close $fh;
    # my $document = do {
    #     local $/ = undef;
    #     open my $fh, "<", $p or die "could not open $p: $!";
    #     <$fh>;
    # };
    #return $document;
}

#sub head {
#    my $p = shift;
#    open my $handle, '<', $p;
#    chomp(my @lines = <$handle>);
#    close $handle;
#    return $lines[0];
#}



## Closure stuff
sub arg {  ## because in sleep we have to diff
    my $i = shift;
    my @l = @_;
    return $l[$i];
}

sub lambda {
    my $c=shift;
    return sub { eval $c  };
}
sub cloxx {
    my $c = shift;
    my @args = @_;
    my $code = sub {eval $c};
    $code->(@args);
}

sub cc {
    my $c = shift;
    my @args = @_;
    my $code = sub {eval $c};
    $code->(@args);
}
sub ccc {
  my @exprs = @_;
  foreach $e (@exprs){
    cc($e);
  }
}


sub clox {
    my $c = shift;
    my @args = @_;
    $c->(@args);
}
sub apply {
  my $c = shift;
  my $arg = shift;
    my $code = sub {eval $c};
    if(ref($arg) eq 'ARRAY') {
      [ map { $code->($_) } @{ $arg }];
    }else{
      [ $code->($arg)] ;
    }
}
sub seq {
  my @exprs = shift;
  eval @exprs;
}

# web
sub wget {
  my $url = shift;
  my $file = shift;

  use LWP::Simple;

  if(isfile($file)){
    die "ERR: File $file already exist";
  }
 
  my $status = mirror($url, $file);
  #my $status = getstore($url, $file);
 
  if ( is_success($status) ) {
    return $file;
  }
  else {
    die "error downloading file: $status\n";
  }
}

sub untar {
  my $fname = shift;
  my $x = Archive::Extract->new( archive => $fname );
  $x->extract( to => '.' ) or die $x->error;
}
  
1;

