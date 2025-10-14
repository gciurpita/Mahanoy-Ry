
all : cards.htm

cards.htm : cards.out
	cardsFmt.k cards.out | tee $@

.phony : cards.out
cards.out : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car | tee $@

stats : cards.out
	stats.k

clean :
	rm -f *~ *htm
