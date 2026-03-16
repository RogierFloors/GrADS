# Building GrADS with Conda

This directory includes a conda build recipe for GrADS 2.2.3 with full feature support. Conda provides significant advantages over building from source directly.

## Why use Conda?

### Key Benefits

1. **Reproducibility** — All dependencies are pinned to specific versions. The same build recipe works identically on any machine.
2. **Isolation** — Each conda environment is completely isolated. GrADS can coexist with other versions or builds without conflicts.
3. **Dependency Management** — Conda automatically handles all libraries (HDF5, NetCDF, GRIB2, GeoTIFF, Cairo, etc.) with correct versions.
4. **No System Root Access** — Build and install entirely in user space without `sudo`. No modifications to `/usr/local/` or system libraries.
5. **Easy Portability** — Share `.conda` packages or rebuild on different machines using the same recipe.
6. **Binary Distribution** — Pre-built binaries avoid long compile times on each machine.

### Compared to Building from Source

Direct compilation (`./configure && make`) requires:
- Installing all dependencies manually with system package managers
- Managing version conflicts between tools
- Dealing with compiler sysroot incompatibilities (especially with cross-compilers)
- Writing complex shell setup scripts to manage environment paths
- Troubleshooting linker errors from library version mismatches

Conda handles all of this automatically.

## Building the Package

### Prerequisites

You need conda or mamba installed. If you have miniforge/mambaforge, you're ready.

### Build Steps

1. **Navigate to the repository:**
   ```bash
   cd /path/to/GrADS
   ```

2. **Install conda-build (one-time only):**
   ```bash
   mamba install -n base conda-build -y
   ```

3. **Build the package:**
   ```bash
   conda build conda.recipe/ --no-anaconda-upload
   ```

   The build will:
   - Download all dependencies automatically
   - Apply patches for GCC 15 compatibility
   - Configure GrADS with all features enabled
   - Link against HDF5, NetCDF, GRIB2, GeoTIFF, and other libraries
   - Create a `.conda` package file

   **Note:** The build must run in your base conda environment. The recipe uses conda's cross-compiler toolchain, which handles all sysroot and compiler compatibility automatically.

### Build Output

A successful build produces:
```
~/miniforge3/conda-bld/linux-64/grads-2.2.3-h3218e01_N.conda
```

(where `N` is the build number)

## Installing and Using GrADS

### Create a New Environment

```bash
mamba create -n grads
mamba activate grads
```

### Install GrADS

Using your built package:
```bash
mamba install /path/to/conda-bld/linux-64/grads-2.2.3-h3218e01_N.conda
```

Or install from conda-forge (if available in the future):
```bash
mamba install -c conda-forge grads
```

### Run GrADS

Simple usage:
```bash
grads -blc "your_script.gs"
```

Or interactively:
```bash
grads
```

### Verify All Features Are Enabled

```bash
grads -blc "q config"
```

You should see:
```
Config: v2.2.3 little-endian readline grib2 netcdf hdf4-sds hdf5 opendap-grids geotiff shapefile
```

## Example: Running a GrADS Script

Create `plot_data.gs`:
```grads
'open data.ctl'
'd variable'
'printim output.png'
'quit'
```

Run it:
```bash
grads -blc plot_data.gs
```

**Important:** Always include `'quit'` at the end of your script in batch mode (`-blc`), otherwise GrADS waits for interactive input.

## Features Included in the Conda Build

The recipe enables:
- **GRIB2** support (via `g2clib 1.6.0` — pinned for API compatibility)
- **NetCDF** (with HDF5 support)
- **HDF4** interface
- **HDF5** interface
- **OPeNDAP** gridded data support
- **GeoTIFF** and TIFF output
- **Shapefile** support
- **KML** support
- **Cairo** graphics library (for high-quality displays and printing)
- **Readline** for command-line editing

## Troubleshooting

### Build Fails with "conda-build not found"
```bash
mamba install -n base conda-build
```

### Build Fails with Version Conflicts
Clean the conda-build cache:
```bash
conda build purge
rm -rf ~/miniforge3/conda-bld/grads_*
```

Then rebuild.

### "libgrib2c.so not found" at Runtime
The conda recipe automatically creates a symlink from `libg2c.so` → `libgrib2c.so` during the build. If this fails, manually create it:
```bash
ln -s $CONDA_PREFIX/lib/libg2c.so $CONDA_PREFIX/lib/libgrib2c.so
```

### GrADS Tries to Load Wrong Plugins
The conda environment sets `GADDIR` and `GAUDPT` environment variables automatically via activation scripts in `etc/conda/activate.d/`. If you have other GrADS installations on the system, their environment variables may interfere. 

Solution: Always run GrADS in a fresh conda environment or unset conflicting variables:
```bash
env -u GADDIR -u GAUDPT grads -blc your_script.gs
```

## Recipe Details

The conda recipe is in `conda.recipe/`:
- **`meta.yaml`** — Package metadata, dependencies, and build configuration
- **`build.sh`** — Build script that runs `configure`, `make`, and installs data files

### Key Build Fixes Applied

The source code includes patches for:
1. **GCC 15 compatibility** — Updated function prototypes (K&R style `void func()` → modern `void func(void)`)
2. **HDF5 1.12+ API** — Uses `H5Oget_info3()` and `H5O_info2_t` instead of deprecated v1 API
3. **Plugin loading order** — Correct load sequence for display and print plugins

These fixes are committed to the `conda_build` branch and are applied automatically during the conda build.

## Rebuilding on Another Machine

Simply clone the repository and run:
```bash
conda build conda.recipe/ --no-anaconda-upload
```

The recipe is self-contained and will produce an identical build with no additional setup.

## Further Reading

- [Conda Documentation](https://docs.conda.io/)
- [GrADS Documentation](http://cola.gmu.edu/grads/)