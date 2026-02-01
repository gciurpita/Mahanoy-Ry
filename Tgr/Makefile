  Dir   = ../Svgs
  Svgs  = $(patsubst %.tgr, $(Dir)/%.svg, $(Tgrs))
# Svgs += $(patsubst %.trk, %.svg, $(Trks))
# Trks  = $(shell echo *trk)
  Tgrs  = $(shell echo *tgr)

%.svg : %.tgr
	tgrSvg.k $^ >  $@

# ------------------------------------------------
all : $(Svgs)
#	mv $(Svgs) ../Images
	@rm -f *~ 

all.htm : $(Svgs)
	cat $(Svgs) > $@

check :
	@echo "  Svgs: " $(Svgs)
	@echo "  Trks: " $(Trks)
	@echo "  Tgrs: " $(Tgrs)

# ------------------------------------------------
clean :
	rm -f *~ *svg
