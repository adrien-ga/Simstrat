# Simstrat v1.3  

*** Description ***  
This GIT repository contains the source code, manual and executable file of Simstrat v1.3, as used in the paper gmd-2016-262. It also contains the parameter files for four different lakes and the input data files that allow to run and calibrate the model for one lake (Lake Neuchâtel), as an example.  

*** Structure of the repository ***  
simstrat-source/: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Source code of the Simstrat model  
Simstrat_Manual.docx: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Documentation of the Simstrat model  
Simstrat_WindFiltering/kepsmodel.exe: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Binary executable of the Simstrat model (compiler: GNU Fortran)  
Simstrat_WindFiltering/kepsilon_\*.par: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Parameter files for lake \*  
Simstrat_WindFiltering/kepsilon_\*_wfilt.par: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Parameter files for lake \*, using filtered wind  
Simstrat_WindFiltering/\*/: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Input files for lake \*  
Simstrat_WindFiltering/\*.txt: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Temperature observation files for lake \*  
Simstrat_WindFiltering/Simstrat_WindFiltering.R: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Script for wind filtering

*** Instructions to run the model and exploit the results ***  
Either use the provided Windows executable (kepsmodel.exe) or compile the source code (see Manual). Once the executable is placed in the Simstrat_WindFiltering/ folder, the model can be run at the command line with the following syntax: "[executable] [par file]" (Windows) or "./[executable] [par file]" (Linux). For example for Lake Neuchâtel: "kepsmodel.exe kepsilon_LacDeNeuchatel.par". The model will write the results at the path specified in the par file (line 7, in our case LacDeNeuchatel_Results/), which must exist.
The R function GetResults.R can be used to extract and plot the results. In our example, in order to extract all temperature profiles and contour-plot them, it can be called from the R command line as follows: "GetResults('LacDeNeuchatel_Results/','T',graph=TRUE)".

*** Instructions to calibrate the model ***  
The scripts for calibration were developed for Windows platforms. They assume PEST is installed and available (see Manual). They furthermore assume R (version 3.3.1) is installed and the following executable is available: C:/APPS/R/R-3.3.1/bin/x64/RScript.exe.  
To launch calibration for lake * using PEST for lake *, run the script runPEST.bat (standard) or runPEST_parallel.bat (parallelized on 4 CPUs) from Simstrat_WindFiltering/\*_PEST/. At the end of calibration, the set of optimal parameters is written in the text file Simstrat_WindFiltering/\*_PEST/keps_calib.par.

*** Instructions to verify the model ***  
An idealized case was developed for verification of the wind filtering algorithms and of the model. In this idealized case, wind is a periodic rectangular function of variable frequency affecting a two-layer basin. The corresponding filtered wind is generated via the script Simstrat_WindFiltering/Simstrat_WindFiltering.R. This allows to show that, depending on the frequency of the wind function, filtering is correctly performed and transmitted to the model and that BSIW excitation occurs as expected. The idealized case can then be run using Simstrat_WindFiltering/kepsilon_IdealizedCase.par (par file) as input to the model executable (see above).

*** Author ***  
Adrien Gaudard, adrien.gaudard@eawag.ch