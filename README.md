# baresip-win32
Baresip cross-compiled for Windows using Mingw


## Tools to install

You need to install the Mingw32-compiler and Wine:

Debian:

```bash
sudo apt-get install mingw32 wine
```

OSX Using Macports:

```bash
sudo port install i386-mingw32-gcc wine
```

## Copy the source code

```bash
$ wget https://github.com/baresip/re/archive/v1.1.0.tar.gz
$ wget https://github.com/baresip/rem/archive/v0.6.0.tar.gz
$ wget https://github.com/baresip/baresip/archive/v1.0.0.tar.gz
$ wget https://www.openssl.org/source/openssl-1.1.0e.tar.gz

$ git clone https://github.com/baresip/retest.git
```

... and unpack in the root directory.


## Cross-Compile the projects

You must build openssl first:

```bash
$ make openssl
```

```bash
$ make
```

This will cross compile all the projects for Windows and execute
the testcode using Wine.

If it works you can fiddle with the build flags for fun :)

