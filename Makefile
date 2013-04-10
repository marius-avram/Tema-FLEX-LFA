CC=g++
LEX=flex
LDFLAGS=-lfl
CFLAGS=-c -g
OFLAGS=-o $@
SRC=mtx.l TuringCell.cpp Symbol.cpp Util.cpp
RM=rm

mtx: mtx.o 
	$(CC) -o $@ $^ $(LDFLAGS)

mtx.o: mtx.cpp
	$(CC) $(CFLAGS) -o $@ $<

mtx.cpp: $(SRC)
	$(LEX) -o $@ $(SRC)

.PHONY: clean

clean: 
	rm *~ *.o mtx.cpp
