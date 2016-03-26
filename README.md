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

```base
$ wget http://www.creytiv.com/pub/re-0.4.15.tar.gz
$ wget http://www.creytiv.com/pub/rem-0.4.7.tar.gz
$ wget http://www.creytiv.com/pub/retest-0.4.8.tar.gz
$ wget http://www.creytiv.com/pub/baresip-0.4.18.tar.gz
```

... and unpack in the root directory.


## Cross-Compile the projects

```bash
$ make
```

This will cross compile all the projects for Windows and execute
the testcode using Wine.

If it works you can fiddle with the build flags for fun :)

