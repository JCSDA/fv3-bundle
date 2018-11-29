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

#  Only one of the following:
#  GFS_FOUND  - System has GFS
#  GEOS_FOUND - System has GEOS

message("TRYING TO FIND A MODEL")

set (GFS_FOUND 0)
set (GEOS_FOUND 0)
set (FV3BASEDMODEL_FOUND 0)
if( DEFINED FV3BASEDMODEL_PATH )
  if(EXISTS ${FV3BASEDMODEL_PATH}/lib/libMAPL_Base.a)
    set (GEOS_FOUND 1)
  elseif(EXISTS ${FV3BASEDMODEL_PATH}/lib/libNEMS_Base.a) #Or something like that
    set (GFS_FOUND 1)
  endif()
endif()


if (GEOS_FOUND)
 
  #List of GEOS dependencies, could GLOB but r4-r8 duplicates
  list( APPEND GEOS_DEPS Chem_Base
                         Chem_Shared
                         GEOS_Shared
                         GMAO_eu
                         GMAO_gfio
                         GMAO_hermes
                         GMAO_mpeu
                         GMAO_pFIO
                         GMAO_pilgrim
                         LANL_cice
                         MAPL_Base
                         MAPL_cfio
                         NSIDC-OSTIA_SST-ICE_blend
                         post )
  
  foreach(GEOS_DEP ${GEOS_DEPS})
    find_library(LIBTMP ${GEOS_DEP} PATHS ${FV3BASEDMODEL_PATH}/lib/)
    list( APPEND FV3BASEDMODEL_LIBRARY ${LIBTMP})
    list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/include/${GEOS_DIR})
  endforeach()

  find_library(LIBTMP ${GEOS_DEP} PATHS ${FV3BASEDMODEL_PATH}/lib/)

elseif (GFS_FOUND)

message("GFS_FOUND")

endif()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(FV3BASEDMODEL DEFAULT_MSG FV3BASEDMODEL_LIBRARY FV3BASEDMODEL_INCLUDE_DIR)
mark_as_advanced(FV3BASEDMODEL_INCLUDE_DIR FV3BASEDMODEL_LIBRARY )

if( FV3BASEDMODEL_FOUND )
    set( FV3BASEDMODEL_LIBRARIES    ${FV3BASEDMODEL_LIBRARY} )
    set( FV3BASEDMODEL_INCLUDE_DIRS ${FV3BASEDMODEL_INCLUDE_DIR} )
else()
    set( FV3BASEDMODEL_LIBRARIES    "" )
    set( FV3BASEDMODEL_INCLUDE_DIRS "" )
endif()

message("FV3BASEDMODEL_LIBRARIES ${FV3BASEDMODEL_LIBRARIES}")
message("FV3BASEDMODEL_INCLUDE_DIRS ${FV3BASEDMODEL_INCLUDE_DIRS}")

