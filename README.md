# Simstrat  

*** Description ***  
This GIT repository contains the source code of Simstrat, as used in the paper gmd-2016-262. It also contains the executable file, the parameter files and the input data files that allow to run the model for four different lakes.  
This model version is temporary and an updated one will shortly be made available.  

*** Structure of the repository ***  
simstrat-source/: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Source code of the Simstrat model  
simstrat-documentation/: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Documentation of the Simstrat model  
kepsmodel.exe: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Binary executable of the Simstrat model (compiler: GNU Fortran)  
kepsilon_\*.par: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Parameter files for lake \*  
kepsilon_\*_wfilt.par: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Parameter files for lake \*, using filtered wind  
\*/: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Input files for lake \*  
\*.txt: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Temperature observation files for lake \*  
Simstrat_WindFiltering.R: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Script for wind filtering  

*** Author ***  
Adrien Gaudard, adrien.gaudard@eawag.ch  