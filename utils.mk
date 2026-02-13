#+-------------------------------------------------------------------------------
# The following parameters are assigned with default values. These parameters can
# be overridden through the make command line
#+-------------------------------------------------------------------------------

DEBUG := no

#Generates debug summary report
ifeq ($(DEBUG), yes)
VPP_LDFLAGS += --dk list_ports
endif

include $(dir $(lastword $(MAKEFILE_LIST)))/MakefileCommon.mk


MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
COMMON_REPO ?= $(shell python -c "import os; print(os.path.abspath('${MK_PATH}/../../..').replace(os.sep, '/'))")
PWD = $(shell python -c "import os; print(os.getcwd().replace(os.sep, '/'))")
XF_PROJ_ROOT = $(shell python -c "import os; print(os.path.abspath('${COMMON_REPO}').replace(os.sep, '/'))")

#Check OS and setting env for xrt c++ api
GXX_EXTRA_FLAGS := 
# Only run lsb_release on Linux (Windows doesn't have it)
ifneq ($(OS),Windows_NT)
    OSDIST = $(shell lsb_release -i 2>/dev/null | awk -F: '{print tolower($$2)}' | tr -d ' 	' )
    OSREL = $(shell lsb_release -r 2>/dev/null | awk -F: '{print tolower($$2)}' | tr -d ' 	')
    # for centos and redhat
    ifneq ($(findstring centos,$(OSDIST)),)
        ifeq (7,$(shell echo $(OSREL) | awk -F. '{print tolower($$1)}' ))
            GXX_EXTRA_FLAGS := -D_GLIBCXX_USE_CXX11_ABI=0
        endif
    else ifneq ($(findstring redhat,$(OSDIST)),)
        ifeq (7,$(shell echo $(OSREL) | awk -F. '{print tolower($$1)}' ))
            GXX_EXTRA_FLAGS := -D_GLIBCXX_USE_CXX11_ABI=0
        endif
    endif
endif
#Setting PLATFORM 
ifeq ($(PLATFORM),)
ifneq ($(DEVICE),)
$(warning WARNING: DEVICE is deprecated in make command. Please use PLATFORM instead)
PLATFORM := $(DEVICE)
endif
endif

#Checks for XILINX_VITIS
check-vitis:
ifndef XILINX_VITIS
	$(error XILINX_VITIS variable is not set, please set correctly using "source <Vitis_install_path>/Vitis/<Version>/settings64.sh" and rerun)
endif

#Checks for XILINX_XRT
check-xrt:
ifndef XILINX_XRT
	$(error XILINX_XRT variable is not set, please set correctly using "source /opt/xilinx/xrt/setup.sh" and rerun)
endif

gen_run_app:
	-$(RM) run_app.sh run_app.bat
ifeq ($(OS),Windows_NT)
	$(ECHO) set PATH=%PATH%;%XILINX_XRT%/bin > run_app.bat
	$(ECHO) $(EXECUTABLE)$(EXT) -x $(PROJECT_NAME).xclbin >> run_app.bat
else
	$(ECHO) 'export LD_LIBRARY_PATH=/mnt:/tmp:$$LD_LIBRARY_PATH' >> run_app.sh
	$(ECHO) 'export PATH=$$PATH:/sbin' >> run_app.sh
	$(ECHO) 'export XILINX_XRT=/usr' >> run_app.sh
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
	$(ECHO) 'export XILINX_VITIS=$$PWD' >> run_app.sh
	$(ECHO) 'export XCL_EMULATION_MODE=$(TARGET)' >> run_app.sh
endif
	$(ECHO) '$(EXECUTABLE) -x $(PROJECT_NAME).xclbin' >> run_app.sh
	$(ECHO) 'return_code=$$?' >> run_app.sh
	$(ECHO) 'if [ $$return_code -ne 0 ]; then' >> run_app.sh
	$(ECHO) 'echo "ERROR: host run failed, RC=$$return_code"' >> run_app.sh
	$(ECHO) 'fi' >> run_app.sh
	$(ECHO) 'echo "INFO: host run completed."' >> run_app.sh
endif
check-platform:
ifndef PLATFORM
	$(error PLATFORM not set. Please set the PLATFORM properly and rerun. Run "make help" for more details.)
endif

#   device2xsa - create a filesystem friendly name from device name
#   $(1) - full name of device
device2xsa = $(strip $(patsubst %.xpfm, % , $(shell basename $(PLATFORM))))

XSA := 
ifneq ($(PLATFORM), )
XSA := $(call device2xsa, $(PLATFORM))
endif

############################## Deprecated Checks and Running Rules ##############################
check:
	$(ECHO) "WARNING: \"make check\" is a deprecated command. Please use \"make run\" instead"
	make run

exe:
	$(ECHO) "WARNING: \"make exe\" is a deprecated command. Please use \"make host\" instead"
	make host


docs: README.rst

README.rst: description.json
	$(XF_PROJ_ROOT)/common/utility/readme_gen/readme_gen.py description.json



############################## Help Prompt ##############################
help:
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make \033[33mall\033[39m TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) ""
	$(ECHO) "  make \033[33mbuild\033[39m TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to build xclbin application and host application."
	$(ECHO) ""
	$(ECHO) "  make \033[33mbuild_kernel\033[39m TARGET=<sw_emu/hw_emu/hw> PLATFORM=<FPGA platform>"
	$(ECHO) "      Command to build xclbin application."
	$(ECHO) ""
	$(ECHO) "  make \033[33mbuild_host\033[39m"
	$(ECHO) "      Command to build host application."
	$(ECHO) ""
	$(ECHO) "  make \033[33mclean_host\033[39m"
	$(ECHO) "      Command to remove all the generated files for the host application."
	$(ECHO) ""
	$(ECHO) "  make \033[33mclean\033[39m"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
