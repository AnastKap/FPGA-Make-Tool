@echo off
setlocal

REM Try to find standard make
where make >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    make %*
    goto :EOF
)

REM Try to find mingw32-make
where mingw32-make >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    mingw32-make %*
    goto :EOF
)

REM Try to find gmake (common in Xilinx installs)
where gmake >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    gmake %*
    goto :EOF
)

REM Check common Xilinx paths if not in PATH
if exist "C:\Xilinx\Vivado\2021.1\tps\win64\git-1.9.5\bin\make.exe" (
   "C:\Xilinx\Vivado\2021.1\tps\win64\git-1.9.5\bin\make.exe" %*
   goto :EOF
)

echo Error: 'make' command not found.
echo.
echo Please ensure you have a 'make' utility installed and in your PATH.
echo Common sources:
echo  - MinGW / MSYS2
echo  - Chocolatey (choco install make)
echo  - Xilinx Vivado/Vitis installation (often has gmake)
echo.
exit /b 1
