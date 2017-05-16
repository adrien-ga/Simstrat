@echo OFF &SETLOCAL
set "wdir=%cd%"

REM Set the model to write results in current PEST directory
set "file=kepsilon_PEST.par"
set /a Line_Physic=7
set "PathOut_Physic=%wdir%\results\"
(for /f "tokens=1*delims=:" %%a in ('findstr /n "^" "%file%"') do (
    set "Line=%%b"
    if %%a equ %Line_Physic% set "Line=%PathOut_Physic%"
    SETLOCAL ENABLEDELAYEDEXPANSION
    echo(!Line!
	ENDLOCAL
)) > "%file%.new"
copy %file%.new %file% > NUL
del %file%.new

REM Run the model
cd ..\..
kepsmodel.exe %wdir%\kepsilon_PEST.par > NUL

REM Format output in a readable way for PEST
cd %wdir%\..
REM matlab /wait -nodisplay -nosplash -nojvm -nodesktop -r "wdir='%wdir%'; run([pwd '\OutputInstructions.m']); exit;"
"C:\APPS\R\R-3.3.1\bin\x64\RScript.exe" --vanilla --slave OutputInstructions.R %wdir%