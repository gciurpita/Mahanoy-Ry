
  Svgs  = $(patsubst %.dsc, %.svg, $(Dscs))
  Dscs  = $(shell echo *dsc)

%.bld : %.dsc
	Bin/mkBldg.k $^ | tee $@

%.bld : %.k
	$^ | tee $@

%.svg : %.bld
	Bin/bldg.k $^ > $@

%.svg : %.pts
	ptsSvg.k $^ | tee $@

# ----------------------------------------------------------
all : bldg.html

bldg.html : $(Svgs)
	@ echo "<meta http-equiv=\"refresh\" content=\"5\">" > $@
	cat $(Svgs) >> $@

check :
	@echo "  dsc: " $(Dscs)
	@echo "  svg: " $(Svgs)

clean :
	rm -f *.svg *bld *html
