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
  elseif(EXISTS ${FV3BASEDMODEL_PATH}/FV3_INSTALL/libfv3cap.a) #Or something like that
    set (GFS_FOUND 1)
  else()
    message( WARNING "FV3BASEDMODEL_PATH found" )
  endif()
else()
  message( WARNING "FV3BASEDMODEL_PATH not found" )
endif()


# Model specific part
# -------------------
if (GEOS_FOUND)
 
  message("Found GEOS model, building library and include lists")

  if( NOT DEFINED BASELIBDIR )
    message(FATAL_ERROR "Fatal error: GEOS model found but not BASELIBDIR.")
  endif()

  # BASELIBS
  # --------

  #ESMF
  list( APPEND FV3BASEDMODEL_LIBRARY ${BASELIBDIR}/lib/libesmf.a)
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${BASELIBDIR}/include/esmf)

  #gFTL
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${BASELIBDIR}/gFTL/include)

  #FLAP
  list( APPEND FV3BASEDMODEL_LIBRARY ${BASELIBDIR}/lib/libflap.a)
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${BASELIBDIR}/include/FLAP)

  #pFUnit
  list( APPEND FV3BASEDMODEL_LIBRARY ${BASELIBDIR}/pFUnit/pFUnit-mpi/lib/libpfunit.a)
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${BASELIBDIR}/pFUnit/pFUnit-mpi/include)


  #GEOS libraries
  #--------------

  #List of GEOS libraries (order important)
  #cd GEOSagcm/Linux/src
  #ls -lt
  list( APPEND GEOS_DEPS GEOSgcs_GridComp
                         GEOSgcm_GridComp
                         GEOSagcm_GridComp
                         GEOSmkiau_GridComp
                         GEOSphysics_GridComp
                         GEOSradiation_GridComp
                         GEOSsolar_GridComp
                         GEOSirrad_GridComp
                         RRTMG
                         GEOSgwd_GridComp
                         RRTMG_mods
                         RRTMG_SW
                         RRTMG_SW_mods
                         GEOSsatsim_GridComp
                         GEOS_RadiationShared
                         GEOSmoist_GridComp
                         GEOSturbulence_GridComp
                         GEOSsurface_GridComp
                         GEOSlake_GridComp
                         GEOSlandice_GridComp
                         GEOSsaltwater_GridComp
                         GEOSland_GridComp
                         GEOScatch_GridComp
                         GEOScatchCN_GridComp
                         GEOSvegdyn_GridComp
                         GEOS_LandShared
                         GEOS_SurfaceShared
                         GEOSchem_GridComp
                         StratChem_GridComp
                         GEOSpchem_GridComp
                         GEOSachem_GridComp
                         GMIchem_GridComp
                         GAAS_GridComp
                         GOCART_GridComp
                         CFC_GridComp
                         CARMAchem_GridComp
                         Rn_GridComp
                         BC_GridComp
                         BRC_GridComp
                         CO2_GridComp
                         CO_GridComp
                         DU_GridComp
                         O3_GridComp
                         OC_GridComp
                         SS_GridComp
                         SU_GridComp
                         CH4_GridComp
                         NI_GridComp
                         MAMchem_GridComp
                         TR_GridComp
                         MATRIXchem_GridComp
                         DNA_GridComp
                         HEMCO_GridComp
                         GEOSsuperdyn_GridComp
                         FVdycore_GridComp
                         FVdycoreCubed_GridComp
                         ARIESg3_GridComp
                         GEOSdatmodyn_GridComp
                         fvdycore
                         GMAO_pilgrim
                         GEOSogcm_GridComp
                         GuestOcean_GridComp
                         GEOSdatasea_GridComp
                         GEOSdataseaice_GridComp
                         GEOSorad_GridComp
                         LANL_cice
                         NCEP_sp_r4i4
                         Chem_Shared
                         Chem_Base
                         GEOS_Shared
                         MAPL_Base
                         GMAO_pFIO
                         MAPL_cfio_r4
                         GMAO_gfio_r4
                         GMAO_hermes
                         GMAO_mpeu )
  
  foreach(GEOS_DEP ${GEOS_DEPS})
    list( APPEND FV3BASEDMODEL_LIBRARY ${FV3BASEDMODEL_PATH}/lib/lib${GEOS_DEP}.a)
    list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/include/${GEOS_DEP})
  endforeach()

  #FMS
  find_library(FMS_LIBRARY GFDL_fms_r8 PATHS ${FV3BASEDMODEL_PATH}/lib/)
  set (FMS_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/include/GFDL_fms_r8)

elseif (GFS_FOUND)

  message("Found GFS model, building library and include lists")

  #NEMSfv3gfs libraries (order from fv3.mk)
  list( APPEND GFS_DEPS fv3cap
                        fv3core
                        fv3io
                        ipd
                        gfsphys
                        fv3cpl
                        stochastic_physics )
  foreach(GFS_DEP ${GFS_DEPS})
    list( APPEND FV3BASEDMODEL_LIBRARY ${FV3BASEDMODEL_PATH}/FV3_INSTALL/lib${GFS_DEP}.a)
  endforeach()

  #NEMSfv3gfs includes
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH})
  list( APPEND GFS_INCS FV3_INSTALL
                        atmos_cubed_sphere
                        io
                        fms
                        gfsphysics
                        cpl
                        ipd )
  foreach(GFS_INC ${GFS_INCS})
    list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${FV3BASEDMODEL_PATH}/${GFS_INC})
  endforeach()

  #FMS (seperate package for fv3-jedi-lm)
  find_library(FMS_LIBRARY fms PATHS /scratch4/NCEPDEV/nems/save/Jun.Wang/jedi/20181109/fv3-bundle/fms/build/lib)
  set (FMS_INCLUDE_DIR /scratch4/NCEPDEV/nems/save/Jun.Wang/jedi/20181109/fv3-bundle/fms/build/module)

  #Supporting libraries
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/nemsio/v2.2.3/libnemsio_v2.2.3.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/bacio/v2.0.1/libbacio_v2.0.1_4.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/sp/v2.0.2/libsp_v2.0.2_d.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/w3emc/v2.0.5/libw3emc_v2.0.5_d.a)
  list( APPEND FV3BASEDMODEL_LIBRARY /scratch3/NCEPDEV/nwprod/lib/w3nco/v2.0.6/libw3nco_v2.0.6_d.a)

  #ESMF
  list( APPEND FV3BASEDMODEL_LIBRARY ${ESMF_PATH}/lib/libesmf.a)
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${ESMF_PATH}/include)
  list( APPEND FV3BASEDMODEL_INCLUDE_DIR ${ESMF_PATH}/mod)

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
