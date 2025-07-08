
  Svgs  = $(patsubst %.dsc, %.svg, $(Dscs))
  Dscs  = $(shell echo *dsc)

%.bld : %.dsc
	Bin/mkBldg.k $^ | tee $@

%.bld : %.k
	$^ | tee $@

%.svg : %.bld
	Bin/bldg.k $^ | tee $@

%.svg : %.pts
	Bin/ptsSvg.k $^ | tee $@

# ----------------------------------------------------------
all : bldg.html foundry.htm

bldg.html : $(Svgs)
	@ echo "<meta http-equiv=\"refresh\" content=\"5\">" > $@
	cat $(Svgs) >> $@

.PHONY : foo.svg
foo.svg : foo.dsc
	mkBldg.k      foo.dsc  | tee foo.bld
	bldg.k        foo.bld  | tee $@

.PHONY : foundry.htm
foundry.htm : foundry.pts Bin/ptsSvg.k
	Bin/ptsSvg.k foundry.pts | tee $@

.PHONY : test.htm
test.htm : test.bld Bin/bldg.k
	bldg.k test.bld | tee $@

window :
	windows.k | bldg.k | tee windows.svg

# ----------------------------------------------------------
check :
	@echo "  dsc: " $(Dscs)
	@echo "  svg: " $(Svgs)

# ----------------------------------------------------------
clean :
	rm -f  *bld *htm *html *.svg
