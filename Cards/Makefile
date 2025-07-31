
all : cards.htm

cards.htm : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car | tee $@

cards.out : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car

clean :
	rm -f *~ *htm
