#
# Makefile
#
# Copyright (C) 2010 - 2020 Alfred E. Heggestad
#


#
# To build with 32-bit toolchain:
#
# make TUPLE=i686-w64-mingw32
#

OS        := $(shell uname -s | tr "[A-Z]" "[a-z]")

ifeq ($(OS),linux)
	TUPLE   := x86_64-w64-mingw32
endif
ifeq ($(OS),darwin)
	TUPLE	:= x86_64-w64-mingw32
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

CFLAGS    := \
	-Werror \
	-DFD_SETSIZE=2048 \
	-g -gstabs \
	-isystem $(PWD)/openssl/include

LFLAGS    := \
	-g -gstabs \
	-L$(SYSROOT)/lib/ \
	-L$(PWD)/openssl \
	-L$(PWD)/rem

# workaround for linker order (note, the order is important)
LIBS	:= -lrem -lssl -lcrypto -lwsock32 -lws2_32 -liphlpapi -lwinmm \
	-lgdi32 -lcrypt32 \
	-lstrmiids -lole32 -loleaut32 -static -lstdc++ -lpthread -lqwave


COMMON_FLAGS := CC=$(CC) \
		CXX=$(CXX) \
		RANLIB=$(RANLIB) \
		EXTRA_CFLAGS="$(CFLAGS)" \
		EXTRA_LFLAGS="$(LFLAGS)" \
		LIBS="$(LIBS)" \
		SYSROOT=$(SYSROOT) \
		RELEASE=1 \
		OS=win32

EXTRA_MODULES := \
	aubridge \
	aufile \
	dshow \
	fakevideo


OPENSSL_FLAGS := \
	threads \
	\
	no-async \
	no-bf \
	no-blake2 \
	no-camellia \
	no-capieng \
	no-cast \
	no-comp \
	no-dso \
	no-engine \
	no-gost \
	no-idea \
	no-md2 \
	no-md4 \
	no-mdc2 \
	no-psk \
	no-rc2 \
	no-rc4 \
	no-rc5 \
	no-sctp \
	no-seed \
	no-shared \
	no-srp \
	no-ssl3 \


default:	retest baresip

libre.a: Makefile
	@rm -f re/libre.*
	cmake \
		-S re \
		-B re/build \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/cmake/mingw-w64-x86_64.cmake \
		-DOPENSSL_ROOT_DIR=$(PWD)/openssl
	cmake --build re/build --target re -j4


librem.a:	Makefile libre.a
	@rm -f rem/librem.*
	cmake \
		-S rem \
		-B rem/build \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/cmake/mingw-w64-x86_64.cmake
	cmake --build rem/build --target rem -j4


.PHONY: retest
retest:		Makefile librem.a libre.a
	@rm -f retest/retest.exe
	cmake \
		-S retest \
		-B retest/build \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/cmake/mingw-w64-x86_64.cmake \
		-DOPENSSL_ROOT_DIR=$(PWD)/openssl
	cmake --build retest/build -j4


.PHONY: baresip
baresip:	Makefile librem.a libre.a
	@rm -f baresip/baresip.exe baresip/src/static.c
	PKG_CONFIG_LIBDIR="$(SYSROOT)/lib/pkgconfig" \
	cmake \
		-S baresip \
		-B baresip/build \
		-DCMAKE_TOOLCHAIN_FILE=$(PWD)/cmake/mingw-w64-x86_64.cmake \
		-DOPENSSL_ROOT_DIR=$(PWD)/openssl \
		-DSTATIC=YES
	cmake --build baresip/build -j4


.PHONY: openssl
openssl:
	cd openssl && \
		CC=$(CC) RANLIB=$(RANLIB) AR=$(AR) \
		./Configure mingw64 $(OPENSSL_FLAGS) && \
		$(MAKE) build_libs

clean:
	for p in baresip retest rem re; do \
		rm -f $$p/build/* ; \
	done

info:
	$(MAKE) $@ -C re $(COMMON_FLAGS)

dump:
	@echo "TUPLE = $(TUPLE)"
	@echo "WINE  = $(WINE)"

.PHONY: test
test: retest baresip
	cd retest && $(WINE) retest -r
	cd baresip && $(WINE) selftest.exe
