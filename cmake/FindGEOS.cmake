# (C) Copyright 2018 UCAR.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

# - Try to find GEOS and if so FMS
# Once done this will define:

#  GEOS_FOUND - System has an GEOS
#  GEOS_INCLUDE_DIRS - The GEOS include directories
#  GEOS_LIBRARIES - The libraries needed to use GEOS
#  GEOS_DEFINITIONS - Compiler switches required for using GEOS

#  FMS_FOUND - System has FMS
#  FMS_INCLUDE_DIRS - The FMS include directories
#  FMS_LIBRARIES - The libraries needed to use FMS
#  FMS_DEFINITIONS - Compiler switches required for using FMS

#  ESMF_FOUND - System has ESMF
#  ESMF_INCLUDE_DIRS - The ESMF include directories
#  ESMF_LIBRARIES - The libraries needed to use ESMF
#  ESMF_DEFINITIONS - Compiler switches required for using ESMF

#  Only one of the following:
#  GEOS_FOUND - System has GEOS


# Determine which model (if any)
# ------------------------------
if( DEFINED GEOS_PATH )
  if(EXISTS ${GEOS_PATH}/lib/libMAPL_Base.a)
    set (GEOS_FOUND 1)
  else()
    message( WARNING "GEOS_PATH found" )
  endif()
else()
  message( WARNING "GEOS_PATH not found" )
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
  list( APPEND GEOS_LIBRARY ${BASELIBDIR}/lib/libesmf.a)
  list( APPEND GEOS_INCLUDE_DIR ${BASELIBDIR}/include/esmf)

  #gFTL
  list( APPEND GEOS_INCLUDE_DIR ${BASELIBDIR}/gFTL/include)

  #FLAP
  list( APPEND GEOS_LIBRARY ${BASELIBDIR}/lib/libflap.a)
  list( APPEND GEOS_INCLUDE_DIR ${BASELIBDIR}/include/FLAP)

  #pFUnit
  list( APPEND GEOS_LIBRARY ${BASELIBDIR}/pFUnit/pFUnit-mpi/lib/libpfunit.a)
  list( APPEND GEOS_INCLUDE_DIR ${BASELIBDIR}/pFUnit/pFUnit-mpi/include)


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
    list( APPEND GEOS_LIBRARY ${GEOS_PATH}/lib/lib${GEOS_DEP}.a)
    list( APPEND GEOS_INCLUDE_DIR ${GEOS_PATH}/include/${GEOS_DEP})
  endforeach()

  #FMS
  find_library(FMS_LIBRARY GFDL_fms_r8 PATHS ${GEOS_PATH}/lib/)
  set (FMS_INCLUDE_DIR ${GEOS_PATH}/include/GFDL_fms_r8)

endif()


# General flags
# -------------

include(FindPackageHandleStandardArgs)

#GEOS
find_package_handle_standard_args(GEOS DEFAULT_MSG GEOS_LIBRARY GEOS_INCLUDE_DIR)
mark_as_advanced(GEOS_INCLUDE_DIR GEOS_LIBRARY )

#FMS
find_package_handle_standard_args(FMS DEFAULT_MSG FMS_LIBRARY FMS_INCLUDE_DIR)
mark_as_advanced(FMS_INCLUDE_DIR FMS_LIBRARY )

if( GEOS_FOUND )
    set( GEOS_LIBRARIES    ${GEOS_LIBRARY} )
    set( GEOS_INCLUDE_DIRS ${GEOS_INCLUDE_DIR} )
    set( FMS_LIBRARIES    ${FMS_LIBRARY} )
    set( FMS_INCLUDE_DIRS ${FMS_INCLUDE_DIR} )
else()
    set( GEOS_LIBRARIES    "" )
    set( GEOS_INCLUDE_DIRS "" )
    set( FMS_LIBRARIES    "" )
    set( FMS_INCLUDE_DIRS "" )
endif()
