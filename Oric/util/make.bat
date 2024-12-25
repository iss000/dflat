echo off
setlocal EnableDelayedExpansion


:compile
color 81
echo Build started   : %date% %time%

REM Build cpp utilities - put them all in one bin folder
gcc ./dfbin2tap/dfbin2tap.cpp -o ./bin/dfbin2tap
if errorlevel 1 goto errors
gcc ./dftap2txt/dftap2txt.cpp -o ./bin/dftap2txt
if errorlevel 1 goto errors
gcc ./dftap2wav/dftap2wav.cpp -o ./bin/dftap2wav
if errorlevel 1 goto errors
gcc ./dftxt2tap/dftxt2tap.cpp -o ./bin/dftxt2tap
if errorlevel 1 goto errors


color 21
echo COMPILE SUCCESSFUL : !date! !time!
goto end

:errors
color 41
echo STOPPED DUE TO ASSEMBLY ERRORS
goto end

:end


