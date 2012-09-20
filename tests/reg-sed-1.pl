include('plib.sl');

$otext = 'hoo xx haa';
$rx = '(\w*) xx (\w*)';
$to = '$1 yyyyy $2';

$ntext = sed($otext, $rx, $to);

echo("orig. text: $otext");
echo("new text: $ntext");

