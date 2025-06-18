

%.svg : %.xyz
	xyzSvg.k $^ > $@


all : ebr.svg

ebr.svg : ebr.xyz
	xyzSvg.k ebr.xyz > $@

clean :
	rm -f *.svg *bld *html
