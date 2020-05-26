# (C) Copyright 2017-2019 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# ##########
# fv3-bundle
# ##########

project( fv3-bundle C CXX Fortran )

cmake_minimum_required( VERSION 3.3.2 FATAL_ERROR )

set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake;${CMAKE_MODULE_PATH}")
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
find_package(eckit)
if(NOT eckit_FOUND)
    ecbuild_bundle( PROJECT eckit GIT "https://github.com/jcsda/eckit.git" BRANCH develop UPDATE )
endif()
ecbuild_bundle( PROJECT fckit GIT "https://github.com/jcsda/fckit.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/jcsda/atlas.git" BRANCH develop UPDATE )

# External observation operators
# ------------------------------
#ecbuild_bundle( PROJECT geos-aero GIT "https://github.com/jcsda/geos-aero.git"    BRANCH develop UPDATE )
#ecbuild_bundle( PROJECT gsw       GIT "https://github.com/jcsda/GSW-Fortran.git"  BRANCH develop UPDATE )
#ecbuild_bundle( PROJECT ropp-ufo  GIT "https://github.com/jcsda/ropp-test.git"    BRANCH develop UPDATE )
ecbuild_bundle( PROJECT crtm      GIT "https://github.com/jcsda/crtm.git"         BRANCH develop UPDATE )

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda/oops.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda/saber.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda/ioda.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda/ufo.git"   BRANCH develop UPDATE )

# Shallow water model
# -------------------
#ecbuild_bundle( PROJECT shallow-water GIT "https://github.com/jcsda/shallow-water.git" BRANCH develop UPDATE )

# Options for building with GEOS or GFS models
# --------------------------------------------
option(BUILD_WITH_GEOS "Build with GEOS model" OFF)
option(BUILD_WITH_GFS  "Build with GFS model"  OFF)

# FMS library
# -----------
if (NOT ${BUILD_WITH_GEOS})
  ecbuild_bundle( PROJECT fms GIT "https://github.com/jcsda/FMS.git" BRANCH dev/master-ecbuild UPDATE )
endif()

# GFS model
# ---------
if (${BUILD_WITH_GFS})
  #ToDo
endif()

# fv3-jedi and associated repositories
# ------------------------------------
ecbuild_bundle( PROJECT femps       GIT "https://github.com/jcsda/femps.git"                BRANCH develop UPDATE )
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda/fv3-jedi-linearmodel.git" BRANCH feature/geos UPDATE )
ecbuild_bundle( PROJECT fv3-jedi    GIT "https://github.com/jcsda/fv3-jedi.git"             BRANCH feature/geos UPDATE )

# Build Doxygen documentation
# ---------------------------
option(BUILD_FV3_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_FV3_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_FV3_BUNDLE_DOC)

ecbuild_bundle_finalize()
