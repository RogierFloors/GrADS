# Conda recipe

This directory is the canonical upstream Conda recipe for GrADS. It uses the
v1 `recipe.yaml` format and is built with `rattler-build`. Users should normally
install the published conda-forge package as described in the repository's
[Conda installation guide](../README_CONDA.md).

The recipe builds the tagged source archive recorded in `recipe.yaml`. Update
the version, tag, and SHA-256 together when preparing a new release.

## Prerequisites

Install the build tool in the base environment:

```bash
mamba install -n base -c conda-forge rattler-build
```

The recipe currently targets Linux and builds against dependencies supplied by
conda-forge rather than system libraries.

## Render and build

From the repository root, render the recipe and solve its dependencies without
running a build:

```bash
rattler-build build \
  --recipe conda.recipe/recipe.yaml \
  --channel conda-forge \
  --render-only \
  --with-solve
```

Build and test both outputs:

```bash
rattler-build build \
  --recipe conda.recipe/recipe.yaml \
  --channel conda-forge \
  --output-dir /tmp/grads-rattler-output
```

The build produces `grads` and `gradspy` packages. It runs
`configure`, `make`, and `make install`, then packages:

- the GrADS command-line tools;
- the Cairo, X11, GD, and dummy graphics plugins;
- `libgradspy.so` and the optional `gradspy` Python wrapper;
- the files in `data/`, installed under `$PREFIX/share/grads`;
- the plugin table and Conda activation scripts.

## Install a local build

Install the build directory as the highest-priority channel, followed by
conda-forge for runtime dependencies:

```bash
mamba install -n <environment> \
  -c /tmp/grads-rattler-output \
  -c conda-forge \
  --strict-channel-priority \
  grads=2.2.3.post1 gradspy=2.2.3.post1
```

After activating the target environment, confirm that no shared libraries are
missing and query the GrADS feature configuration:

```bash
ldd "$CONDA_PREFIX/bin/grads" | grep "not found" || true
printf "q config\nquit\n" | grads -bl
python -c "from gradspy import GrADS; print(GrADS)"
```

## Recipe implementation notes

### GRIB2 compatibility name

Conda provides the GRIB2 library as `libg2c`, while the GrADS configure check
looks for `libgrib2c`. The build script creates this compatibility symlink only
for the configure and link step. The packaged executable uses the real
`libg2c.so.0` SONAME, and the recipe declares the corresponding runtime
dependencies.

### Runtime environment

Activation scripts installed by the recipe set:

- `GADDIR` to the packaged GrADS data directory;
- `GAUDPT` to the packaged plugin table;
- `GAGPY` to the packaged `libgradspy.so`.

When testing, ensure shell functions or variables from another GrADS
installation are not taking precedence. Useful checks are:

```bash
type -a grads
printf "%s\n" "$GADDIR" "$GAUDPT" "$GAGPY"
```

### Python output

The `gradspy` wrapper is a separate output because it adds Python runtime
dependencies such as NumPy, pandas, and xarray. The native shared library stays
in the `grads` package.

## Conda-forge submission

For the initial submission, copy `recipe.yaml` and `build.sh` from this
directory into `recipes/grads` in a `conda-forge/staged-recipes` checkout.
After acceptance, the generated `grads-feedstock` repository becomes the
authoritative location for the published recipe.
