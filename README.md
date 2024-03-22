# FPGA Makefile Toolchain

This repository contains the basic files to automate the procedure of FPGA testing and kernel implementation

## How to use?

Copy in your workspace folder (where you wish to run the *make* command) the file under the name *template_settings.mk* and rename it to *MakefileVitis.mk*(the name can change to your liking). Then, make the appropriate changes to the variables, change the path in the last line where the *include* is to point to the Makefile of this repository and, after that, you are ready to run the tool via *make -f MakefileVitis.mk* (Or any other name given previously).
