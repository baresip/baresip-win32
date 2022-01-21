# baresip-win32
Baresip cross-compiled for Windows using MinGW-w64


## Tools to install

You need to install the MinGW-w64 compiler and Wine:

Debian/Ubuntu:

```bash
sudo apt-get install mingw-w64 wine
```

macOS using Homebrew:

```bash
brew install mingw-w64 wine
```

## Copy the source code

```bash
$ git clone https://github.com/baresip/re
$ git clone https://github.com/baresip/rem
$ git clone https://github.com/baresip/retest
$ git clone https://github.com/baresip/baresip
$ wget https://www.openssl.org/source/openssl-1.1.1m.tar.gz
$ tar -xf openssl-1.1.1m.tar.gz
$ mv openssl-1.1.1m openssl
```

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

