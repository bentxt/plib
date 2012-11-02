include('Plib');
@l = list(4,5,"hi");

@nl = apply('{
  return (shift(@_));
}',@l);

echo(@nl);
