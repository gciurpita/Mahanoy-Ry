

%.htm : %.pts
	../Bin/ptsSvg.k $^ | tee $@

%.svg : %.xyz
	xyzSvg.k $^ > $@

# ------------------------------------------------
all : ebr.svg

.PHONY : ebr.htm
ebr.htm : ebr.pts
	../Bin/ptsSvg.k $^ | tee $@

# ------------------------------------------------
clean :
	rm -f *.svg *bld *html
