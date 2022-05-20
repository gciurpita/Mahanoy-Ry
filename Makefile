
    Xgrs  = $(patsubst %.k, %.xgr, *.k)
    Xgrs  = lavale.xgr loop.xgr staging.xgr

%.xgr : %.k
	$^ | tee $@

# ----------------------------------------------------------
all : $(Xgrs)

# ----------------------------------------------------------
neat :
	@ rm -f *~

clean : neat
	rm -f *xgr
