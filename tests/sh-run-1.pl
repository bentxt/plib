include('plib.sl');

@lines =  run('cat /etc/hosts');
foreach $i  (@lines){
    echo($i);
}

