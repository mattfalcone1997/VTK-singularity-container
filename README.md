# VTK singularity container for Nek5000 data

This repository contains singularity container and associated scripts for an MPI build of VTK to speed up testing on HPCs. The singularity container currently uses MPICH but can be easily changed to use OpenMPI if necessary by looking at Singularity's documentation. The VTK build is based on the commit associated with Paraview 5.13.3.

## Requirements
* Installation of Singularity.
* MPICH-based MPI installation (if run using MPI hybrid mode).
Note that MPI can be used from within the container using `shell` or `exec` subcommands.

### Using Apptainer
You should be able to use Apptainer, although this has not been fully tested. From preliminary testing, some additional steps are required.
1. Create Sylabs account.
1. Create access token
1. Set the library locally Sylabs using the access token for security
```bash
singularity remote add sylabs https://cloud.sylabs.io
```

## Running the container
1. Pull the container from Sylabs. The tag `old` indicates the version of the container which has the integer overflow bug in the `vtkNek5000Reader`. A new one with the bug fixed can be accessed with the `fix` tag.
```bash
singularity pull library://mattfalcone1997/vtk/vtk_mpich.sif:old
```
2. Test the container
```bash
singularity test vtk_mpich.sif
```
3. The container can be used like any other singularity container, note that arguments to the `run` subcommand are passed to Python.
3. To run `read_nek_data.py` with MPI in Hybrid mode and screenshot the result use
```bash
mpirun -n 4 singularity run vtk_container.sif read_nek_data.py <path/to/data.nek5000> --screenshot
```

## Run on `CSD3` visualisation nodes
1. Connect to visualisation nodes in the usual way.
1. Load singularity module
```bash
module load singularity/current
```
3. Load paraview, so that the same MPI is loaded as Paraview for testing. The specific version shouldn't matter too much.
```bash
module load paraview/5.11.2-omniverse
```