-FV3 1.0.0 RELEASE NOTES

The Joint Effort for Data assimilation Integration (JEDI) is a development project led by the Joint Center for Satellite Data Assimilation (JCSDA). The purpose of JEDI is to provide a comprehensive generic data assimilation system that will accelerate data assimilation developments and the uptake of new observation platforms for the community.
 
JEDI-FV3 1.0.0 is the initial release of the implementation of JEDI for models based on the FV3 dynamical core. In the initial release this includes global numerical weather prediction (NWP) with NOAA’s Unified Forecast System (UFS) running the Global Forecast System (GFS) and NASA’s Goddard Earth Observing System (GEOS).

## SOURCE CODE

JEDI-FV3 1.0.0 is highly modular software and the required source code spans several repositories in various categories. All this software is available open source from https://github.com/JCSDA

* The generic data assimilation components **OOPS**, **UFO**, **SABER** and **IODA** provide the central data assimilation capabilities. **OOPS** is the heart of JEDI, defining interfaces and data assimilation applications. **UFO** provides generic observation operators. **IODA** provides the in-memory data access and management and IO for observations. **SABER** provides generic interfaces for covariance matrix operations.
* **FV3-JEDI** implements the JEDI applications for FV3-based forecast models and provides all the configuration and executables for running applications.
* **FV3-JEDI-LINEARMODEL** contains the tangent linear and adjoint versions of FV3 and physics, built by NASA’s Global Modeling and Assimilation Office. 
* **GFDL_atmos_cubed_sphere** and **FMS** provide the FV3 dynamical core and its associated library. These are provided by NOAA but contain minor modifications to provide a JEDI-friendly build system.
* **FEMPS** is a Finite element mesh Poisson solver that works on cubed-sphere fields and is used in error covariance modeling.
* The libraries **ECKIT**, **FCKIT** and **ATLAS** provide general utilities used by all other components.

Descriptions of the various components of JEDI are available [here](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/inside/jedi-components/index.html).

## BUILD SYSTEM

Several modes of building and running JEDI-FV3 are supported with this release:
* Using a pre-compiled [tutorial container](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/learning/tutorials/level1/index.html).
* Using a [development container](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/learning/tutorials/level2/index.html). 
* Using [Amazon Web Services](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/cloud/index.html).
* Using pre-prepared modules maintained on several [HPC platforms](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/modules.html?highlight=modules). These include NOAA's Hera machine, NASA NCCS's Discover machine, UCAR's Cheyenne machine, Orion at Mississippi State and S4 at the University of Wisconsin 
* By self installing all of the dependencies using [JEDI-STACK](https://github.com/JCSDA/jedi-stack). This repository includes everything required to build the system, beginning with installation of the source code compilers.

Unless working in the application container (where the code is pre-built) users clone only the FV3-BUNDLE to get started. FV3-BUNDLE is essentially a convenience package that will clone clone and build all the required JEDI-FV3 dependencies. Users can obtain this software with:

`git clone -b 1.0.0 https://github.com/jcsda/fv3-bundle`

## DOCUMENTATION AND SUPPORT

Documentation for JEDI-FV3 can be found at [jedi-docs](https://jedi-docs.jcsda.org). Users are encouraged to explore the documentation for detailed descriptions of the source code, development practices and build systems. Note that users are also encouraged to contribute to the documentation, which can be done by submitting to the JEDI-DOCS repository at https://github.com/JCSDA/jedi-docs. JEDI source code includes DOXYGEN comments and the DOXYGEN generated pages can be found under the documentation for [each component](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/inside/jedi-components/index.html). These pages are useful for learning more about the way the software is structured.

## APPLICATIONS

JEDI-FV3 is provided with input files for performing a number of applications with JEDI-FV3. Users can perform an observation simulation application, known as ‘h(x)’ or can run variational data assimilation with the 3DEnVar algorithm. Supported resolutions for UFS/GFS are C12, C24, C48, C96 and C192. Supported resolutions for GEOS are C12, C24, C48, C90, C180. The values in these resolutions refer to the standard way in which FV3 determines resolution, by the number of grid cells along a face of the cube. C96 means 96 by 96 grid cells on each face, which equates to approximately 100km. In addition to the h(x) and variational applications several utility applications are provided. The Parameters application can be used to generate fixed or dynamic localization operators using SABER. The ConvertState application can be used to change the resolution of cubed-sphere fields. The DiffStates application can be used to create an increment from the difference of the analysis and background.

## POST PROCESSING AND VISUALIZATION

### Analysis fields

JEDI-FV3 works directly with cubed-sphere data structures and can read data in two formats,  GFS restarts and GEOS restarts. Data can be output in these same formats as well as interpolated to longitude and latitude grids. Cubed-sphere fields written in the GEOS format can be visualized easily with the [Panoply](https://www.giss.nasa.gov/tools/panoply/) software developed by NASA. A lightweight Python utility is provided for visualizing fields on a longitude-latitude grid. 

### Observations

Utilities are provided for plotting observation statistics from the data output by IODA. Use of these tools can be explored through the [tutorials](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/learning/tutorials/index.html).

