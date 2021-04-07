################################
### FreeSwitch headers files found in libfreeswitch-dev ###
FS_INCLUDES=/usr/include/freeswitch
FS_MODULES=/usr/lib/freeswitch/mod
################################

### END OF CUSTOMIZATION ###
SHELL := /bin/bash
PROC?=$(shell uname -m)

CFLAGS=-fPIC -O3 -fomit-frame-pointer -fno-exceptions -Wall -std=c99 -pedantic

INCLUDES=-I/usr/include -Ibcg729/include -I$(FS_INCLUDES)
LDFLAGS=-lm -Wl,-static -Lbcg729/src/.libs -lbcg729 -Wl,-Bdynamic

all : mod_bcg729.o
	$(CC) $(CFLAGS) $(INCLUDES) -shared -Xlinker -x -o mod_bcg729.so mod_bcg729.o $(LDFLAGS)

mod_bcg729.o: bcg729 mod_bcg729.c
	$(CC) $(CFLAGS) $(INCLUDES) -c mod_bcg729.c

clone_bcg729:
	if [ "$(ls -A bcg729 2> /dev/null)" == "" ]; then \
		git submodule update --init; \
	fi

bcg729: clone_bcg729
	cd bcg729 && cmake . && make && cd ..

clean:
	rm -f *.o *.so *.a *.la; cd bcg729 && make clean; cd ..

distclean: clean

install: all
	/usr/bin/install -c mod_bcg729.so $(INSTALL_PREFIX)/$(FS_MODULES)/mod_bcg729.so
