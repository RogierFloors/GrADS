# Conda-forge staging notes

This directory contains a staged-recipes-ready recipe for submitting GrADS to
conda-forge.

## Recommended submission flow

1. The recipe currently uses the `v2.2.3.post1` tag, which includes the conda
   build fixes and `src/gradspy.py`.

2. Confirm `extra: recipe-maintainers` before opening the PR.

3. Fork `conda-forge/staged-recipes`, copy `conda-forge/recipes/grads` into
   the fork's `recipes/grads`, and open a pull request.

4. Watch the CI logs. The first likely review points are Linux-only support,
   the `g2clib`/`nceplibs-g2c` pin used for GRIB2 compatibility, and whether
   `gradspy` should remain a separate output.

## Review notes

- Linux-only is intentional for the initial submission. macOS support can be
  added later once the native dependency stack and plugin loading are tested.
- `gradspy` is a separate noarch output because it is a Python interface with
  Python runtime dependencies; the native shared library remains in `grads`.
- GRIB2 support requires a compatibility symlink because conda-forge provides
  `libg2c`, while GrADS checks for `libgrib2c`.
- `g2clib`/`nceplibs-g2c` stay pinned for the initial submission because this
  build relies on their library naming and GRIB2 ABI.

To compute the SHA256 for a GitHub archive:

```bash
curl -fL https://github.com/RogierFloors/GrADS/archive/<tag-or-commit>.tar.gz -o /tmp/grads.tar.gz
openssl sha256 /tmp/grads.tar.gz
```
