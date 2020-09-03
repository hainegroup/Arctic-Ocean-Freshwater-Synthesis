Arctic Ocean Freshwater Synthesis
==============================
[![Build Status](https://travis-ci.com/ThomasHaine/arctic_ocean_freshwater_synthesis.svg?branch=master)](https://travis-ci.com/ThomasHaine/arctic_ocean_freshwater_synthesis)
[![codecov](https://codecov.io/gh/ThomasHaine/arctic_ocean_freshwater_synthesis/branch/master/graph/badge.svg)](https://codecov.io/gh/ThomasHaine/arctic_ocean_freshwater_synthesis)
[![License:MIT](https://img.shields.io/badge/License-MIT-lightgray.svg?style=flt-square)](https://opensource.org/licenses/MIT)

MATLAB code to build a schematic diagram of Arctic Ocean freshwater storage and fluxes. Data taken from Jahn & Laiho (2020) and Haine et al. (2015), plus updates.

Run MATLAB codes as follows:

* Run `flux_update.m` to make a diagnostic figure of freshwater fluxes from Haine et al. (2015), plus recent public data updates. This builds the `.mat` file used in the main script.
* Run `make_LFC_map.m` to make the liquid freshwater content basemap adapted from Haine et al. (2015) Fig. 6.
* Run `schematic_figure.m` to read Alex Jahn's CESM data from Jahn & Laiho (2020) and make the subplots for the schematic figure (six `.eps.` files).
* Build `schematic.key` and `schematic.pdf` using the component figure files.

The Matlab code uses <a target="_blank" href="http://www.teos-10.org/software.htm#1">Gibbs-Seawater (GSW) Oceanographic Toolbox functions</a>.</small></p>
 
A commentary article entitled *Arctic Ocean Freshening Linked to Anthropogenic Climate Change: All Hands on Deck* has been submitted to GRL. See the ESSOAr preprint [here](???).

--------

<p><small>Project based on the <a target="_blank" href="https://github.com/jbusecke/cookiecutter-science-project">cookiecutter science project template</a>.</small></p>