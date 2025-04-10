# cmake file adapted from VTK CI pipeline. Configuration options
# determined by CMAKE_CONFIGURATION environment variable. To
# build a openmp and MPI build use
# export CMAKE_CONFIGURATION=openmp_mpi
# To consider all options, search file for calls of the configuration_file
# cmake function.

if (NOT DEFINED "ENV{PYTHON_PREFIX}")
  message(FATAL_ERROR
    "The `PYTHON_PREFIX` environment variable is required.")
endif ()

set(python_subdir "bin/")
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "windows")
  set(python_subdir "")
endif ()

if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "macos")
  if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "x86_64")
    if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "python31.") # 3.10+ binaries target at least 11.0
      set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "")
    else ()
      set(CMAKE_OSX_DEPLOYMENT_TARGET "10.10" CACHE STRING "")
    endif ()
  elseif ("$ENV{CMAKE_CONFIGURATION}" MATCHES "arm64")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "")
  endif ()
endif ()

set(VTK_WHEEL_BUILD ON CACHE BOOL "")
set(VTK_INSTALL_SDK ON CACHE BOOL "")

set(CMAKE_PREFIX_PATH "$ENV{PYTHON_PREFIX}" CACHE STRING "")
set(Python3_EXECUTABLE "$ENV{PYTHON_PREFIX}/${python_subdir}python$ENV{PYTHON_VERSION_SUFFIX}" CACHE FILEPATH "")
# We always want the Python specified here, not the system one.
set(Python3_FIND_STRATEGY LOCATION CACHE STRING "")

# Official wheels never include remote modules (because they are not under
# VTK's software process).
set(VTK_ENABLE_REMOTE_MODULES OFF CACHE BOOL "")

# Disable debug leaks in wheels.
set(VTK_DEBUG_LEAKS OFF CACHE BOOL "")

# Enable `.pyi` files.
set(VTK_BUILD_PYI_FILES ON CACHE BOOL "")

# Disable modules we cannot build for wheels.
set(VTK_GROUP_ENABLE_Qt NO CACHE STRING "") # Qt
set(VTK_MODULE_ENABLE_VTK_CommonArchive NO CACHE STRING "") # libarchive
set(VTK_MODULE_ENABLE_VTK_DomainsMicroscopy NO CACHE STRING "") # OpenSlide
set(VTK_MODULE_ENABLE_VTK_FiltersOpenTURNS NO CACHE STRING "") # OpenTURNS
set(VTK_MODULE_ENABLE_VTK_FiltersReebGraph NO CACHE STRING "") # Boost
set(VTK_MODULE_ENABLE_VTK_IOADIOS2 NO CACHE STRING "") # ADIOS2
set(VTK_MODULE_ENABLE_VTK_IOAlembic NO CACHE STRING "") # alembic
set(VTK_MODULE_ENABLE_VTK_IOFFMPEG NO CACHE STRING "") # FFMPEG
set(VTK_MODULE_ENABLE_VTK_IOGDAL NO CACHE STRING "") # GDAL
set(VTK_MODULE_ENABLE_VTK_IOLAS NO CACHE STRING "") # liblas
set(VTK_MODULE_ENABLE_VTK_IOMySQL NO CACHE STRING "") # MariaDB
set(VTK_MODULE_ENABLE_VTK_IOODBC NO CACHE STRING "") # odbc
set(VTK_MODULE_ENABLE_VTK_IOOpenVDB NO CACHE STRING "") # OpenVDB
set(VTK_MODULE_ENABLE_VTK_IOPDAL NO CACHE STRING "") # PDAL
set(VTK_MODULE_ENABLE_VTK_IOPostgreSQL NO CACHE STRING "") # PostgreSQL
set(VTK_MODULE_ENABLE_VTK_InfovisBoost NO CACHE STRING "") # Boost
set(VTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms NO CACHE STRING "") # Boost
set(VTK_MODULE_ENABLE_VTK_RenderingFreeTypeFontConfig NO CACHE STRING "") # fontconfig
set(VTK_MODULE_ENABLE_VTK_RenderingOpenVR NO CACHE STRING "") # OpenVR

if(NOT WIN32)
  set(VTK_MODULE_ENABLE_VTK_RenderingOpenXR NO CACHE STRING "") # OpenXR disable on every system except Windows
endif()

set(VTK_MODULE_ENABLE_VTK_RenderingRayTracing NO CACHE STRING "") # OSPRay
set(VTK_MODULE_ENABLE_VTK_RenderingZSpace NO CACHE STRING "") # zSpace
set(VTK_MODULE_ENABLE_VTK_fides NO CACHE STRING "") # ADIOS2
set(VTK_MODULE_ENABLE_VTK_xdmf3 NO CACHE STRING "") # Boost
set(VTK_MODULE_ENABLE_VTK_IOOCCT NO CACHE STRING "") # occt
set(VTK_ENABLE_CATALYST OFF CACHE BOOL "") # catalyst

# Stock CI builds test everything possible (platforms will disable modules as
# needed).
set(VTK_BUILD_ALL_MODULES ON CACHE BOOL "")

set(VTK_LEGACY_REMOVE ON CACHE BOOL "")
set(VTK_BUILD_TESTING WANT CACHE STRING "")
set(VTK_BUILD_EXAMPLES ON CACHE BOOL "")

set(VTK_BUILD_SCALE_SOA_ARRAYS ON CACHE BOOL "")
set(VTK_DISPATCH_SOA_ARRAYS ON CACHE BOOL "")

set(VTK_DEBUG_LEAKS ON CACHE BOOL "")
set(VTK_USE_LARGE_DATA ON CACHE BOOL "")
set(VTK_LINKER_FATAL_WARNINGS ON CACHE BOOL "")

set(VTK_ENABLE_CATALYST ON CACHE BOOL "")
set(VTK_WRAP_SERIALIZATION ON CACHE BOOL "")

# The install trees on CI machines need help since dependencies are not in a
# default location.
set(VTK_RELOCATABLE_INSTALL ON CACHE BOOL "")

# Remote modules are not under VTK's development process.
set(VTK_ENABLE_REMOTE_MODULES OFF CACHE BOOL "")

# We run the install right after the build. Avoid rerunning it when installing.
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY "ON" CACHE BOOL "")

# Install VTK.
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "")
set(CMAKE_INSTALL_LIBDIR "lib" CACHE STRING "")

# Enable extra build warnings in CI.
set(VTK_ENABLE_EXTRA_BUILD_WARNINGS ON CACHE BOOL "")
set(VTK_ENABLE_EXTRA_BUILD_WARNINGS_EVERYTHING ON CACHE BOOL "")

# Remove this after Utilities/OpenGL is deleted.
set(VTK_MODULE_ENABLE_VTK_opengl NO CACHE STRING "")

# Options that can be overridden based on the
# configuration name.
function (configuration_flag variable configuration)
  if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "${configuration}")
    set("${variable}" ON CACHE BOOL "")
  else ()
    set("${variable}" OFF CACHE BOOL "")
  endif ()
endfunction ()

function (configuration_flag_module variable configuration)
  if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "${configuration}")
    set("${variable}" YES CACHE STRING "")
  else ()
    set("${variable}" NO CACHE STRING "")
  endif ()
endfunction ()

# doxygen
configuration_flag(VTK_BUILD_DOCUMENTATION "doxygen")

# kits
configuration_flag(VTK_ENABLE_KITS "kits")

# mpi
configuration_flag(VTK_USE_MPI "mpi")
configuration_flag_module(VTK_GROUP_ENABLE_MPI "mpi")

# offscreen
configuration_flag(VTK_DEFAULT_RENDER_WINDOW_OFFSCREEN "offscreen")
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "offscreen")
  set(VTK_USE_COCOA OFF CACHE BOOL "")
  set(VTK_USE_X OFF CACHE BOOL "")
endif ()

# webgpu
configuration_flag(VTK_ENABLE_WEBGPU "webgpu")

# cuda
configuration_flag(VTK_USE_CUDA "cuda")

# python
configuration_flag(VTK_WRAP_PYTHON "python")

# java
configuration_flag(VTK_WRAP_JAVA "java")
configuration_flag(VTK_BUILD_MAVEN_PKG "java")

if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "java")
  set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
  set(JOGL_VERSION "2.3.2" CACHE STRING "")
  # Naming is <arch-platform> since some maven versions fail to properly parse
  # the artifact name when numbers are trailing in the classifer name.
  set(MAVEN_NATIVE_ARTIFACTS "darwin-amd;darwin-arm;linux-amd;windows-amd" CACHE STRING "" FORCE)
  set(MAVEN_VTK_ARTIFACT_SUFFIX "-java${VTK_JAVA_RELEASE_VERSION}" CACHE STRING "")
  # Disable snapshots for tag releases and also when the env variable
  # VTK_JAVA_FORCE_RELEASE is defined through the Gitlab schedule pipeline UI.
  # Note that VTK_JAVA_FORCE_RELEASE is used to create/override VTK java
  # releases.
  if (NOT DEFINED ENV{CI_COMMIT_TAG} AND NOT DEFINED ENV{VTK_JAVA_FORCE_RELEASE})
    set(MAVEN_VTK_SNAPSHOT "-SNAPSHOT" CACHE STRING "")
  endif()
  set(VTK_BUILD_TESTING OFF CACHE BOOL "" FORCE)
  set(VTK_CUSTOM_LIBRARY_SOVERSION "" CACHE STRING "")
  set(VTK_CUSTOM_LIBRARY_VERSION "" CACHE STRING "")
  set(VTK_DEBUG_LEAKS OFF CACHE BOOL "" FORCE)
  set(VTK_GROUP_ENABLE_Rendering "YES" CACHE STRING "")
  set(VTK_JAVA_JOGL_COMPONENT "YES" CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_RenderingOpenXR NO CACHE STRING "" FORCE)
  set(VTK_MODULE_ENABLE_VTK_TestingCore NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_TestingDataModel NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_TestingGenericBridge NO STRING STRING "")
  set(VTK_MODULE_ENABLE_VTK_TestingIOSQL NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_TestingRendering NO CACHE STRING "")
  set(VTK_VERSIONED_INSTALL "OFF" CACHE BOOL "" FORCE)
endif()

# qt
configuration_flag_module(VTK_GROUP_ENABLE_Qt "qt")
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "qt5")
  set(VTK_QT_VERSION 5 CACHE STRING "")
endif ()

# "nogl" builds
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "renderless")
  set(VTK_MODULE_ENABLE_VTK_RenderingCore NO CACHE STRING "")

  # "mpi" forces MPI modules to be ON, but these require rendering, so force
  # them off too.
  set(VTK_MODULE_ENABLE_VTK_DomainsParallelChemistry NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_FiltersParallelGeometry NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_FiltersParallelMPI NO CACHE STRING "")
  set(VTK_MODULE_ENABLE_VTK_IOMPIParallel NO CACHE STRING "")
endif ()

# "tbb"/"openmp"/"stdthread" builds
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "tbb")
  set(VTK_SMP_IMPLEMENTATION_TYPE TBB CACHE STRING "")
elseif ("$ENV{CMAKE_CONFIGURATION}" MATCHES "openmp")
  set(VTK_SMP_IMPLEMENTATION_TYPE OpenMP CACHE STRING "")
elseif ("$ENV{CMAKE_CONFIGURATION}" MATCHES "stdthread")
  set(VTK_SMP_IMPLEMENTATION_TYPE STDThread CACHE STRING "")
else ()
  set(VTK_SMP_IMPLEMENTATION_TYPE Sequential CACHE STRING "")
endif ()

# Shared/static
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "shared")
  set(VTK_BUILD_SHARED_LIBS ON CACHE BOOL "")
elseif ("$ENV{CMAKE_CONFIGURATION}" MATCHES "static")
  set(VTK_BUILD_SHARED_LIBS OFF CACHE BOOL "")
endif ()

# vtkmoverride
configuration_flag(VTK_ENABLE_VTKM_OVERRIDES "vtkmoverride")

# ospray
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "ospray")
  set(VTK_MODULE_ENABLE_VTK_RenderingRayTracing YES CACHE STRING "")
else ()
  set(VTK_MODULE_ENABLE_VTK_RenderingRayTracing NO CACHE STRING "")
endif ()

# anari/helide
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "helide")
  set(VTK_MODULE_ENABLE_VTK_RenderingAnari YES CACHE STRING "")
else ()
  set(VTK_MODULE_ENABLE_VTK_RenderingAnari NO CACHE STRING "")
endif ()

# Mangling
if ("$ENV{CMAKE_CONFIGURATION}" MATCHES "mangling")
  set(VTK_ABI_NAMESPACE_NAME "vtk_mangle_test" CACHE STRING "")
endif()

# Default to Release builds.
if ("$ENV{CMAKE_BUILD_TYPE}" STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "")
else ()
  set(CMAKE_BUILD_TYPE "$ENV{CMAKE_BUILD_TYPE}" CACHE STRING "")
endif ()
