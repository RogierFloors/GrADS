# Conda-forge staging notes

This directory contains a staged-recipes-ready recipe for submitting GrADS to
conda-forge.

## Recommended submission flow

1. Commit `src/gradspy.py`, then create a release tag that includes the conda
   build fixes and the Python wrapper. The existing `v2.2.3` tag points at
   `master`, not the current `conda_build` branch. Prefer a new tag such as
   `v2.2.3.post1` or `v2.2.4`.

2. Update `recipes/grads/meta.yaml`:
   - set `version` to the release version
   - replace `commit` with the tag, or change the URL to a tag archive
   - update `sha256`
   - confirm `extra: recipe-maintainers`

3. Fork `conda-forge/staged-recipes`, copy `conda-forge/recipes/grads` into
   the fork's `recipes/grads`, and open a pull request.

4. Watch the CI logs. The first likely review points are the strict pins on
   `libnetcdf` and `g2clib`, Linux-only support, and whether `gradspy` should
   remain a separate output.

To compute the SHA256 for a GitHub archive:

```bash
curl -fL https://github.com/RogierFloors/GrADS/archive/<tag-or-commit>.tar.gz -o /tmp/grads.tar.gz
openssl sha256 /tmp/grads.tar.gz
```
