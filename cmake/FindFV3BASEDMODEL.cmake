# (C) Copyright 2018 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# - Try to find GEOS or GFS and if so FMS
# Once done this will define:

#  FV3BASEDMODEL_FOUND - System has an FV3BASEDMODEL
#  FV3BASEDMODEL_INCLUDE_DIRS - The FV3BASEDMODEL include directories
#  FV3BASEDMODEL_LIBRARIES - The libraries needed to use FV3BASEDMODEL
#  FV3BASEDMODEL_DEFINITIONS - Compiler switches required for using FV3BASEDMODEL

#  FMS_FOUND - System has FMS
#  FMS_INCLUDE_DIRS - The FMS include directories
#  FMS_LIBRARIES - The libraries needed to use FMS
#  FMS_DEFINITIONS - Compiler switches required for using FMS

if( DEFINED FMS_PATH )
    find_path(FMS_INCLUDE_DIR fms_platform.h PATHS ${FMS_PATH} PATH_SUFFIXES fms NO_DEFAULT_PATH)
	find_library(FMS_LIBRARY  fms            PATHS ${FMS_PATH} PATH_SUFFIXES fms NO_DEFAULT_PATH)
endif()

find_path(FMS_INCLUDE_DIR fms_platform.h PATH_SUFFIXES fms )
find_library( FMS_LIBRARY fms            PATH_SUFFIXES fms )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set FMS_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(FMS  DEFAULT_MSG
                                  FMS_LIBRARY FMS_INCLUDE_DIR)

mark_as_advanced(FMS_INCLUDE_DIR FMS_LIBRARY )

if( FMS_FOUND )
    set( FMS_LIBRARIES    ${FMS_LIBRARY} )
    set( FMS_INCLUDE_DIRS ${FMS_INCLUDE_DIR} )
else()
    set( FMS_LIBRARIES    "" )
    set( FMS_INCLUDE_DIRS "" )
endif()
