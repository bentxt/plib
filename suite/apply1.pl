include('Plib');
@l = list(4,5,"hi");

apply('{
  echo(shift(@_));
}',@l);
