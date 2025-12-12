
	Alls = corner.trk penn.trk shelf.trk wall.trk water.trk
	All2 = corner.trk penn.trk shelf7.trk wall.trk water.trk
	All3 = corner.trk  shelf8.trk wall.trk
	All4 = corner.trk penn.trk shelf9.trk wall.trk water.trk
	Stove =            stgB.trk wall.trk
	Corner= corner.trk          shelf8a.trk

%.svg : %.trk
	trkSvg.k $^ | tee $@

%.xgr : %.trk
	track.k $^ | tee $@

%.xgr : %.k
	$^ | tee $@
	xgraph -ng -monitor_files 5 penn.xgr &

# ----------------------------------------------------------
all.xgr : $(Alls)
	track.k $(Alls) | tee $@

all2.xgr : $(All2)
	track.k $(All2) | tee $@

all3.xgr : $(All3)
	track.k $(All3) | tee $@

all4.xgr : $(All4)
	track.k $(All4) | tee $@

stove.xgr : $(Stove)
	track.k $(Stove) | tee $@

corner.xgr : $(Corner)
	track.k $(Corner) | tee $@

# ----------------------------------------------------------
neat :
	@ rm -f *~
	@ echo $(Alls)

clean : neat
	rm -f $(Xgrs) all.xgr
