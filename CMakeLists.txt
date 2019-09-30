# (C) Copyright 2017-19 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

#
# fv3-bundle
#

project( fv3-bundle C CXX Fortran )

cmake_minimum_required( VERSION 3.3.2 FATAL_ERROR )

set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake;${CMAKE_CURRENT_SOURCE_DIR}/ecbuild/cmake;${CMAKE_MODULE_PATH}")
include( ecbuild_bundle )

#Default release mode
set( ECBUILD_DEFAULT_BUILD_TYPE Release )

set( ENABLE_MPI ON CACHE BOOL "Compile with MPI" )

ecbuild_bundle_initialize()

ecbuild_requires_macro_version( 2.9 )

# Eckit (usually not compiled inline)
# -----------------------------------
ecbuild_bundle( PROJECT eckit         GIT "https://github.com/ECMWF/eckit.git"                TAG 1.1.0 )

# FCKIT
# -----
ecbuild_bundle( PROJECT fckit         GIT "https://github.com/JCSDA/fckit.git"                BRANCH develop             UPDATE )

# External observation operators
# ------------------------------
#ecbuild_bundle( PROJECT gsw           GIT "https://github.com/JCSDA/GSW-Fortran.git"          BRANCH develop             UPDATE )
#ecbuild_bundle( PROJECT ropp-ufo      GIT "https://github.com/JCSDA/ropp-test.git"            BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT crtm          GIT "https://github.com/JCSDA/crtm.git"                 BRANCH develop             UPDATE )

# Core JEDI repositories
# ----------------------
ecbuild_bundle( PROJECT saber         GIT "https://github.com/JCSDA/saber.git"                BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT oops          GIT "https://github.com/JCSDA/oops.git"                 BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT ioda          GIT "https://github.com/JCSDA/ioda.git"                 BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT ufo           GIT "https://github.com/JCSDA/ufo.git"                  BRANCH develop             UPDATE )

# FV3 based model and/or FMS
# --------------------------
#Find GEOS or GFS and thus the version of FMS for fv3-jedi-lm
#find_package( FV3BASEDMODEL )
#if (NOT FV3BASEDMODEL_FOUND)
    ecbuild_bundle( PROJECT fms       GIT "https://github.com/JCSDA/FMS.git"                  BRANCH dev/master-ecbuild  UPDATE )
#endif()

# GFS model
# ---------
ecbuild_bundle( PROJECT gfs           GIT "https://github.com/danholdaway/gfs.git"            BRANCH develop  UPDATE )

# FV3-JEDI and the linearized model
# ---------------------------------
ecbuild_bundle( PROJECT femps         GIT "https://github.com/JCSDA/femps.git"                BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT fv3-jedi-lm   GIT "https://github.com/JCSDA/fv3-jedi-linearmodel.git" BRANCH develop             UPDATE )
ecbuild_bundle( PROJECT fv3-jedi      GIT "https://github.com/JCSDA/fv3-jedi.git"             BRANCH feature/gfs             UPDATE )

# Build Doxygen documentation
# ---------------------------
option(BUILD_FV3_BUNDLE_DOC "Build documentation" OFF)
if(BUILD_FV3_BUNDLE_DOC)
   add_subdirectory( Documentation )
endif(BUILD_FV3_BUNDLE_DOC)

ecbuild_bundle_finalize()





