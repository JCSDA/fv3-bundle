# (C) Copyright 2017-2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# ##########
# fv3-bundle
# ##########

project( fv3-bundle C CXX Fortran )

cmake_minimum_required( VERSION 3.3.2 FATAL_ERROR )

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include( ecbuild_bundle )

# Default release mode
set( ECBUILD_DEFAULT_BUILD_TYPE Release )

# Enable MPI
set( ENABLE_MPI ON CACHE BOOL "Compile with MPI" )

# Initialize
ecbuild_bundle_initialize()
ecbuild_requires_macro_version( 2.9 )

# ECMWF libs
# ----------
option(BUILD_ECKIT "Build ECKIT as part of the fv3-bundle" OFF)
if (BUILD_ECKIT)
  ecbuild_bundle( PROJECT eckit GIT "https://github.com/JCSDA/eckit.git" UPDATE BRANCH release-stable )
endif()
ecbuild_bundle( PROJECT fckit GIT "https://github.com/jcsda/fckit.git" BRANCH release-stable UPDATE )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/jcsda/atlas.git" BRANCH release-stable UPDATE )

# External (optional) observation operators
# ------------------------------
option(BUILD_GEOSAERO "Build GEOS-AERO as part of the fv3-bundle" OFF)
option(BUILD_GSW      "Build GSW       as part of the fv3-bundle" OFF)
option(BUILD_ROPP     "Build ROPP-UFO  as part of the fv3-bundle" OFF)

if(BUILD_GEOSAERO)
  ecbuild_bundle( PROJECT geos-aero GIT "https://github.com/jcsda/geos-aero.git" BRANCH develop UPDATE )
endif()

if(BUILD_GSW)
  ecbuild_bundle( PROJECT gsw GIT "https://github.com/jcsda/GSW-Fortran.git" BRANCH develop UPDATE )
endif()

if(BUILD_ROPP)
  ecbuild_bundle( PROJECT ropp-ufo GIT "https://github.com/jcsda/ropp-test.git" BRANCH develop UPDATE )
endif()

# External (required) observation operators
# ------------------------------
ecbuild_bundle( PROJECT crtm GIT "https://github.com/jcsda/crtm.git" BRANCH develop UPDATE )

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda/oops.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda/saber.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda/ioda.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda/ufo.git"   BRANCH develop UPDATE )

# Options for building with certain models
# ----------------------------------------
set(FV3_FORECAST_MODEL "FV3CORE" CACHE STRING "Choose which MODEL to build with")
set_property(CACHE FV3_FORECAST_MODEL PROPERTY STRINGS "FV3CORE" "UFS" "GEOS")
if(NOT FV3_FORECAST_MODEL MATCHES "^(FV3CORE|UFS|GEOS)$")
  ecbuild_error("Valid options for -DFV3_FORECAST_MODEL are FV3CORE|UFS|GEOS")
endif()
ecbuild_info("Building with FV3-based model: ${FV3_FORECAST_MODEL}")

# FMS and FV3 dynamical core model are needed for FV3CORE
# -------------------------------------------------------
if (FV3_FORECAST_MODEL MATCHES "FV3CORE")
  ecbuild_bundle( PROJECT fms GIT "https://github.com/jcsda/FMS.git" BRANCH release-stable UPDATE )
  ecbuild_bundle( PROJECT fv3 GIT "https://github.com/jcsda/GFDL_atmos_cubed_sphere.git" BRANCH release-stable UPDATE )
endif()

# fv3-jedi linear model
# ---------------------
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda/fv3-jedi-linearmodel.git" BRANCH develop UPDATE )

# fv3-jedi and associated repositories
# ------------------------------------
ecbuild_bundle( PROJECT femps    GIT "https://github.com/jcsda/femps.git"    BRANCH develop UPDATE )
ecbuild_bundle( PROJECT fv3-jedi GIT "https://github.com/jcsda/fv3-jedi.git" BRANCH develop UPDATE )

# Build Doxygen documentation
# ---------------------------
option(BUILD_FV3_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_FV3_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_FV3_BUNDLE_DOC)

ecbuild_bundle_finalize()
