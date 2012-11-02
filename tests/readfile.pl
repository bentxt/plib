@ln = readfile "tests/texts.txt";

for $l (@ln) {
  echo "hi $l";
}
