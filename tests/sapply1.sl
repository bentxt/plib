include("plib/Plib");

@foo = ( 
  '{apply( \'{
      ($l) = @_; 
      echo("hi $l"); }\', 
    @("hoo"))}'); 
#@foo = ( '{apply( '{($l) = @_; echo("hi $l"); }', '{list('one', 'two', 'three')}')}'); 


ccc(@foo);

