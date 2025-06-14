  Svgs  = $(patsubst %.tgr, %.svg, $(Tgrs))
  Svgs += $(patsubst %.trk, %.svg, $(Trks))
  Trks  = $(shell echo *trk)
  Tgrs  = $(shell echo *tgr)

%.svg : %.tgr
	tgrSvg.k $^ >  $@

%.svg : %.trk
	trkSvg.k $^ >  $@

# ------------------------------------------------
all : all.htm

all.htm : $(Svgs)
	cat $(Svgs) > $@

check :
	@echo "  Svgs: " $(Svgs)
	@echo "  Trks: " $(Trks)
	@echo "  Tgrs: " $(Tgrs)

# ------------------------------------------------
clean :
	rm -f *~ *svg
