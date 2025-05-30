
all : cards.htm

cards.htm : lavale.loc lavale.car cards.k
	cards.k lavale.loc lavale.car | tee $@


clean :
	rm -f *~ *htm
