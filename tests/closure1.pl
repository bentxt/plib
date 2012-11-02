

sub cloxx {
    my $c = shift;
    my @args = @_;
    my $code = sub {eval $c};
    $code->(@args);
}


$l =  lambda( '{ my @a = @_; print @a;print "\n" }');
$ll =  '{ ($a) = @_; print $a; }';


#clox($l, 'hello');
#cloxx($ll, 'hexxo');
cc($ll, 'hexxo');

