
	Trks = corner.trk penn.trk shelf.trk wall.trk water.trk
	Trk2 = corner.trk penn.trk shelf7.trk wall.trk water.trk
	Trk3 = corner.trk  shelf8.trk wall.trk

%.xgr : %.trk
	track.k $^ | tee $@

%.xgr : %.k
	$^ | tee $@
	xgraph -ng -monitor_files 5 penn.xgr &

# ----------------------------------------------------------
all.xgr : $(Trks)
	track.k $(Trks) | tee $@

all2.xgr : $(Trk2)
	track.k $(Trk2) | tee $@

all3.xgr : $(Trk3)
	track.k $(Trk3) | tee $@

# ----------------------------------------------------------
neat :
	@ rm -f *~
	@ echo $(Trks)

clean : neat
	rm -f $(Xgrs) all.xgr
