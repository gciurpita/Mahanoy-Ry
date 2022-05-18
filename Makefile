
	Targ = lavale

%.xgr : %.k
	$^ > $@

$(Targ).xgr : lavale.k
	lavale.k > $@
