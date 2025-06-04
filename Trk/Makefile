  Svgs  = $(patsubst %.trk, %.svg, $(Trks))
  Trks  = $(shell echo *trk)

%.svg : %.trk
	trkSvg.k $^ >  $@

all.htm : $(Svgs)
	cat $(Svgs) > $@
