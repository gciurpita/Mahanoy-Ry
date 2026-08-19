
  Blds  = $(shell echo *bld)
  Dscs  = $(shell echo *dsc)
  Ptss  = $(shell echo *pts)

  Svgs  = $(patsubst %.dsc, %.svg, $(Dscs))
  Svgs += $(patsubst %.pts, %.svg, $(Ptss))
  Svgs += $(patsubst %.bld, %.svg, $(Blds))

  Svgs2  = cloth.svg foot.svg furn.svg hard.svg meat.svg plumb.svg 
  Svgs2 += $(patsubst %.pts, %.svg, $(Ptss))
  Svgs2 += $(patsubst %.bld, %.svg, $(Blds))

%.bld : %.dsc
	Bin/mkBldg.k $^ | tee $@

%.bld : %.k
	$^ | tee $@

%.svg : %.bld
	Bin/bldg.k $^ | tee $@

%.htm : %.pln
	Bin/mkPlan.k $^ | tee $@

%.svg : %.pln
	Bin/mkPlan.k $^ | tee $@

%.svg : %.pts
	Bin/ptsSvg.k $^ | tee $@

# ----------------------------------------------------------
all2 : $(Svgs2)

all0 : bldg.html $(Svgs)

bldg.html : $(Svgs)
#	@ echo "<meta http-equiv=\"refresh\" content=\"9\">" > $@
	cat $(Svgs) >> $@

.PHONY : foo.htm
foo.htm : foo.dsc
	mkBldg.k foo.dsc | tee foo.bld | bldg.k foo.bld  | tee $@

.PHONY : foundry.htm
foundry.htm : foundry.pts Bin/ptsSvg.k
	Bin/ptsSvg.k foundry.pts | tee $@

.PHONY : test.htm
test.htm : test.bld Bin/bldg.k
	bldg.k test.bld | tee $@

window :
	Bin/windows.k | Bin/bldg.k | tee windows.svg

# ----------------------------------------------------------
check :
	@echo "  bld: " $(Blds)
	@echo "  dsc: " $(Dscs)
	@echo "  svg: " $(Svgs)

# ----------------------------------------------------------
clean :
	rm -f   *htm  *.svg *.xgr
