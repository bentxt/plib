## utils

sub scriptpath {
    return $__SCRIPT__;
}

sub scriptname {
    return getFileName( $__SCRIPT__ ) ;
}

sub argn {
    return size(@ARGV);
}
sub args {
    return @ARGV;
}
sub argv {
    return @ARGV[$1];
}

sub echo {
    $s = $1;
    println( $s);
}

## regex


sub grep{
    $text = $1;
    $regx = $2;
    if( $text ismatch $regx ) {
        return 1;
    } else{
        return 0 ;
    }
}
sub sed{
    $text = $1;
    $regx = $2;
    $tor = $3;
    $ntext = replace( $text, $regx, $tor );
    return("$ntext");
}

## shutil stuff

sub cat {
    $p = $1;
    $handle = openf($p);
    @data = readAll($handle);
    closef($handle);
    return @data;
    }

sub run {
    $cmd = $1;
    $process = exec($cmd);
    @data = readAll($process);
    closef($process);
    return @data;
}

sub list{
    return @_;
}
sub hash{
    return @_;
}

sub nth {
    ($i, @arr) = @_;
    return @arr[$i];
}
sub my {
   $var = $1;                                             
   local('$var');
   return $var; 
} 



sub arg {
    ($i, @arr) = @_;

    return @arr[$i+1];
}

sub clos{
    $closure = compile_closure('return $1 ;' );
    $cr = [$closure: $1];
    return compile_closure($cr);
}

sub clox {
    ($cref, @args) = @_;
    [$cr: @args]
}

