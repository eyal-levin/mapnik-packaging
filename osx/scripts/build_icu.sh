set -e 

mkdir -p ${PACKAGES}
cd ${PACKAGES}

echo '*building icu*'
rm -rf icu-${ARCH_NAME}
rm -rf icu
# *WARNING* do not set an $INSTALL variable
# it will screw up icu build scripts
export OLD_CPPFLAGS=${CPPFLAGS}
export OLD_LDFLAGS=${LDFLAGS}
export LDFLAGS="${STDLIB_LDFLAGS} ${LDFLAGS}"
# http://source.icu-project.org/repos/icu/icu/trunk/readme.html#RecBuild
# http://userguide.icu-project.org/packaging
# http://thebugfreeblog.blogspot.de/2013/05/cross-building-icu-for-applications-on.html
# U_CHARSET_IS_UTF8 is added to try to reduce icu library size (18.3)
export CPPFLAGS=${ICU_CPP_FLAGS}

tar xf icu4c-${ICU_VERSION2}-src.tgz
mv icu icu-${ARCH_NAME}
cd icu-${ARCH_NAME}/source
if [ $BOOST_ARCH = "arm" ]; then
    export CROSS_FLAGS="--with-cross-build=$(pwd)/../../icu-i386/source"
    export CPPFLAGS="${CPPFLAGS} -I$(pwd)/common -I$(pwd)/tools/tzcode/"
else
    export CROSS_FLAGS=""
fi
./configure ${HOST_ARG} ${CROSS_FLAGS} --prefix=${BUILD} \
--disable-samples \
--enable-static \
--disable-shared \
--with-data-packaging=archive \
--disable-tests \
--enable-tests=no \
--disable-extras \
--disable-layout \
--disable-draft \
--disable-icuio \
--disable-samples \
--disable-dyload
make -j${JOBS} -i -k
make install
export LDFLAGS=${OLD_LDFLAGS}
export CPPFLAGS=${OLD_CPPFLAGS}
cd ${PACKAGES}

if [ $UNAME = 'Darwin' ]; then
    otool -L ${BUILD}/lib/*.dylib | grep c++
fi

# clear out shared libs
rm -f ${BUILD}/lib/{*.so,*.dylib}
