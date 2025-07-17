
all : cards.htm

cards.htm : mahanoy.loc mahanoy.car cards.k
	cards.k mahanoy.loc mahanoy.car | tee $@


clean :
	rm -f *~ *htm
