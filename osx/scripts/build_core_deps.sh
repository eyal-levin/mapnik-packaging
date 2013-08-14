set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

# icu
./build_icu.sh

# boost
./build_boost.sh

# bzip2
echo '*building bzip2'
rm -rf bzip2-${BZIP2_VERSION}
tar xf bzip2-${BZIP2_VERSION}.tar.gz
cd bzip2-${BZIP2_VERSION}
make install PREFIX=${BUILD} CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" -i -k
cd ${PACKAGES}

# zlib
echo '*building zlib*'
rm -rf zlib-${ZLIB_VERSION}
tar xf zlib-${ZLIB_VERSION}.tar.gz
cd zlib-${ZLIB_VERSION}
# no longer needed on os x with zlib 1.2.8
#if [ $UNAME = 'Darwin' ]; then
#  patch -N < ${PATCHES}/zlib-configure.diff
#fi
./configure --prefix=${BUILD}
make -j$JOBS
make install
cd ${PACKAGES}

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}

# freetype
echo '*building freetype*'
rm -rf freetype-${FREETYPE_VERSION}
tar xf freetype-${FREETYPE_VERSION}.tar.bz2
cd freetype-${FREETYPE_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG}
make -j${JOBS}
make install
cd ${PACKAGES}

# jpeg
echo '*building jpeg*'
rm -rf jpeg-${JPEG_VERSION}
tar xf jpegsrc.v${JPEG_VERSION}.tar.gz
cd jpeg-${JPEG_VERSION}
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} --disable-dependency-tracking
make -j${JOBS}
make install
cd ${PACKAGES}

# libpng
echo '*building libpng*'
rm -rf libpng-${LIBPNG_VERSION}
tar xf libpng-${LIBPNG_VERSION}.tar.gz
cd libpng-${LIBPNG_VERSION}
# NOTE: C_INCLUDE_PATH is needed for png the gcc -E usage which does not
# seem to respect CFLAGS and will fail to find zlib.h
./configure --prefix=${BUILD} --enable-static --disable-shared ${HOST_ARG} \
  --disable-dependency-tracking \
  --with-zlib-prefix=${BUILD}
make -j${JOBS}
make install
cd ${PACKAGES}

# libxml2
# TODO: https://docs.google.com/a/mapbox.com/document/d/1AcQlm_bl8TQ0n3of5udyMzIbk54712-f_8Ph9zfjIsc/pub
echo '*building libxml2*'
rm -rf libxml2-${LIBXML2_VERSION}
tar xf libxml2-${LIBXML2_VERSION}.tar.gz
cd libxml2-${LIBXML2_VERSION}
./configure --prefix=${BUILD} --with-zlib=${PREFIX} \
--enable-static --disable-shared ${HOST_ARG} \
--with-icu=${PREFIX} \
--without-python \
--with-xptr \
--with-xpath \
--with-xinclude \
--with-threads \
--with-tree \
--with-catalog \
--without-legacy \
--without-iconv \
--without-debug \
--without-docbook \
--without-ftp \
--without-html \
--without-http \
--without-sax1 \
--without-schemas \
--without-schematron \
--without-valid \
--without-writer \
--without-modules \
--without-lzma \
--without-readline \
--without-regexps \
--without-c14n
make -j${JOBS}
make install
cd ${PACKAGES}


if [ $UNAME = 'Darwin' ]; then
    lipo -info ${BUILD}/lib/*.a | grep arch
fi