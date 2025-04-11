#!/bin/bash
# This script installs a VTK python wheel with Open MP enabled
# The following envionrment variables must be set
# * CMAKE_CONFURATION
# * PYTHON_PREFIX
# The CMAKE configuration file vtk_options must be present.

#===============================================================
# Helper functions

set -e
test_return () {
      if [ $? -ne 0 ]; then
            echo -e "Error: $1"
            exit $?
      fi
}

#Check cmake cache available
if [ ! -f vtk_options.cmake ]; then
      echo -e "Cannot find vtk_options.cmake"
      exit 1
fi
CMAKE_CONFIG_FILE=${PWD}/vtk_options.cmake

#===============================================================
# Use ninja to build if available
if command -v ninja &> /dev/null ; then
      CMD=ninja
      GENERATOR="Ninja"
else
      CMD="make -j ${NTHREADS}"
      GENERATOR="Unix Makefiles"
fi

echo -e "Using cmake generator ${CMD}"

git clone https://gitlab.kitware.com/mattfalcone1997/vtk.git VTK
#============================================================
# create build directory
cd VTK

# This one has fixed the integer overflow bug
git checkout nek_reader_bug
# This one has the integer overflow bug
#git checkout feef9ccd0a1ad893308532afe85c9d08d17aa99d

git submodule update --init --recursive

mkdir -p build
cd build

# set environment variables for cmake

# Run cmake
cmake -G"${GENERATOR}" \
      -DCMAKE_BUILD_TYPE=Release \
      -DVTK_BUILD_TESTING=OFF \
      -DVTK_BUILD_DOCUMENTATION=OFF \
      -DVTK_BUILD_EXAMPLES=OFF \
      -DVTK_MODULE_ENABLE_VTK_opengl=YES \
      -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
      -C "${CMAKE_CONFIG_FILE}" \
      -B . -S ../

test_return "Error during configuration"

# build VTK
$CMD
test_return "Error during VTK build"

PYBIN=$PYTHON_PREFIX/bin/python

# Create wheel file for VTK
$PYBIN setup.py bdist_wheel
test_return "Error building VTK wheel"

#Install VTK wheel
$PYBIN -m pip install dist/vtk-*.whl
test_return "Error installing VTK wheel"
