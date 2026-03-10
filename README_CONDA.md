# Building using conda build

A conda build of grads can be made like this:

```bash
MAMBA_ROOT_PREFIX=/home/rogier/miniforge3 mamba run -n base conda build /home/rogier/programs/GrADS/conda.recipe/ --no-anaconda-upload
```

It is important that the build is done with the conda base environment.
All the instruction for which package to include are in conda.recipe/. It also install some data in "$PREFIX/share/grads" and creates UDPT (User Defined Plug-in Table) pointing to conda env libs, as required so that they don't intervene with other Grads installation on the machine.

Installing the conda package in another environment is done with:
```bash
MAMBA_ROOT_PREFIX=/home/rogier/miniforge3 mamba install -n grads /home/rogier/miniforge3/conda-bld/linux-64/grads-2.2.3-h3218e01_3.conda -y
```

To run grads I was able to do:
```bash
env -u GADDIR -u GAUDPT MAMBA_ROOT_PREFIX=/home/rogier/miniforge3 mamba run -n grads bash -c 'source /home/rogier/miniforge3/envs/grads/etc/conda/activate.d/grads-env.sh && /home/rogier/miniforge3/envs/grads/bin/grads -blc /home/rogier/data/gfs/025/bla.gs'
```

Most of this is just unsetting current environent variables that interfere with the conda based grads. I don't think this is needed anymore when the other grads is removed.