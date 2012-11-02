include("plib/Plib");
#echo("shit");

echo(pwd());
@listing = apply ( '{
    ($l) = @_;
    echo("hi $l");
    return $l;
    }'
    , lsall(pwd()));

echo(@listing);
