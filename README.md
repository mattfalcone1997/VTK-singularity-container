# VTK singularity container for Nek5000 data

This repository contains singularity container and associated scripts for an MPI build of VTK to speed up testing on HPCs. The singularity container currently uses MPICH but can be easily changed to use OpenMPI if necessary by looking at Singularity's documentation.

## Building and running the container
To build and run the container a singularity installation is required. To build run the command
```bash
sudo singularity build vtk_container.sif vtk_container.def
```
To test the installation use
```bash
singularity test vtk_container.sif
```
To read Nek5000 data and screenshot it
```bash
mpirun -n 4 singularity run vtk_container.sif read_nek_data.py <path/to/data.nek5000> --screenshot
```
