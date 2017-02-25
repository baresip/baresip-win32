#
# Makefile
#
# Copyright (C) 2010 - 2016 Creytiv.com
#

OS        := $(shell uname -s | tr "[A-Z]" "[a-z]")

ifeq ($(OS),linux)
	TUPLE   := i586-mingw32msvc
endif
ifeq ($(OS),darwin)
	TUPLE	:= i386-mingw32
endif


# Tools
SYSROOT   := /opt/local/$(TUPLE)
CC        := $(TUPLE)-gcc
CXX       := $(TUPLE)-g++
RANLIB    := $(TUPLE)-ranlib
AR        := $(TUPLE)-ar
PWD       := $(shell pwd)
WINE      := wine


# Compiler and Linker Flags
#

CFLAGS    := -DFD_SETSIZE=1024 \
	-isystem $(PWD)/openssl/include

LFLAGS    := -L$(SYSROOT)/lib/ \
	-L$(PWD)/openssl \
	-L$(PWD)/rem

# workaround for linker order (note, the order is important)
LIBS	:= -lrem -lssl -lcrypto -lwsock32 -lws2_32 -liphlpapi -lwinmm \
	-lgdi32 -lcrypt32


COMMON_FLAGS := CC=$(CC) \
		CXX=$(CXX) \
		RANLIB=$(RANLIB) \
		EXTRA_CFLAGS="$(CFLAGS)" \
		EXTRA_LFLAGS="$(LFLAGS)" \
		LIBS="$(LIBS)" \
		SYSROOT=$(SYSROOT) \
		SYSROOT_ALT= \
		HAVE_GETOPT=1 \
		HAVE_LIBRESOLV= \
		HAVE_RESOLV= \
		HAVE_PTHREAD= \
		HAVE_PTHREAD_RWLOCK= \
		HAVE_LIBPTHREAD= \
		HAVE_INET_PTON=1 \
		HAVE_INET6=1 \
		PEDANTIC= \
		OPT_SIZE=1 \
		OS=win32 \
		USE_OPENSSL=yes \
		USE_OPENSSL_DTLS=yes \
		USE_OPENSSL_SRTP=yes \
		USE_ZLIB=

OPENSSL_FLAGS := \
	threads \
	\
	no-bf \
	no-camellia \
	no-capieng \
	no-cast \
	no-comp \
	no-dso \
	no-engine \
	no-gost \
	no-heartbeats \
	no-idea \
	no-md2 \
	no-md4 \
	no-mdc2 \
	no-psk \
	no-rc2 \
	no-rc4 \
	no-rc5 \
	no-ripemd \
	no-sctp \
	no-seed \
	no-shared \
	no-srp \
	no-ssl2 \
	no-ssl3 \


default:	retest baresip

libre.a: Makefile
	@rm -f re/libre.*
	make $@ -C re $(COMMON_FLAGS)

librem.a:	Makefile libre.a
	@rm -f rem/librem.*
	@make $@ -C rem $(COMMON_FLAGS)

.PHONY: retest
test: retest
retest:		Makefile librem.a libre.a
	@rm -f retest/retest
	make -C retest $(COMMON_FLAGS) LIBRE_SO=$(PWD)/re \
		LIBREM_PATH=$(PWD)/rem
	cd retest && $(WINE) retest -r

.PHONY: baresip
baresip:	Makefile librem.a libre.a
	@rm -f baresip/baresip.exe baresip/src/static.c
	PKG_CONFIG_LIBDIR="$(SYSROOT)/lib/pkgconfig" \
	make selftest.exe baresip.exe -C baresip $(COMMON_FLAGS) STATIC=1 \
		LIBRE_SO=$(PWD)/re LIBREM_PATH=$(PWD)/rem
	cd baresip && $(WINE) selftest.exe && cd ..

.PHONY: openssl
openssl:
	cd openssl && \
		CC=$(CC) RANLIB=$(RANLIB) AR=$(AR) \
		./Configure mingw $(OPENSSL_FLAGS) && \
		make build_libs

clean:
	make distclean -C baresip
	make distclean -C retest
	make distclean -C rem
	make distclean -C re

info:
	make $@ -C re $(COMMON_FLAGS)

dump:
	@echo "TUPLE = $(TUPLE)"
	@echo "WINE  = $(WINE)"
