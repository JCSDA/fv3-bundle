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
ecbuild_bundle( PROJECT jedicmake GIT "https://github.com/jcsda/jedi-cmake.git" BRANCH develop UPDATE )

# ECMWF libraries
option("BUNDLE_SKIP_ECKIT" "Don't build eckit" "ON" ) # Skip eckit build unless user passes -DBUNDLE_SKIP_ECKIT=OFF
option("BUNDLE_SKIP_FCKIT" "Don't build fckit" "ON") # Skip fckit build unless user passes -DBUNDLE_SKIP_FCKIT=OFF
option("BUNDLE_SKIP_ATLAS" "Don't build atlas" "ON") # Skip atlas build unless user passes -DBUNDLE_SKIP_ATLAS=OFF

ecbuild_bundle( PROJECT eckit GIT "https://github.com/ecmwf/eckit.git" TAG 1.16.0 )
ecbuild_bundle( PROJECT fckit GIT "https://github.com/ecmwf/fckit.git" TAG 0.9.2 )
ecbuild_bundle( PROJECT atlas GIT "https://github.com/ecmwf/atlas.git" TAG 0.24.1 )

# External (required) observation operators
ecbuild_bundle( PROJECT crtm GIT "https://github.com/jcsda/crtm.git"   TAG v2.3-jedi.0 )

# Core JEDI repositories
ecbuild_bundle( PROJECT oops  GIT "https://github.com/jcsda/oops.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT saber GIT "https://github.com/jcsda/saber.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ioda  GIT "https://github.com/jcsda/ioda.git"  BRANCH develop UPDATE )
ecbuild_bundle( PROJECT ufo   GIT "https://github.com/jcsda/ufo.git"   BRANCH develop UPDATE )

# FMS and FV3 dynamical core
ecbuild_bundle( PROJECT fms GIT "https://github.com/jcsda/FMS.git" BRANCH release-stable UPDATE )
ecbuild_bundle( PROJECT fv3 GIT "https://github.com/jcsda/GFDL_atmos_cubed_sphere.git" BRANCH release-stable UPDATE )

# fv3-jedi and associated repositories
ecbuild_bundle( PROJECT femps       GIT "https://github.com/jcsda/femps.git"                BRANCH develop UPDATE )
ecbuild_bundle( PROJECT fv3-jedi-lm GIT "https://github.com/jcsda/fv3-jedi-linearmodel.git" BRANCH develop UPDATE )
ecbuild_bundle( PROJECT fv3-jedi    GIT "https://github.com/jcsda/fv3-jedi.git"             BRANCH develop UPDATE )

# ioda, ufo, fv3-jedi, and saber test data
#---------------------------------

# If IODA branch is being built set GIT_BRANCH_FUNC to IODA's current branch.
# If a tagged version of IODA is being built set GIT_TAG_FUNC to ioda's current tag. In this case,
# IODA test files will be download from UCAR DASH and ioda-data repo will not be cloned.
# When LOCAL_PATH_JEDI_TESTFILES is set to the directory of IODA test files stored
# in a local directory, ioda-data repo will not be cloned

find_branch_name(REPO_DIR_NAME ioda)
# When LOCAL_PATH_JEDI_TESTFILES is set to the directory of IODA test files stored
# in a local directory, ioda-data repo will not be cloned
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED GIT_TAG_FUNC )
  ecbuild_bundle( PROJECT ioda-data GIT "https://github.com/JCSDA-internal/ioda-data.git" BRANCH develop UPDATE )

  # If IODA's current branch is available in ioda-data repo, that branch will be checked out
  branch_checkout (REPO_DIR_NAME ioda-data
                   BRANCH ${GIT_BRANCH_FUNC} )
endif()

# same procedure for ufo-data
find_branch_name(REPO_DIR_NAME ufo)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED GIT_TAG_FUNC )
  ecbuild_bundle( PROJECT ufo-data GIT "https://github.com/JCSDA-internal/ufo-data.git" BRANCH develop UPDATE )

  # If UFO's current branch is available in ioda-data repo, that branch will be checked out
  branch_checkout (REPO_DIR_NAME ufo-data
                   BRANCH ${GIT_BRANCH_FUNC} )
endif()

# same procedure for fv3-jedi-data
find_branch_name(REPO_DIR_NAME fv3-jedi)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED GIT_TAG_FUNC )
  ecbuild_bundle( PROJECT fv3-jedi-data GIT "https://github.com/JCSDA-internal/fv3-jedi-data.git" BRANCH develop UPDATE )

  # If fv3-jedi's current branch is available in ioda-data repo, that branch will be checked out
  branch_checkout (REPO_DIR_NAME fv3-jedi-data
                   BRANCH ${GIT_BRANCH_FUNC} )
endif()

# same procedure for saber-data
find_branch_name(REPO_DIR_NAME saber)
if( NOT DEFINED ENV{LOCAL_PATH_JEDI_TESTFILES} AND NOT DEFINED GIT_TAG_FUNC )
  ecbuild_bundle( PROJECT saber-data GIT "https://github.com/JCSDA-internal/saber-data.git" BRANCH develop UPDATE )

  # If saber's current branch is available in saber-data repo, that branch will be checked out
  branch_checkout (REPO_DIR_NAME saber-data
                   BRANCH ${GIT_BRANCH_FUNC} )
endif()

# Finalize bundle
# ---------------
ecbuild_bundle_finalize()
