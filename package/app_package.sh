#!/usr/bin/env bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

VERSION=$1
if [ -z "$VERSION" ]; then
  VERSION=$(cat "${DIR}/../VERSION")
else
  shift
fi

./app_build.sh

echo
echo "PACKAGING motp:${VERSION}"
echo


DSTPATH="${DIR}/distr"
SRCDIR="$DSTPATH/bin"

# https://www.internalpointers.com/post/build-binary-deb-package-practical-guide
function package_deb() {
  ARCH=$1
  DSTPATH=$2
  DSTDIR="${DSTPATH}/motp_${VERSION}_${ARCH}"
  mkdir -p "$DSTDIR/DEBIAN"
  #install -d "${DSTDIR}/etc/motp"
  install -d "${DSTDIR}/usr/local/bin"
  #install -d "${DSTDIR}/etc/systemd/system"
  #install -m 0644 "${DIR}/debian/mbridge.service"  "${DSTDIR}/etc/systemd/system/mbridge.service"
  #install -m 0644 "${DIR}/../conf/channels.json"     "${DSTDIR}/etc/mbridge/channels.json"
  #install -m 0644 "${DIR}/../conf/logger.json"       "${DSTDIR}/etc/mbridge/logger.json"
  install -m 0755 "${SRCDIR}/linux/${ARCH}/motp" "${DSTDIR}/usr/local/bin/motp"
  {
    echo "Package: motp"
    echo "Version: ${VERSION}"
    echo "Architecture: ${ARCH}"
    echo "Maintainer: Mikhail Kantur <mkantur@gmail.com>"
    echo "Description: modbus-to-http bridging service"
    echo "Depends: systemd"
    echo ""
  } > "$DSTDIR/DEBIAN/control"
  install -m 755 "${DIR}/debian/motp.postinst" "$DSTDIR/DEBIAN/postinst"
  install -m 755 "${DIR}/debian/motp.postrm"   "$DSTDIR/DEBIAN/postrm"
  dpkg-deb --build --root-owner-group "${DSTDIR}"
  rm -rf "${DSTDIR}"
}
function package_tgz() {
  OS=$1
  ARCH=$2
  DSTPATH=$3
  DSTFILE="motp_${VERSION}_${OS}_${ARCH}.tgz"
  cd "${SRCDIR}/${OS}/${ARCH}"    && \
  tar cvfz "${DSTFILE}" motp      && \
  mv "${DSTFILE}" "${DSTPATH}"
}
function package_zip() {
  OS=$1
  ARCH=$2
  DSTPATH=$3
  DSTFILE="motp_${VERSION}_${OS}_${ARCH}.zip"
  cd  "${SRCDIR}/${OS}/${ARCH}"   && \
  zip "${DSTFILE}" motp           && \
  mv  "${DSTFILE}" "${DSTPATH}"
}
package_deb amd64         "${DSTPATH}"
package_deb armhf         "${DSTPATH}"
package_deb armhf64       "${DSTPATH}"
package_tgz macos x86_64  "${DSTPATH}"
package_tgz macos m1      "${DSTPATH}"
package_zip win   x86_64  "${DSTPATH}"
package_zip win   x86     "${DSTPATH}"
