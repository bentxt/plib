include('plib.sl');

$otext = 'hoo xx haa';

$rx = '(\w*) xx (\w*)';

$res = grep($otext, $rx);

if ( $res ){
    echo("success");
} else {
    echo("doesn't grep");
}


