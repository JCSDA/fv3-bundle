### License:

(C) Copyright 2017-2020 UCAR

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

### Description:

Bundle containing all the repositories that are needed to compile fv3-jedi, the interface between JEDI and FV3 based models (https://github.com/JCSDA/fv3-jedi)

### Installation:

For details about JEDI, including installation instructions see: https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/

If building on NASA's Discover, NOAA's Hera or MSU's Orion machines the provided build scripts are a convenient way of building:

    git clone https://github.com/jcsda/fv3-bundle
    cd fv3-bundle

Then to see the compiler options available on that machine do:

    ./buildscripts/build_<machine>.sh -h

The first option listed is the default that would be chosen if no arguments are provided. Typically, the only options needed are `-c` for the compiler choice and `-b` for release or debug build mode.

Example on Orion:

    ./buildscripts/build_orion.sh -b release

Will build in release mode with the default compiler and then run all the tests for fv3-jedi.

Once the system is built with a particular compiler and build mode the build script should not be used again. If changes are made that need to be recompiled it is quickest to use make commands within the part of the build directory associated with the source code changes. First source the modules used for the build; to see what was sourced take a look inside the build script. This is machine dependent and it's worth having some shortcuts for future use.  Once the modules are sourced simply do:

    cd build-<compiler-version>/fv3-jedi
    make -j<x>

where `<x>` is the number of processors, e.g. 6.
