## Summary

This PR adds GrADS, the Grid Analysis and Display System, with a native
`grads` package and a noarch `gradspy` Python interface output.

## Notes for reviewers

- Initial support is Linux-only. macOS support can be added later after the
  native dependency stack and display/print plugin loading are tested there.
- `gradspy` is split into a noarch Python output because it only installs the
  Python wrapper and depends on the native `grads` package for `libgradspy.so`.
- GRIB2 support needs a compatibility symlink: conda-forge's GRIB2 library is
  available as `libg2c`, while GrADS checks for `libgrib2c`.
- `g2clib`/`nceplibs-g2c` are pinned for the initial package because the build
  depends on their library naming and ABI.

## Local validation

Render-only check:

```bash
env HOME=/tmp conda build conda-forge/recipes/grads --no-anaconda-upload --output --croot /tmp/conda-bld-grads-review
```

Full build check:

```bash
env HOME=/tmp conda build conda-forge/recipes/grads --no-anaconda-upload --croot /tmp/conda-bld-grads-review
```
