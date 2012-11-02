viscreen:
	viscreen "./plb tests/clos-1.pl"

clean:
	rm -f Plib Plib.pm plb 

link:
	ln -s plibs/Pl* .
	ln -s plibs/plb .
