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

#  ESMF_FOUND - System has ESMF
#  ESMF_INCLUDE_DIRS - The ESMF include directories
#  ESMF_LIBRARIES - The libraries needed to use ESMF
#  ESMF_DEFINITIONS - Compiler switches required for using ESMF

#  Only one of the following:
#  GFS_FOUND  - System has GFS
#  GEOS_FOUND - System has GEOS


# Determine which model (if any)
# ------------------------------
if( DEFINED FV3BASEDMODEL_PATH )
  if(EXISTS ${FV3BASEDMODEL_PATH}/lib/libMAPL_Base.a)
    set (GEOS_FOUND 1)
  elseif(EXISTS ${FV3BASEDMODEL_PATH}/libfv3cap.a) #Or something like that
    set (GFS_FOUND 1)
  else()
    message( WARNING "FV3BASEDMODEL not found" )
  endif()
endif()


# Model specific part
# -------------------
if (GEOS_FOUND)
 
  message("Found GEOS model, building library and include lists")

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
    list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/include/${GEOS_DEP})
  endforeach()

  #ESMF
  message("ESMF_PATH: ${ESMF_PATH}")
  if( NOT DEFINED ESMF_PATH )
    message(FATAL_ERROR "Fatal error, GEOS model found but path to ESMF not provided.")
  endif()

  find_library(LIBTMP esmf PATHS ${ESMF_PATH}/lib/)
  list( APPEND FV3BASEDMODEL_LIBRARY ${LIBTMP})
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${ESMF_PATH}/include/esmf)

  #FMS (seperate package for fv3-jedi-lm)
  find_library(FMS_LIBRARY GFDL_fms_r8 PATHS ${FV3BASEDMODEL_PATH}/lib/)
  set (FMS_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/include/GFDL_fms_r8)

elseif (GFS_FOUND)

  message("Found GFS model, building library and include lists")

  list( APPEND GFS_DEPS fv3cap
                        fv3core
                        fv3cpl
                        fv3io
                        gfsphys
                        ipd
                        stochastic_physics)

  foreach(GFS_DEP ${GFS_DEPS})
    find_library(LIBTMP ${GFS_DEP} PATHS ${FV3BASEDMODEL_PATH}/)
    list( APPEND FV3BASEDMODEL_LIBRARY ${LIBTMP})
  endforeach()

  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH})

  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/nemsio/v2.2.3/libnemsio_v2.2.3.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/bacio/v2.0.1/libbacio_v2.0.1_4.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/sp/v2.0.2/libsp_v2.0.2_d.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/w3emc/v2.0.5/libw3emc_v2.0.5_d.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/w3nco/v2.0.6/libw3nco_v2.0.6_d.a)

  #ESMF
  find_library(LIBTMP esmf PATHS ${ESMF_PATH}/lib/libO/Linux.intel.64.intelmpi.default/)
  list( APPEND FV3BASEDMODEL_LIBRARY ${LIBTMP})
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${ESMF_PATH}/include)

  #FMS (seperate package for fv3-jedi-lm)
  find_library(FMS_LIBRARY fms PATHS /scratch4/NCEPDEV/nems/save/Jun.Wang/jedi/20181109/fv3-bundle/fms/build/lib)
  set (FMS_INCLUDE_DIR /scratch4/NCEPDEV/nems/save/Jun.Wang/jedi/20181109/fv3-bundle/fms/build/module)

endif()


# General flags
# -------------

include(FindPackageHandleStandardArgs)

#FV3BASEDMODEL
find_package_handle_standard_args(FV3BASEDMODEL DEFAULT_MSG FV3BASEDMODEL_LIBRARY FV3BASEDMODEL_INCLUDE_DIR)
mark_as_advanced(FV3BASEDMODEL_INCLUDE_DIR FV3BASEDMODEL_LIBRARY )

#FMS
find_package_handle_standard_args(FMS DEFAULT_MSG FMS_LIBRARY FMS_INCLUDE_DIR)
mark_as_advanced(FMS_INCLUDE_DIR FMS_LIBRARY )

if( FV3BASEDMODEL_FOUND )
    set( FV3BASEDMODEL_LIBRARIES    ${FV3BASEDMODEL_LIBRARY} )
    set( FV3BASEDMODEL_INCLUDE_DIRS ${FV3BASEDMODEL_INCLUDE_DIR} )
    set( FMS_LIBRARIES    ${FMS_LIBRARY} )
    set( FMS_INCLUDE_DIRS ${FMS_INCLUDE_DIR} )
else()
    set( FV3BASEDMODEL_LIBRARIES    "" )
    set( FV3BASEDMODEL_INCLUDE_DIRS "" )
    set( FMS_LIBRARIES    "" )
    set( FMS_INCLUDE_DIRS "" )
endif()
