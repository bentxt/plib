include('Plib');

@l = cycle('{
  ($l) = @_;
  echo("hello: $l");
  return $l;
  }', fileiter("suite/test.txt"));

$x = iterator(
  'my ($arg) =  @_;
   my $gen = fileiter($arg);
  ',
 ' if($i = $gen->())  {
        chomp($i);
        return $i;
       }else{
      return undef;
    }
' , "suite/test.txt");


my $y = iter('{
   ($l) = @_;
   return "gugu: $l";
   }', fileiter("suite/test.txt"));

 @x = cycle('{
   ($l) = @_;
   echo("hello: $l");
   return $l;
   }', $x);
 echo(@x);

echo($y->());
