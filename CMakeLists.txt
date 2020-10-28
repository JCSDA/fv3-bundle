# (C) Copyright 2017-2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.


# # ------------------------------------------------------------------------- #
# # fv3-bundle for building all the components needed for the JEDI-FV3 system #
# # ------------------------------------------------------------------------- #


# Preamble
# --------

# Check for minimim cmake requirement
cmake_minimum_required( VERSION 3.12 FATAL_ERROR )

# Create project
project( fv3-bundle VERSION 1.0.0 LANGUAGES C CXX Fortran )

# Include ecbuild_bundle macro
include( ecbuild_bundle )

# Default build mode, change with --build=[release]|debug|bit
set( ECBUILD_DEFAULT_BUILD_TYPE Release )

# Enable MPI
set( ENABLE_MPI ON CACHE BOOL "Compile with MPI" )


# Initialize bundle
# -----------------
ecbuild_bundle_initialize()


# Add packages to the bundle
# --------------------------

# jedi-cmake
ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/jcsda/jedi-cmake.git" TAG 1.0.0 )

# ECMWF libraries
find_package( eckit 1.11.6 QUIET)
if (${eckit_FOUND})
  message(STATUS "Found ECKIT package, not building as part of the bundle" )
else()
  ecbuild_bundle( PROJECT eckit GIT "https://github.com/jcsda-internal/eckit.git" TAG 1.11.jcsda )
endif()
ecbuild_bundle( PROJECT fckit GIT "https://github.com/jcsda-internal/fckit.git" TAG 0.7.jcsda )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/jcsda-internal/atlas.git" TAG 0.20.jcsda )

# External (required) observation operators
ecbuild_bundle( PROJECT crtm GIT "https://github.com/jcsda/crtm.git"   TAG v2.3-jedi )

# Core JEDI repositories
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda/oops.git"  TAG 1.0.0 )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda/saber.git" TAG 1.0.0 )
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda/ioda.git"  TAG 1.0.0 )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda/ufo.git"   TAG 1.0.0 )

# FMS and FV3 dynamical core
ecbuild_bundle( PROJECT fms GIT "https://github.com/jcsda/FMS.git"                     TAG 1.0.0.jcsda )
ecbuild_bundle( PROJECT fv3 GIT "https://github.com/jcsda/GFDL_atmos_cubed_sphere.git" TAG 1.0.0.jcsda )

# fv3-jedi and associated repositories
ecbuild_bundle( PROJECT femps       GIT "https://github.com/jcsda/femps.git"                TAG 1.0.0 )
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda/fv3-jedi-linearmodel.git" TAG 1.0.0 )
ecbuild_bundle( PROJECT fv3-jedi    GIT "https://github.com/jcsda/fv3-jedi.git"             TAG 1.0.0 )


# Finalize bundle
# ---------------
ecbuild_bundle_finalize()
