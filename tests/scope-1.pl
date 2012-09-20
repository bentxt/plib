include('plib.sl');

$x = 22222;

sub scopee {
   $x =  my($x);
   echo($x);
   $x = arg(0,@_);
   echo($x);
}

scopee(4444);
$x = 3333;
scopee(4444);


