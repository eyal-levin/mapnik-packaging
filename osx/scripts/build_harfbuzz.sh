#!/usr/bin/env bash
set -e -u
set -o pipefail
mkdir -p ${PACKAGES}
cd ${PACKAGES}

HARFBUZZ_LATEST=false
HARFBUZZ_LATEST_HASH=7d5e7613ced3dd39d05df83c

echoerr 'building harfbuzz'

if [[ ${HARFBUZZ_LATEST} == true ]]; then
    if [[ ! -d harfbuzz-master ]]; then
        git clone --quiet https://github.com/behdad/harfbuzz.git harfbuzz-master
        cd harfbuzz-master
        git checkout ${HARFBUZZ_LATEST_HASH}
        git apply ${PATCHES}/harfbuzz-disable-pkg-config.diff
        NOCONFIGURE=1 ./autogen.sh
    else
        cd harfbuzz-master
        git checkout .
        git pull || true
        git checkout ${HARFBUZZ_LATEST_HASH}
        git apply ${PATCHES}/harfbuzz-disable-pkg-config.diff
        # TODO - depends on ragel
        NOCONFIGURE=1 ./autogen.sh ${HOST_ARG}
        make clean
        make distclean
    fi
else
    download harfbuzz-${HARFBUZZ_VERSION}.tar.bz2
    rm -rf harfbuzz-${HARFBUZZ_VERSION}
    tar xf harfbuzz-${HARFBUZZ_VERSION}.tar.bz2
    cd harfbuzz-${HARFBUZZ_VERSION}
    patch -N -p1 < ${PATCHES}/harfbuzz-${HARFBUZZ_VERSION}.diff
fi


FREETYPE_CFLAGS="-I${BUILD}/include/freetype2"
FREETYPE_LIBS="-L${BUILD}/lib -lfreetype -lz"
CXXFLAGS="${CXXFLAGS} ${FREETYPE_CFLAGS}"
CFLAGS="${CFLAGS} ${FREETYPE_CFLAGS}"
LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS} ${FREETYPE_LIBS}"
./configure --prefix=${BUILD} ${HOST_ARG} \
 --enable-static --disable-shared --disable-dependency-tracking \
 --with-icu=no \
 --with-cairo=no \
 --with-glib=no \
 --with-gobject=no \
 --with-graphite2=no \
 --with-freetype \
 --with-uniscribe=no \
 --with-coretext=no
$MAKE -j${JOBS} V=1
$MAKE install
cd ${PACKAGES}
