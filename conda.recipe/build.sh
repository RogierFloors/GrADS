#!/bin/bash
set -ex

# g2clib provides libg2c but GrADS configure expects libgrib2c
if [ -f "$PREFIX/lib/libg2c.so" ] && [ ! -f "$PREFIX/lib/libgrib2c.so" ]; then
  ln -s libg2c.so "$PREFIX/lib/libgrib2c.so"
fi

SUPPLIBS="$PREFIX" ./configure \
  --prefix="$PREFIX" \
  --with-netcdf="$PREFIX" \
  --with-hdf5="$PREFIX" \
  --enable-dyn-supplibs \
  CAIRO_CFLAGS="-I$PREFIX/include/cairo -I$PREFIX/include/freetype2" \
  CAIRO_LIBS="-L$PREFIX/lib -lcairo" \
  GD_CFLAGS="-I$PREFIX/include" \
  GD_LIBS="-L$PREFIX/lib -lgd" \
  CPPFLAGS="-I$PREFIX/include -I$PREFIX/include/freetype2" \
  LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

make -j"${CPU_COUNT:-1}"
make install

# Install Python interface; claimed by the grads-python noarch output
install -m 644 src/gradspy.py "$SP_DIR/gradspy.py"

# Install data files
mkdir -p "$PREFIX/share/grads"
cp -r data/* "$PREFIX/share/grads/"

# Create UDPT
cat > "$PREFIX/share/grads/udpt" <<'EOF'
# Type     Name     Full path to shared object file
gxdisplay  Cairo    %s/lib/libgxdCairo.so
gxdisplay  X11      %s/lib/libgxdX11.so
gxdisplay  gxdummy  %s/lib/libgxdummy.so
*
gxprint    Cairo    %s/lib/libgxpCairo.so
gxprint    GD       %s/lib/libgxpGD.so
gxprint    gxdummy  %s/lib/libgxdummy.so
EOF
# Replace %s placeholders with $PREFIX (escaped for sed)
sed -i "s|%s|$PREFIX|g" "$PREFIX/share/grads/udpt"

# Create conda activation/deactivation scripts
mkdir -p "$PREFIX/etc/conda/activate.d"
mkdir -p "$PREFIX/etc/conda/deactivate.d"

cat > "$PREFIX/etc/conda/activate.d/grads-env.sh" <<EOF
#!/bin/bash
export GADDIR_BACKUP="\$GADDIR"
export GAUDPT_BACKUP="\$GAUDPT"
export GAGPY_BACKUP="\$GAGPY"
export GADDIR="$PREFIX/share/grads"
export GAUDPT="$PREFIX/share/grads/udpt"
export GAGPY="$PREFIX/lib/libgradspy.so"
EOF

cat > "$PREFIX/etc/conda/deactivate.d/grads-env.sh" <<EOF
#!/bin/bash
export GADDIR="\$GADDIR_BACKUP"
export GAUDPT="\$GAUDPT_BACKUP"
export GAGPY="\$GAGPY_BACKUP"
unset GADDIR_BACKUP
unset GAUDPT_BACKUP
unset GAGPY_BACKUP
EOF
