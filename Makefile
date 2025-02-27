MIX = mix

LIBTOOL ?= libtool
ERLANG_PATH ?= $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I"$(ERLANG_PATH)"
CFLAGS += -I c_src/secp256k1 -I c_src/secp256k1/src -I c_src/secp256k1/include
CFLAGS += -I$(../libsecp256k1)/src
SECP256K1_VERSION = v0.4.0

ifneq ($(OS),Windows_NT)
CFLAGS += -fPIC
ENDING = dll
else
ENDING = so
endif

LIBSECP256K1 = c_src/secp256k1/.libs/libsecp256k1.a

ifneq (,$(HOST))
HOSTFLAG = --host=$(HOST)
endif

EXTRALIBS += $(LIBSECP256K1)

.PHONY: clean test

ifeq ($(STATIC_ERLANG_NIF),)
ifeq ($(shell uname),Darwin)
SECPLDFLAGS = -dynamiclib -undefined dynamic_lookup
endif

all: priv/libsecp256k1_nif.$(ENDING)
else
CFLAGS += -DSTATIC_ERLANG_NIF=1
CXXFLAGS += -DSTATIC_ERLANG_NIF=1

# For static libs the basename "libsecp256k1" and the nif name in ERL_NIF_INIT() must match
all: priv/libsecp256k1.a
endif

priv/libsecp256k1_nif.dll: | priv/libsecp256k1_nif.so
	cp  priv/libsecp256k1_nif.so  priv/libsecp256k1_nif.dll
priv/libsecp256k1_nif.so: c_src/libsecp256k1_nif.c $(EXTRALIBS)
	$(CC) $(CFLAGS) -shared -o $@ c_src/libsecp256k1_nif.c $(EXTRALIBS) $(SECPLDFLAGS)

c_src/libsecp256k1_nif.o: $(EXTRALIBS)
priv/libsecp256k1.a: c_src/libsecp256k1_nif.o
	$(LIBTOOL) -static -o $@ c_src/libsecp256k1_nif.o $(EXTRALIBS)

$(LIBSECP256K1): c_src/secp256k1/Makefile
	$(MAKE) -C c_src/secp256k1

.PHONY: c_src/secp256k1/Makefile
c_src/secp256k1/Makefile:
	if [ ! -d c_src/secp256k1 ]; then \
		cd c_src && git clone https://github.com/bitcoin/secp256k1; \
	else \
		cd c_src/secp256k1 && git fetch origin; \
	fi
	cd c_src/secp256k1 && git reset --hard $(SECP256K1_VERSION) && ./autogen.sh && ./configure --disable-shared --enable-module-recovery $(HOSTFLAG) CFLAGS="$(CFLAGS)";

test:
	$(MIX) eunit

clean:
	$(MIX) clean
	if [ -d c_src/secp256k1 ]; then \
		$(MAKE) -C c_src/secp256k1 clean; \
	fi
	$(RM) priv/libsecp256k1_nif.so
