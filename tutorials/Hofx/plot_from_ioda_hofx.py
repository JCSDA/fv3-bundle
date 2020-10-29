#!/usr/bin/env python

# (C) Copyright 2019-2020 UCAR
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.

import cartopy.crs as ccrs
import click
import datetime as dt
import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
from netCDF4 import Dataset
import numpy as np
import os

matplotlib.use("Agg")

# --------------------------------------------------------------------------------------------------
## @package plot_from_ioda_hofx.py
#
#  This is a utility for plotting an from hofx like data that is output from ioda
#
# --------------------------------------------------------------------------------------------------

# --------------------------------------------------------------------------------------------------

def abort(message):
    print('\n ABORT: '+message+'\n')
    raise(SystemExit)

# --------------------------------------------------------------------------------------------------

@click.command()
@click.option('--hofxfiles',     required=True,  help='IODA files in format like hofx/hofx3d_gfs_c48_ncdiag_aircraft_PT6H_20201001_0300Z_NPROC.nc4')
@click.option('--variable',      required=True,  help='E.g. air_temperature@hofx')
@click.option('--nprocs',        required=True,  help='Number of processors used for JEDI run', type=int)
@click.option('--window_begin',  required=True,  help='Time at beginning of the window (yyyymmddhh)', default=False)
@click.option('--omb',           required=False, help='Set to true to compute omb', default=False)
@click.option('--colmin',        required=False, help='Minimum for colorbar in plotting', default=-9999.9)
@click.option('--colmax',        required=False, help='Maximum for colorbar in plotting', default=-9999.9)
def plot_from_ioda_hofx(hofxfiles, variable, nprocs, window_begin, omb, colmin, colmax):

    # Variable name and units
    # -----------------------
    vsplit = variable.split('@')
    variable_name = vsplit[0]
    units = ''
    if variable_name[0:22] == 'brightness_temperature':
        units = 'K'
    elif variable_name == 'eastward_wind':
        units = 'ms-1'
    elif variable_name == 'air_temperature':
        units = 'K'
    elif variable_name == 'air_pressure':
        units = 'Pa'

    # Make it omb if requested
    if omb:
      if (vsplit[1] != 'hofx'):
        abort("If --omg=true then --variable must be var@hofx")

    # Filename
    # --------
    if omb:
      print("Computing omb")
      vsavename = vsplit[0]+"_omb"
      vtitle = vsplit[0]+" omb"
    else:
      vsavename = vsplit[0]+"_"+vsplit[1]
      vtitle = vsplit[0]+" "+vsplit[1]

    savename = os.path.basename(hofxfiles)
    #savename = savename.replace('_NPROC', '')
    #savename = savename.replace('.nc4', '')
    #savename = savename + '-' + vsavename + '.png'
    savename = vsavename + '.png'

    # Loop over hofxfiles
    # -------------------
    odat = []
    lons = []
    lats = []
    time = []

    for n in range(nprocs):

        file = hofxfiles.replace('NPROC', str(n).zfill(4))
        print(" Reading "+file)

        fh = Dataset(file)

        odat_proc = fh.variables[variable][:]
        if omb:
          odat_proc = fh.variables[vsplit[0]+'@ObsValue'][:] - odat_proc
        lons_proc = fh.variables['longitude@MetaData'][:]
        lats_proc = fh.variables['latitude@MetaData'][:]
        time_proc = fh.variables['datetime@MetaData'][:]

        win_beg = dt.datetime.strptime(window_begin, '%Y%m%d%H')

        for m in range(len(odat_proc)):
            odat.append(odat_proc[m])
            lons.append(lons_proc[m])
            lats.append(lats_proc[m])
            time_proc_ = (time_proc[m])
            time_proc_str = ''
            for l in range(20):
                time_proc_str = time_proc_str + time_proc_[l].decode('UTF-8')
            time.append((dt.datetime.strptime(time_proc_str, '%Y-%m-%dT%H:%M:%SZ') - win_beg).total_seconds())

        fh.close()

    numobs = len(odat)

    obarray = np.empty([numobs, 4])

    obarray[:, 0] = odat
    obarray[:, 1] = lons
    obarray[:, 2] = lats
    obarray[:, 3] = time


    # Compute and print some stats for the data
    # -----------------------------------------
    stdev = np.nanstd(obarray[:, 0])  # Standard deviation
    omean = np.nanmean(obarray[:, 0]) # Mean of the data
    datmi = np.nanmin(obarray[:, 0])  # Min of the data
    datma = np.nanmax(obarray[:, 0])  # Max of the data

    print("Plotted data statistics: ")
    print("Mean: ", omean)
    print("Standard deviation: ", stdev)
    print("Minimum ", datmi)
    print("Maximum: ", datma)


    # Norm for scatter plot
    # ---------------------
    norm = None


    # Min max for colorbar
    # --------------------
    if np.nanmin(obarray[:, 0]) < 0:
      cmax = datma
      cmin = datmi
      cmap = 'RdBu'
    else:
      cmax = omean+stdev
      cmin = np.maximum(omean-stdev, 0.0)
      cmap = 'viridis'

    if vsplit[1] == 'PreQC' or vsplit[1] == 'EffectiveQC':
      cmin = datmi
      cmax = datma

      # Specialized colorbar for integers
      cmap = plt.cm.jet
      cmaplist = [cmap(i) for i in range(cmap.N)]
      cmaplist[1] = (.5, .5, .5, 1.0)
      cmap = matplotlib.colors.LinearSegmentedColormap.from_list('Custom cmap', cmaplist, cmap.N)
      bounds = np.insert(np.linspace(0.5, int(cmax)+0.5, int(cmax)+1), 0, 0)
      norm = matplotlib.colors.BoundaryNorm(bounds, cmap.N)

    # If using omb then use standard deviation for the cmin/cmax
    if omb:
      cmax = stdev
      cmin = -stdev

    # Override with user chosen limits
    if (colmin!=-9999.9):
      print("Using user provided minimum for colorbar")
      cmin = colmin
    if (colmax!=-9999.9):
      print("Using user provided maximum for colorbar")
      cmax = colmax


    # Create figure
    # -------------

    fig = plt.figure(figsize=(10, 5))

    # initialize the plot pointing to the projection
    ax = plt.axes(projection=ccrs.PlateCarree(central_longitude=0))

    # plot grid lines
    gl = ax.gridlines(crs=ccrs.PlateCarree(central_longitude=0), draw_labels=True,
                      linewidth=1, color='gray', alpha=0.5, linestyle='-')
    gl.top_labels = False
    gl.xlabel_style = {'size': 10, 'color': 'black'}
    gl.ylabel_style = {'size': 10, 'color': 'black'}
    gl.xlocator = mticker.FixedLocator(
        [-180, -135, -90, -45, 0, 45, 90, 135, 179.9])
    ax.set_ylabel("Latitude",  fontsize=7)
    ax.set_xlabel("Longitude", fontsize=7)

    # scatter data
    sc = ax.scatter(obarray[:, 1], obarray[:, 2],
                    c=obarray[:, 0], s=4, linewidth=0,
                    transform=ccrs.PlateCarree(), cmap=cmap, vmin=cmin, vmax = cmax, norm=norm)

    # colorbar
    cbar = plt.colorbar(sc, ax=ax, orientation="horizontal", pad=.1, fraction=0.06,)
    cbar.ax.set_ylabel(units, fontsize=10)

    # plot globally
    ax.set_global()

    # draw coastlines
    ax.coastlines()

    # figure labels
    plt.title("IODA observation data: "+vtitle)
    ax.text(0.45, -0.1,   'Longitude', transform=ax.transAxes, ha='left')
    ax.text(-0.08, 0.4, 'Latitude', transform=ax.transAxes,
            rotation='vertical', va='bottom')

    # show plot
    plt.savefig(savename)

    exit()

# --------------------------------------------------------------------------------------------------

if __name__ == '__main__':
    plot_from_ioda_hofx()

# --------------------------------------------------------------------------------------------------
