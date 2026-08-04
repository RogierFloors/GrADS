# Installing GrADS with Conda

The recommended way to install GrADS is the conda-forge package:

```bash
mamba create -n grads -c conda-forge grads
mamba activate grads
```

This installs the native GrADS tools and their supported libraries, including
GRIB2, NetCDF/HDF, GeoTIFF, shapefile, Cairo, and the print/display plugins.
For the optional Python interface:

```bash
mamba install -n grads -c conda-forge gradspy
```

Verify the installation with:

```bash
printf "'q config'\n'quit'\n" | grads -bl
```

The source-build instructions below are intended for package maintainers and
developers who need to build or test the recipe locally.

This branch adds conda packaging for GrADS 2.2.3. The goal is to make GrADS
build reproducibly with the native libraries it needs, then use that recipe as
the basis for a conda-forge submission.

The work has two parts:

- `conda.recipe/`: local recipe for building and testing a GrADS package from
  this checkout.
- `conda-forge/recipes/grads/`: staged-recipes-ready recipe for submission to
  conda-forge.

## What This Adds

The local conda build produces the native GrADS tools and libraries, including:

- `grads`
- `gribmap`
- `stnmap`
- `gribscan`
- `grib2scan`
- `bufrscan`
- display and print plugin libraries
- `libgradspy.so`
- `gradspy.py`, a Python interface installed as the `gradspy` output
- activation scripts that set `GADDIR`, `GAUDPT`, and `GAGPY`

The recipe builds against conda-provided dependencies instead of system
libraries. This keeps HDF5, NetCDF, GRIB2, GeoTIFF, Cairo, readline, and related
native dependencies in one isolated environment.

## Why Conda

Building GrADS directly from source requires installing and coordinating a large
native dependency stack. Conda makes that easier because it provides:

- isolated build and runtime environments
- compiler toolchains that work with conda packages
- consistent native libraries across systems
- binary package output that can be installed without rebuilding
- a path to conda-forge distribution

This is especially useful for GrADS because several optional features depend on
native libraries with specific headers, symbols, and plugin paths.

## Build Locally

Install `conda-build` once:

```bash
mamba install -n base conda-build -y
```

Build the local package from the repository root:

```bash
conda build conda.recipe/ --no-anaconda-upload
```

The build will:

- create a conda build environment
- install all build and host dependencies
- run `./configure`, `make`, and `make install`
- install GrADS data files under `$PREFIX/share/grads`
- create the plugin table at `$PREFIX/share/grads/udpt`
- install activation/deactivation scripts
- install `gradspy.py` into the Python site-packages directory

A successful Linux build produces packages under the conda build directory, for
example:

```text
~/miniforge3/conda-bld/linux-64/grads-2.2.3-<hash>_<build>.conda
~/miniforge3/conda-bld/noarch/gradspy-2.2.3-<build>.conda
```

## Install and Test a Local Build

Create a clean environment:

```bash
mamba create -n grads-test
mamba activate grads-test
```

Install the locally built package:

```bash
mamba install /path/to/conda-bld/linux-64/grads-2.2.3-*.conda
```

Optional Python interface:

```bash
mamba install /path/to/conda-bld/noarch/gradspy-2.2.3-*.conda
```

Check the native GrADS build:

```bash
printf "'q config'\n'quit'\n" | grads -bl
```

Expected feature line:

```text
Config: v2.2.3 little-endian readline grib2 netcdf hdf4-sds hdf5 opendap-grids geotiff shapefile
```

Check the Python interface:

```bash
python -c "from gradspy import GrADS; print(GrADS)"
```

## Using GrADS

Run a GrADS script in batch mode:

```bash
grads -blc "your_script.gs"
```

For scripts, include `quit` as the final command so GrADS exits:

```grads
'open data.ctl'
'd variable'
'printim output.png'
'quit'
```

Run interactively:

```bash
grads
```

## Important Recipe Details

### GRIB2 library name

Conda-forge's GRIB2 library is provided as `libg2c`, but GrADS configure/link
checks expect `libgrib2c`. The build script creates a compatibility symlink:

```text
libgrib2c.so -> libg2c.so
```

This is intentional and is also documented in the conda-forge PR notes.

### Runtime environment

The package installs conda activation scripts that set:

- `GADDIR` to the packaged GrADS data directory
- `GAUDPT` to the packaged plugin table
- `GAGPY` to the packaged `libgradspy.so`

If another GrADS installation is already configured in the shell, use a fresh
conda environment or unset conflicting variables:

```bash
env -u GADDIR -u GAUDPT -u GAGPY grads -blc your_script.gs
```

### Python interface

`gradspy.py` is a ctypes-based Python wrapper around `libgradspy.so`. It is
packaged as a separate `gradspy` output because it has Python runtime
dependencies (`numpy`, `pandas`, and `xarray`) while the main `grads` package is
a native binary package.

## Source Fixes Included

This branch includes source changes needed for current conda-forge toolchains
and libraries:

- modernized function prototypes for newer GCC compatibility
- HDF5 API updates for HDF5 1.12+ and newer
- plugin loading/order fixes for the packaged display and print backends
- `gradspy.py`, the Python interface used by the `gradspy` output

## Conda-Forge Submission Status

The staged recipe is in:

```text
conda-forge/recipes/grads/
```

It currently builds from the release tag:

```text
v2.2.3.post1
```

The staged recipe is intentionally conservative for the first conda-forge PR:

- Linux-only initially
- `grads` as the native package output
- `gradspy` as a separate noarch Python output
- GRIB2 compatibility symlink retained
- `g2clib` / `nceplibs-g2c` compatibility handled without version pins

## Path to Conda-Forge Acceptance

1. Fork `conda-forge/staged-recipes`.
2. Copy `conda-forge/recipes/grads` into `recipes/grads` in that fork.
3. Open a PR against `conda-forge/staged-recipes:main`.
4. Use `conda-forge/PR_DESCRIPTION.md` as the PR description starting point.
5. Let staged-recipes CI build the package and address reviewer feedback.

Likely review topics:

- whether Linux-only is acceptable for the first submission
- whether the `gradspy` split output is the right package layout
- whether the GRIB2 symlink should stay in `build.sh`
- whether any runtime dependencies should be relaxed or tightened
- whether future macOS support should be tracked after initial acceptance

Once the staged-recipes PR is merged, conda-forge automation will create a
`grads-feedstock` repository. Future package updates should then happen in that
feedstock, not in `staged-recipes`.

After publication, users should be able to install GrADS with:

```bash
mamba install -c conda-forge grads
```

and the Python interface with:

```bash
mamba install -c conda-forge gradspy
```

## Troubleshooting

### `conda-build` is not found

```bash
mamba install -n base conda-build
```

### Build cache or dependency solve problems

```bash
conda build purge
```

Then rebuild:

```bash
conda build conda.recipe/ --no-anaconda-upload
```

### GrADS appears to hang in batch tests

Make sure the command stream includes `quit`:

```bash
printf "'q config'\n'quit'\n" | grads -bl
```

### Wrong GrADS executable is used

Check which executable is on `PATH`:

```bash
which grads
```

In conda tests, prefer prefix-qualified commands:

```bash
printf "'q config'\n'quit'\n" | "$CONDA_PREFIX/bin/grads" -bl
```

## Further Reading

- Conda documentation: https://docs.conda.io/
- Conda-forge staged-recipes: https://github.com/conda-forge/staged-recipes
- GrADS documentation: https://wetterzentrale.de/grads/doc/gadoc.html
