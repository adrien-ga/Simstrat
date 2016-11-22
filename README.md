# Simstrat

*** Description ***
This GIT repository contains the source code of Simstrat, as used in the paper gmd-2016-262. It also contains the executable file, the paramter files and the input data files that allow to run the model for four different lakes.
This model version is temporary and an updated one will shortly be made available.

*** Structure of the repository ***
simstrat-source/         Source code of the Simstrat model
simstrat-documentation/  Documentation of the Simstrat model
kepsmodel.exe            Binary executable of the Simstrat model (compiler: GNU Fortran)
kepsilon_*.par           Parameter files for lake *
kepsilon_*_wfilt.par     Parameter files for lake *, using filtered wind
*/                       Input files for lake *
*.txt                    Temperature observation files for lake *
Simstrat_WindFiltering.R Script for wind filtering

*** Author ***
Adrien Gaudard, adrien.gaudard@eawag.ch