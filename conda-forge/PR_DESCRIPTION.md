## Summary

This PR adds GrADS, the Grid Analysis and Display System, with a native
`grads` package and a noarch `gradspy` Python interface output.

## Upstream status and source fork

Upstream GrADS development has been inactive since 2018, following the end of
project funding and the retirement of the original developer. I contacted the
remaining upstream maintainer about this Conda work. She welcomed the effort,
explained that ongoing upstream maintenance is not currently available, and
suggested maintaining the required changes in a fork.

The recipe therefore uses the maintained `RogierFloors/GrADS` fork while
preserving the original GrADS licensing and attribution. I use GrADS in
production and am willing to maintain both this conda-forge recipe and the
compatibility changes in the source fork.

## Notes for reviewers

- Initial support is Linux-only. macOS support can be added later after the
  native dependency stack and display/print plugin loading are tested there.
- `gradspy` is split into a noarch Python output because it only installs the
  Python wrapper and depends on the native `grads` package for `libgradspy.so`.
- GRIB2 support needs a compatibility symlink: conda-forge's GRIB2 library is
  available as `libg2c`, while GrADS checks for `libgrib2c`.
- `g2clib`/`nceplibs-g2c` are left unpinned so conda-forge's global pinning and
  run exports can select the supported ABI.

## Local validation

Render-only check:

```bash
env HOME=/tmp conda build conda-forge/recipes/grads --no-anaconda-upload --output --croot /tmp/conda-bld-grads-review
```

Full build check:

```bash
env HOME=/tmp conda build conda-forge/recipes/grads --no-anaconda-upload --croot /tmp/conda-bld-grads-review
```
