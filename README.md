Arctic Ocean Freshwater Synthesis
==============================
[![License:MIT](https://img.shields.io/badge/License-MIT-lightgray.svg?style=flt-square)](https://opensource.org/licenses/MIT)

MATLAB code to build a schematic diagram of Arctic Ocean freshwater storage and fluxes. Data taken from [Jahn & Laiho (2020)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2020GL088854) and [Haine et al. (2015)](https://www.sciencedirect.com/science/article/pii/S0921818114003129?via%3Dihub), plus updates.

Run MATLAB codes as follows:

* Run `flux_update.m` to make a diagnostic figure of freshwater fluxes from Haine et al. (2015), plus recent public data updates. This builds the `.mat` file used in the main script.
* Run `make_LFC_map.m` to make the liquid freshwater content basemap adapted from [Haine et al. (2015)](https://www.sciencedirect.com/science/article/pii/S0921818114003129?via%3Dihub) Fig. 6.
* Run `schematic_figure.m` to read Alex Jahn's CESM data from [Jahn & Laiho (2020)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2020GL088854) and make the subplots for the schematic figure (six `.eps` files).
* Use Mac keynote to build `schematic.key` and hence `schematic.pdf` using the component figure files.

The MATLAB code uses [Gibbs-Seawater (GSW) Oceanographic Toolbox functions](http://www.teos-10.org/software.htm#1).
 
A commentary article entitled [*Arctic Ocean Freshening Linked to Anthropogenic Climate Change: All Hands on Deck*](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2020GL090678) has been published at GRL.

--------

<p><small>Project based on the <a target="_blank" href="https://github.com/jbusecke/cookiecutter-science-project">cookiecutter science project template</a>.</small></p>
