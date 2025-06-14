
  Svgs  = $(patsubst %.dsc, %.svg, $(Dscs))
  Dscs  = $(shell echo *dsc)

%.bld : %.dsc
	Bin/mkBldg.k $^ | tee $@

%.svg : %.bld
	Bin/bldg.k $^ > $@

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
