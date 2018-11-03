#!/bin/csh -f

#Script for compiling JEDI on the NASA Center for Climate Similation (NCCS) Discover cluster

#Argument 1: specified the compiler choice
#Argument 2: release or debug
#Argument 3: is optional, set to clean to build from scratch

if ($1 == "") then
  echo "Specifify either intel or gcc compiler, e.g. ./build_jedi_discover.csh intel clean"
  exit()
else
  echo "Building with $1 compiler"
endif

#Clear path
set path = /bin
set path = (${path} /usr/bin)

#Shell
source /usr/share/modules/init/csh

#Source/build environemnt
setenv FV3JEDI_SRC `pwd`
setenv FV3JEDI_ROOT ${FV3JEDI_SRC}

#Where is ecbuild?
setenv ecbuild_path /gpfsm/dnb04/projects/p72/drholdaw/JediShared/JediLibs/ecbuild/ecbuild_2.9.2/
set path = (${path} ${ecbuild_path}/bin)
if (! -f $ecbuild_path/bin/ecbuild) then
  echo "Did not find ecbuild, exiting"
  exit()
endif

if ($2 != "release" && $2 != "debug") then
  echo "Build mode not recognised"
  exit()
endif

if ($1 == "INT" || $1 == "Int" || $1 == "Intel"  || $1 == "intel" || $1 == "int") then

   #These two next lines should match
   setenv JEDI_MODULES /gpfsm/dnb04/projects/p72/drholdaw/JediShared/modules/jedi_modules_int17.0.7.259
   #setenv JEDI_MODULES /gpfsm/dnb04/projects/p72/drholdaw/JediShared/modules/jedi_modules_int18.0.3.222
   source $JEDI_MODULES

   setenv MPIEXEC `which mpirun`
   setenv CPCcomp mpiicpc
   setenv CCcomp mpiicc
   setenv F90comp mpiifort

   setenv JEDI_BUILD $FV3JEDI_ROOT/build_int_$2

else if ($1 == "GCC" || $1 == "gcc" || $1 == "GNU" || $1 == "gnu") then

   #These two next lines should match
   setenv JEDI_MODULES /gpfsm/dnb04/projects/p72/drholdaw/JediShared/modules/jedi_modules_gcc7.3
   source $JEDI_MODULES

   setenv MPIEXEC `which mpirun`
   setenv CPCcomp mpicxx
   setenv CCcomp mpicc
   setenv F90comp mpifort

   setenv JEDI_BUILD $FV3JEDI_ROOT/build_gcc_$2

endif

git lfs install

#NetCDF lib search path
setenv NETCDF $JEDI_BUILD/netcdf
setenv NETCDF_INCLUDE_DIRS $JEDI_BUILD/netcdf/include #Need in order not to auto redefine NETCDF_LIBRARIES
setenv NETCDF_LIBRARIES "$JEDI_BUILD/netcdf/lib/libnetcdf.a;$JEDI_BUILD/netcdf/lib/libnetcdff.a;${BASELIBDIR}/lib/libhdf5_hl.a;${BASELIBDIR}/lib/libhdf5.a;${BASELIBDIR}/lib/libcurl.a;/usr/lib64/libcrypto.so;/usr/lib64/libssl.so;${BASELIBDIR}/lib/libmfhdf.a;${BASELIBDIR}/lib/libdf.a;${BASELIBDIR}/lib/libjpeg.a"

#FMS/FV3 COMPDEFS
setenv COMPDEFS "-DsysLinux;-DESMA64;-DHAS_NETCDF4;-DHAS_NETCDF3;-DH5_HAVE_PARALLEL;-DNETCDF_NEED_NF_MPIIO;-DEIGHT_BYTE;-DSPMD;-DTIMING;-Duse_libMPI;-Duse_netCDF;-DHAVE_SHMEM;-DMAPL_MODE;-DOLDMPP"

#Add Basebin to path, configs for libraries
set path = (${path} ${BASELIBDIR}/bin)

if ($3 == "clean" || ! -d $JEDI_BUILD) then

   #Save username for a bit
   git config --global credential.helper 'cache --timeout=3600'

   #Prepare the build directory
   echo "Building to: " $JEDI_BUILD
   echo $FV3JEDI_SRC
   rm -rf ${JEDI_BUILD}
   mkdir -p ${JEDI_BUILD}

   #Move to build directory
   cd ${JEDI_BUILD}

   #Soft link to modules used for this build
   ln -s $JEDI_MODULES ./jedi_modules
   
   #Create netcdf lib/include that has expected structure
   rm -rf netcdf
   mkdir netcdf
   cd netcdf
   ln -s $BASELIBDIR/lib ./
   ln -s $BASELIBDIR/include/netcdf ./include
   
   #ECBuild
   cd ${JEDI_BUILD}
   ecbuild \
       --build=$2 \
       -DCMAKE_CXX_COMPILER=$CPCcomp \
       -DCMAKE_C_COMPILER=$CCcomp \
       -DCMAKE_Fortran_COMPILER=$F90comp \
       -DBOOST_ROOT=$BOOST_ROOT \
       -DBoost_NO_SYSTEM_PATHS=ON \
       -DNETCDF_LIBRARIES=$NETCDF_LIBRARIES \
       -DNETCDF_INCLUDE_DIRS=$NETCDF_INCLUDE_DIRS \
       -DNETCDF_PATH=$NETCDF \
       -DMPIEXEC=$MPIEXEC \
       -DCOMPDEFS=$COMPDEFS \
       -DFMS_PATH=$JEDI_BUILD/fms/ \
       -DFV3JEDILM_PATH=$JEDI_BUILD/fv3-jedi-lm/ \
       ${FV3JEDI_SRC}

endif

#CMake
cd ${JEDI_BUILD}
make -j12

#Uncomment to run tests
cd ${JEDI_BUILD}
ctest
