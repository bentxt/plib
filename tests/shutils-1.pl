include('plib.sl');

@stuff = ls('/usr/local/');
foreach $i  (@stuff){
    echo($i);
}

