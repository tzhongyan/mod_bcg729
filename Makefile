################################
### FreeSwitch headers files found in libfreeswitch-dev ###
FS_INCLUDES=/home/tzhongyan/git/mod_bcg729/freeswitch-1.10.12/src/include
FS_MODULES=/usr/lib/freeswitch/mod
################################

### END OF CUSTOMIZATION ###
SHELL := /bin/bash
PROC?=$(shell uname -m)

CFLAGS=-fPIC -O3 -fomit-frame-pointer -fno-exceptions -Wall -std=c99 -pedantic
CMAKE := cmake

INCLUDES=-I/usr/include -Ibcg729/include -I$(FS_INCLUDES)
LDFLAGS=-lm -Wl,-static -Lbcg729/src/ -lbcg729 -Wl,-Bdynamic

all : mod_bcg729.o
	$(CC) $(CFLAGS) $(INCLUDES) -shared -Xlinker -x -o mod_bcg729.so mod_bcg729.o $(LDFLAGS)

mod_bcg729.o: bcg729 mod_bcg729.c
	$(CC) $(CFLAGS) $(INCLUDES) -c mod_bcg729.c

clone_bcg729:
	if [ "$(ls -A bcg729 2> /dev/null)" == "" ]; then \
		git submodule update --init; \
	fi

bcg729: clone_bcg729
	cd bcg729 && $(CMAKE) . -DENABLE_SHARED=NO -DENABLE_STATIC=YES -DCMAKE_POSITION_INDEPENDENT_CODE=YES && make && cd ..

clean:
	rm -f *.o *.so *.a *.la; cd bcg729 && make clean; cd ..

distclean: clean
	cd bcg729 && git clean -f -d && cd ..

install: all
	/usr/bin/install -c mod_bcg729.so $(INSTALL_PREFIX)/$(FS_MODULES)/mod_bcg729.so
