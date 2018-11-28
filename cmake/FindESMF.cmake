# (C) Copyright 2018 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# - Try to find EMSF
# Once done this will define:

#  If GEOS or GFS is found also need to link to ESMF
#  ESMF_FOUND - System has ESMF
#  ESMF_INCLUDE_DIRS - The ESMF include directories
#  ESMF_LIBRARIES - The libraries needed to use ESMF
#  ESMF_DEFINITIONS - Compiler switches required for using ESMF


if( DEFINED ESMF_PATH )
     find_path(EMSF_INCLUDE_DIR ESMF.h PATHS ${ESMF_PATH} PATH_SUFFIXES esmf NO_DEFAULT_PATH)
  find_library(ESMF_LIBRARY esmf       PATHS ${ESMF_PATH} PATH_SUFFIXES esmf NO_DEFAULT_PATH)
endif()

find_path(EMSF_INCLUDE_DIR ESMF.h PATH_SUFFIXES esmf )
find_library( ESMF_LIBRARY esmf     PATH_SUFFIXES esmf )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set ESMF_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(ESMF  DEFAULT_MSG
                                  ESMF_LIBRARY ESMF_INCLUDE_DIR)

mark_as_advanced(ESMF_INCLUDE_DIR ESMF_LIBRARY )

if( ESMF_FOUND )
    set( ESMF_LIBRARIES    ${ESMF_LIBRARY} )
    set( ESMF_INCLUDE_DIRS ${ESMF_INCLUDE_DIR} )
else()
    set( ESMF_LIBRARIES    "" )
    set( ESMF_INCLUDE_DIRS "" )
endif()
