# JEDI-FV3 1.1.0 RELEASE NOTES

JCSDA is pleased to announce the public release of JEDI-FV3 1.1.0 on June 11, 2021.  JEDI-FV3 is a multi-component software package that provides everything that is needed to run DA applications for models that use the FV3 dynamical core, including NOAA’s Global Forecast System (GFS) and NASA’s Goddard Earth Observing System (GEOS).

## CHANGES RELATIVE TO JEDI-FV3 1.0.0

* Major update of IODA (version 2.0.0).
    - New internal data organization leveraging HDF5 data model (ioda-engines)
    - New data layout in files for more efficient access to multidimensional data
    - New interfaces to facilitate future integration of additional file formats (back end engines)
    - New python API leveraging python/C++ interoperability from the pybind11 package 
* Substantial enhancement of UFO capabilities
    - New observation operators, quality control filters, and bias correction codes have been developed to replicate operational capabilities, representing the cumulative effect of 410 updates to the UFO code.
    - UFO has all necessary functionality to replicate the NOAA-operational GSI system's H(x), bias correction (BC), and quality control (QC) procedures for many radiance, ozone, GNSSRO, and conventional instruments. Examples are provided in the repository.
        - For radiance-based instruments, UFO can fully reproduce H(x), BC, and QC for AIRS, AMSU-A, ATMS, AVHRR-3, CrIS, IASI, SEVIRI, and SSMI/S. H(x) and BC are implemented for MHS.
        - For ozone instruments, we reproduce H(x) for OMI, OMPS-limb, and OMPS-nadir.
        - For GNSSRO, H(x) and QC are implemented for AOPOD, GRAS, IGOR, and TGRS. 
        - For conventional instruments, we implement H(x) for Aircraft, RASS, Radar VAD wind, Satwind, Scatwind, surface land, and surface marine sensors.
* A new online tutorial highlighting the IODA data model and python API
* New management of tier 1 test data for develop and other branches
    - New ioda-data, ufo-data, and fv3-jedi-data LFS-enabled GitHub repositories (not required for tagged releases)

## Known Bugs and Issues

#### IODA file versioning

Moving to IODA version 2.0.0 requires a change in the layout in the ioda observation data files. Upgrading all of the ioda converter applications to natively write their output in the ioda-v2 format is work in progress, which is anticipated to be completed in the summer of 2021.

To cover this time when a particular ioda converter has not yet been upgraded to version 2.0, and to also handle the conversion of existing ioda version 1.0 files, a ioda file upgrader is provided with this release. This upgrader can be used to convert version 1.0 files (either existing files or new output files from older converters) into equivalent version 2.0 files for use with JEDI.

After building with your particular bundle, the upgrader application will appear in your build area in the path `bin/ioda-upgrade.x`. The usage for the upgrader is:

```bash
ioda-upgrade.x [-n] input_file output_file
```
`-n`: do not group similar variables into one 2D variable

The "-n" option is typically not necessary as it is reserved for a handful of problematic cases. Please see the ReadTheDocs documentation for more details.


#### IODA Python API

To use the ioda python api, one must build the bundle with the following option enabled:

```bash
ecbuild -DBUILD_PYTHON_BINDINGS=ON <path-to-bundle>/fv3-bundle/
```

Then, at run time, 

`LD_LIBRARY_PATH` needs to be set to `<install_area>/lib`, where <install_area> is either `your_build_area/lib` or `your_install_prefix/lib`.

`PYTHONPATH` needs to be set to `<install_area>/lib/python<version>`, where `<version>` is 3.6, 3.7, ... according to your python3 version.

Note: a recent version of `pybind11` is essential for this interface to work with all Python versions. In particular, the pybind11 project has noted that “Combining older versions of pybind11 (< 2.6.0) with Python 3.9.0 will trigger undefined behavior that typically manifests as crashes.” Please contact us if you encounter any difficulties.



---
# JEDI-FV3 1.0.0 RELEASE NOTES

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
* Using pre-prepared modules maintained on several [HPC platforms](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/jedi_environment/modules.html?highlight=modules). These include NOAA's Hera machine, NASA NCCS's Discover machine, UCAR's Cheyenne machine, Orion at Mississippi State and S4 at the University of Wisconsin.
* By self installing all of the dependencies using [JEDI-STACK](https://github.com/JCSDA/jedi-stack). This repository includes everything required to build the system, beginning with installation of the source code compilers.

Unless working in the application container (where the code is pre-built) users clone only the FV3-BUNDLE to get started. FV3-BUNDLE is essentially a convenience package that will clone clone and build all the required JEDI-FV3 dependencies. Users can obtain this software with:

`git clone -b 1.0.0 https://github.com/jcsda/fv3-bundle`

## DOCUMENTATION AND SUPPORT

Documentation for JEDI-FV3 can be found at [jedi-docs](https://jedi-docs.jcsda.org). Users are encouraged to explore the documentation for detailed descriptions of the source code, development practices and build systems. Note that users are also encouraged to contribute to the documentation, which can be done by submitting to the JEDI-DOCS repository at https://github.com/JCSDA/jedi-docs. JEDI source code includes DOXYGEN comments and the DOXYGEN generated pages can be found under the documentation for [each component](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/inside/jedi-components/index.html). These pages are useful for learning more about the way the software is structured.

## APPLICATIONS

JEDI-FV3 is provided with input files for performing a number of applications with JEDI-FV3. Users can perform an observation simulation application, known as ‘h(x)’ or can run variational data assimilation with the 3DEnVar algorithm. Supported resolutions for UFS/GFS are C12, C24, C48, C96 and C192. Supported resolutions for GEOS are C12, C24, C48, C90 and C180. The values in these resolutions refer to the standard way in which FV3 determines resolution, by the number of grid cells along a face of the cube. C96 means 96 by 96 grid cells on each face, which equates to approximately 100km. In addition to the h(x) and variational applications several utility applications are provided. The Parameters application can be used to generate fixed or dynamic localization operators using SABER. The ConvertState application can be used to change the resolution of cubed-sphere fields. The DiffStates application can be used to create an increment from the difference of the analysis and background.

## POST PROCESSING AND VISUALIZATION

### Analysis fields

JEDI-FV3 works directly with cubed-sphere data structures and can read data in two formats,  GFS restarts and GEOS restarts. Data can be output in these same formats as well as interpolated to longitude and latitude grids. Cubed-sphere fields written in the GEOS format can be visualized easily with the [Panoply](https://www.giss.nasa.gov/tools/panoply/) software developed by NASA. A lightweight Python utility is provided for visualizing fields on a longitude-latitude grid. 

### Observations

Utilities are provided for plotting observation statistics from the data output by IODA. Use of these tools can be explored through the [tutorials](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/learning/tutorials/index.html).
