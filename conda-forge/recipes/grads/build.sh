#!/bin/bash
set -ex

# nceplibs-g2c provides libg2c, but GrADS' configure check looks specifically
# in ${PREFIX}/lib for libgrib2c. The linked binaries use libg2c.so.0 through
# its SONAME, so remove this build-only compatibility link before packaging.
ln -s libg2c.so "${PREFIX}/lib/libgrib2c.so"

SUPPLIBS="${PREFIX}" ./configure \
  --prefix="${PREFIX}" \
  --with-netcdf="${PREFIX}" \
  --with-hdf5="${PREFIX}" \
  --enable-dyn-supplibs \
  CAIRO_CFLAGS="-I${PREFIX}/include/cairo -I${PREFIX}/include/freetype2" \
  CAIRO_LIBS="-L${PREFIX}/lib -lcairo" \
  GD_CFLAGS="-I${PREFIX}/include" \
  GD_LIBS="-L${PREFIX}/lib -lgd" \
  CPPFLAGS="-I${PREFIX}/include -I${PREFIX}/include/freetype2" \
  LDFLAGS="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"

make -j"${CPU_COUNT:-1}"
make install
rm -f "${PREFIX}/lib/libgrib2c.so"

find "${PREFIX}/lib" -name '*.la' -delete

mkdir -p "${PREFIX}/share/grads"
cp -r data/* "${PREFIX}/share/grads/"

cat > "${PREFIX}/share/grads/udpt" <<EOF
# Type     Name     Full path to shared object file
gxdisplay  Cairo    ${PREFIX}/lib/libgxdCairo.so
gxdisplay  X11      ${PREFIX}/lib/libgxdX11.so
gxdisplay  gxdummy  ${PREFIX}/lib/libgxdummy.so
*
gxprint    Cairo    ${PREFIX}/lib/libgxpCairo.so
gxprint    GD       ${PREFIX}/lib/libgxpGD.so
gxprint    gxdummy  ${PREFIX}/lib/libgxdummy.so
EOF

mkdir -p "${PREFIX}/etc/conda/activate.d"
mkdir -p "${PREFIX}/etc/conda/deactivate.d"

cat > "${PREFIX}/etc/conda/activate.d/grads-env.sh" <<EOF
#!/bin/bash
export GADDIR_BACKUP="\${GADDIR}"
export GAUDPT_BACKUP="\${GAUDPT}"
export GAGPY_BACKUP="\${GAGPY}"
export GADDIR="${PREFIX}/share/grads"
export GAUDPT="${PREFIX}/share/grads/udpt"
export GAGPY="${PREFIX}/lib/libgradspy.so"
EOF

cat > "${PREFIX}/etc/conda/deactivate.d/grads-env.sh" <<'EOF'
#!/bin/bash
export GADDIR="${GADDIR_BACKUP}"
export GAUDPT="${GAUDPT_BACKUP}"
export GAGPY="${GAGPY_BACKUP}"
unset GADDIR_BACKUP
unset GAUDPT_BACKUP
unset GAGPY_BACKUP
EOF
