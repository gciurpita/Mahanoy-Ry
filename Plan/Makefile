
	Trks = corner.trk penn.trk shelf.trk wall.trk water.trk

%.xgr : %.trk
	track.k $^ | tee $@

%.xgr : %.k
	$^ | tee $@
	xgraph -ng -monitor_files 5 penn.xgr &

# ----------------------------------------------------------
all.xgr : $(Trks)
	track.k $(Trks) | tee $@

# ----------------------------------------------------------
neat :
	@ rm -f *~
	@ echo $(Trks)

clean : neat
	rm -f $(Xgrs) all.xgr
