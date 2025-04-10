"""A script for reading Nek5000 data files in parallel and optionally visualizing them
"""

import argparse
import os

import vtk
import matplotlib as mpl


from mpi4py import MPI
from typing import List

def read_parallel(fname: str,
                  time: float=None,
                  scalars: List[str]=None):
    """Reads Nek5000 data files

    Parameters
    ----------
    fname : str
        file name of Nek5000 file
    time : float, optional
        time that you wish to be read, by default None
    scalars : List[str], optional
        scalars to be visualised, by default None

    Returns
    -------
    vtk.vtkUnstructuredGrid
        Unstructured grid of Nek5000 dataset
    """
    reader = vtk.vtkNek5000Reader()
    reader.SetFileName(fname)
    reader.UpdateInformation()

    if scalars is not None:
        reader.DisableAllPointArrays()
        for scalar in scalars:
            reader.SetPointArrayStatus(scalar, 1)
    else:
        reader.EnableAllPointArrays()

    if time is not None:
        streaming = vtk.vtkStreamingDemandDrivenPipeline()
        key = streaming.UPDATE_TIME_STEP()
        info = reader.GetOutputInformation(0)
        info.Set(key, time)

    reader.Update()
    return reader.GetOutput()

def get_lut(cmap: str):
    """Convert matplotlib colormap to VTK Lookup table

    Parameters
    ----------
    cmap : str
        Matplotlib colormap

    Returns
    -------
    vtk.vtkLookupTable
        Color map lookup table
    """
    lut = vtk.vtkLookupTable()

    ncolors = 256
    lut.SetNumberOfColors(ncolors)
    cmap_ = mpl.colormaps[cmap]
    for i in range(ncolors):
        lut.SetTableValue(i,cmap_(i))
    lut.Build()
    return lut

def pipeline(data: vtk.vtkUnstructuredGrid,
             scalar: str,
             prm: vtk.vtkCompositeRenderManager):
    """Simple pipeline to visualise Nek5000 data

    Parameters
    ----------
    data : vtk.vtkUnstructuredGrid
        input dataset
    scalar : str
        Name of scalar
    prm : vtk.vtkCompositeRenderManager
        Parallel render manager
    """

    renderer = prm.GetRenderWindow().GetRenderers().GetFirstRenderer()

    lut = get_lut('bwr')

    data.GetPointData().SetActiveScalars('Velocity')
    scalar = data.GetPointData().GetScalars('Velocity')

    mapper = vtk.vtkDataSetMapper()
    mapper.SetInputData(data)
    mapper.SetScalarRange(scalar.GetRange())
    mapper.SetColorModeToMapScalars()
    mapper.SetScalarModeToUsePointData()
    mapper.ScalarVisibilityOn()
    mapper.SetLookupTable(lut)

    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    renderer.AddActor(actor)


def create_render_manager(controller: vtk.vtkMPIController):
    """Creates parallel render manager

    Parameters
    ----------
    controller : vtk.vtkMPIController
        Input MPI controller

    Returns
    -------
    vtk.vtkCompositeRenderManager
        Parallel render manager
    """
    renderer = vtk.vtkRenderer()
    renderer.SetBackground(1., 1., 1.)

    render_window = vtk.vtkRenderWindow()
    render_window.AddRenderer(renderer)
    render_window.SetSize(800, 600)

    # Parallel render manager setup
    prm = vtk.vtkCompositeRenderManager()
    prm.SetRenderWindow(render_window)
    prm.SetController(controller)
    prm.InitializeOffScreen()

    return prm

def view_data(prm: vtk.vtkCompositeRenderManager):
    """View data in parallel

    Parameters
    ----------
    prm : vtk.vtkCompositeRenderManager
        Parallel render manager
    """
    rank = prm.GetController().GetCommunicator().GetLocalProcessId()

    render_window = prm.GetRenderWindow()

    if rank == 0:
        prm.ResetAllCameras()

    if rank == 0:
        interactor = vtk.vtkRenderWindowInteractor()
        interactor.SetRenderWindow(render_window)
        render_window.SetInteractor(interactor)
        interactor.Initialize()
        interactor.Start()

        prm.StopServices()

    else:
        # Background ranks wait for render requests
        prm.StartInteractor()

def screenshot(fname: str, prm: vtk.vtkCompositeRenderManager):
    """Take screenshot as PNG file

    Parameters
    ----------
    fname : str
        PNG file name
    prm : vtk.vtkCompositeRenderManager
        Render manager
    """
    rank = prm.GetController().GetCommunicator().GetLocalProcessId()

    render_window = prm.GetRenderWindow()

    if rank == 0:
        prm.ResetAllCameras()

        w2i = vtk.vtkWindowToImageFilter()
        w2i.SetInput(render_window)
        w2i.Update()

        writer = vtk.vtkPNGWriter()
        writer.SetFileName(fname)
        writer.SetInputConnection(w2i.GetOutputPort())
        writer.Write()


def main():
    """Main function"""

    description = (
        'A script for reading Nek5000 data files in parallel and optionally visualizing them'
    )
    parser = argparse.ArgumentParser(
                    prog='read_nek_data',
                    description=description)

    parser.add_argument("filename",
                        help="Input file name")

    parser.add_argument('--interactive',
                        action='store_true',
                        default=False,
                        help="Create interactive render window of input")

    parser.add_argument('--scalar-viz',
                        action='store',
                        default='Velocity',
                        help="Scalar to be visualised")

    parser.add_argument('--screenshot',
                        action='store_true',
                        default=False,
                        help="Create PNG on data")

    args = parser.parse_args()

    ## setup parallel controller
    controller = vtk.vtkMPIController()
    controller.Initialize()
    vtk.vtkMultiProcessController.SetGlobalController(controller)


    if not os.path.isfile(args.filename):
        raise FileNotFoundError(f"{args.filename}: No such file or directory.")

    data = read_parallel(args.filename, 0.)

    if args.screenshot or args.interactive:
        prm = create_render_manager(controller)

        pipeline(data, args.scalars, prm)

    if args.screenshot:
        screenshot("image.png" ,prm)

    if args.interactive:
        view_data(prm)

    # controller.Finalize()
if __name__ == '__main__':
    main()
