
all : cards.htm

cards.htm : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car | tee $@

.phony : cards
cards : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car
	stats.k

clean :
	rm -f *~ *htm
