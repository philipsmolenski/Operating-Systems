PROGRAMS = euron
CC = gcc
CFLAGS = -Wall -O2 -g

all: $(PROGRAMS)

err.o: err.c err.h

swap.o: swap.asm
	nasm -f elf64 -o $@ $<

test_reg.o: test_reg.asm
	nasm -f elf64 -o $@ $< 

euron.o: euron.asm
	nasm -DN=$(N) -f elf64 -o $@ $<

euron_main.o: euron_main.c euron_fun.h err.h
	$(CC) -c -DTHREAD_NUM=$(N) $(CFLAGS) -o $@ $<

euron: euron_main.o euron.o err.o swap.o test_reg.o
	$(CC) -pthread -o $@ $^

.PHONY: all clean

clean:
	rm -rf $(PROGRAMS) *.o