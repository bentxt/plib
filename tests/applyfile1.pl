include('plib/Plib');

applyfile ( 
  '{
    ($l) = @_;
    echo("hi $l");
   }'
, "tests/texts.txt");

