#!/bin/csh -f

#Script for compiling JEDI on the NASA Center for Climate Similation (NCCS) Discover cluster

#Argument 1 specified the compiler choice
#Argument 2 is optional, set to clean to build from scratch

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
setenv FV3JEDI_ROOT ${FV3JEDI_SRC}/..

#Where is ecbuild?
setenv ecbuild_path $FV3JEDI_ROOT/ecbuild
set path = (${path} ${ecbuild_path}/bin)
if (! -f $ecbuild_path/bin/ecbuild) then
  echo "Did not find ecbuild, exiting"
  exit()
endif

#Source the modules
module purge
module load other/cmake-3.8.2
module use -a /discover/nobackup/drholdaw/Jedi/Jedi_Shared/modulefiles

if ($1 == "INT" || $1 == "Int" || $1 == "Intel"  || $1 == "intel") then

   module load other/comp/gcc-6.2
   module load comp/intel-18.0.1.163
   module load mpi/impi-18.0.1.163
   module load lib/mkl-18.0.1.163
   setenv BASEDIR /discover/swdev/mathomp4/Baselibs/ESMA-Baselibs-5.0.9/x86_64-unknown-linux-gnu/ifort_18.0.1.163-intelmpi_18.0.1.163/Linux/ 

   setenv MPIEXEC `which mpirun`
   setenv CPCcomp mpiicpc
   setenv CCcomp mpiicc
   setenv F90comp mpiifort
   
   module load boost/1.66.0_int
   module load eigen/3.3.4_int

   setenv JEDI_BUILD $FV3JEDI_ROOT/build_int

   #Boost/Eigen include dirs
   setenv BOOST_ROOT /discover/nobackup/drholdaw/Jedi/Jedi_Shared/boost/1.66.0_int/include/
   setenv EIGEN3_PATH /discover/nobackup/drholdaw/Jedi/Jedi_Shared/eigen/3.3.4_int/include/

else if ($1 == "GCC" || $1 == "gcc" || $1 == "GNU" || $1 == "gnu") then

   module load other/comp/gcc-7.2
   module load other/mpi/openmpi/3.0.0-gcc-7.2
   module load lib/mkl-18.0.1.163
   setenv BASEDIR /discover/swdev/mathomp4/Baselibs/ESMA-Baselibs-4.0.10/x86_64-unknown-linux-gnu/gfortran_7.2.0-openmpi_3.0.0/Linux

   setenv MPIEXEC `which mpirun`
   setenv CPCcomp mpicxx
   setenv CCcomp mpicc
   setenv F90comp mpifort

   module load boost/1.66.0_gcc
   module load eigen/3.3.4_gcc

   setenv JEDI_BUILD $FV3JEDI_ROOT/build_gcc

   #Boost/Eigen include dirs
   setenv BOOST_ROOT /discover/nobackup/drholdaw/Jedi/Jedi_Shared/boost/1.66.0_gcc/include/
   setenv EIGEN3_PATH /discover/nobackup/drholdaw/Jedi/Jedi_Shared/eigen/3.3.4_gcc/include/

endif

#NetCDF lib search path
setenv NETCDF $JEDI_BUILD/netcdf
setenv NETCDF_INCLUDE_DIRS $JEDI_BUILD/netcdf/include #Need in order not to auto redefine NETCDF_LIBRARIES
setenv NETCDF_LIBRARIES "$JEDI_BUILD/netcdf/lib/libnetcdf.a;$JEDI_BUILD/netcdf/lib/libnetcdff.a;${BASEDIR}/lib/libhdf5_hl.a;${BASEDIR}/lib/libhdf5.a;${BASEDIR}/lib/libcurl.a;/usr/lib64/libcrypto.so;/usr/lib64/libssl.so;${BASEDIR}/lib/libmfhdf.a;${BASEDIR}/lib/libdf.a;${BASEDIR}/lib/libjpeg.a"

#FMS/FV3 COMPDEFS
setenv COMPDEFS "-DsysLinux;-DESMA64;-DHAS_NETCDF4;-DHAS_NETCDF3;-DH5_HAVE_PARALLEL;-DNETCDF_NEED_NF_MPIIO;-DEIGHT_BYTE;-DSPMD;-DTIMING;-Duse_libMPI;-Duse_netCDF;-DHAVE_SHMEM;-DMAPL_MODE;-DOLDMPP"

#Add Basebin to path, configs for libraries
set path = (${path} ${BASEDIR}/bin)

if ($2 == "clean" || ! -d $JEDI_BUILD) then

   #Prepare the build directory
   echo "Building to: " $JEDI_BUILD
   echo $FV3JEDI_SRC
   rm -rf ${JEDI_BUILD}
   mkdir -p ${JEDI_BUILD}
   
   #Create netcdf lib/include that has expected structure
   cd ${JEDI_BUILD}
   rm -rf netcdf
   mkdir netcdf
   cd netcdf
   ln -s $BASEDIR/lib ./
   ln -s $BASEDIR/include/netcdf ./include
   
   #ECBuild
   cd ${JEDI_BUILD}
   ecbuild \
       --build=debug \
       -DCMAKE_CXX_COMPILER=$CPCcomp \
       -DCMAKE_C_COMPILER=$CCcomp \
       -DCMAKE_Fortran_COMPILER=$F90comp \
       -DBOOST_ROOT=$BOOST_ROOT -DBoost_NO_SYSTEM_PATHS=ON \
       -DNETCDF_LIBRARIES=$NETCDF_LIBRARIES \
       -DNETCDF_INCLUDE_DIRS=$NETCDF_INCLUDE_DIRS \
       -DNETCDF_PATH=$NETCDF \
       -DMPIEXEC=$MPIEXEC \
       -DCOMPDEFS=$COMPDEFS \
       -DFMS_PATH=$JEDI_BUILD/fms/ \
       -DFV3_PATH=$JEDI_BUILD/fv3/ \
       ${FV3JEDI_SRC}

endif

#CMake
cd ${JEDI_BUILD}
make -j4

#Uncomment to run tests
#cd ${JEDI_BUILD}
#ctest
