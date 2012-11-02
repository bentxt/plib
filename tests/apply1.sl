include("plib/Plib");

apply ( '{
    ($l) = @_;
    echo("hi $l");
    }'
    , list('one', 'two', 'three'));

apply ( '{
    ($l) = @_;
    echo("hi $l");
    }'
    , list(3));

apply ( '{
    ($l) = @_;
    echo("hi $l");
    }'
    , list("ou"));
