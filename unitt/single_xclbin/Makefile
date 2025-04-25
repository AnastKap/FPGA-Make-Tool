########################## User settings #######################
CONFIG_FILE ?= 1bank.cfg
FROM_STEP ?=
HLS_PRE_TCL ?= hls_config.tcl

KERNEL_FREQUENCY_MHz ?= 200

BUILD_FOLDER ?= .build_global_mem_bw_$(KERNEL_FREQUENCY_MHz)MHz

# Kernel settings
KERNEL_BUILD_FOLDER ?= $(BUILD_FOLDER)/FPGA
KERNEL_NAME ?= global_mem_bw
KERNEL_SOURCES ?= src/kernel.cpp
KERNEL_INCLUDE_FOLDERS ?=
KERNEL_TOP_FUNCTION_NAMES = bandwidth
KERNEL_PREBUILD_STEPS = kernel_prebuild_info


PLATFORM=xilinx_u200_xdma_201830_2
TARGET=hw

ADDITIONAL_VPP_FLAGS ?=


# Host settings
HOST_APP_NAME = global_mem_bw_host
HOST_BUILD_FOLDER ?= $(BUILD_FOLDER)/host
HOST_SOURCES = src/kernel_global_bandwidth.cpp src/xcl2.cpp
HOST_INCLUDE_FOLDERS =
HOST_PREBUILD_STEPS = 
ADDITIONAL_CXX_FLAGS =


# Define the Makefile path of the Makefile library
MAIN_MAKEFILE_PATH ?= ../../Makefile

include $(MAIN_MAKEFILE_PATH)

.DEFAULT_GOAL=build_all
build_all: build_xclbin build_host


kernel_prebuild_info:
	@echo "--------------------------------------------------------------------"
	@echo "Building benchmark $(UBENCH_NAME) with the following configurations"
	@echo "- Ubench build folder: $(shell realpath $(BUILD_FOLDER))"
	@echo "- Frequency (in MHz): $(KERNEL_FREQUENCY_MHz)"
	@echo "--------------------------------------------------------------------"



TEMP_RESULTS_FILE = results_temp_$(KERNEL_FREQUENCY_MHz)
RESULTS_FILE = results.csv
run_measurement: build_all
	@echo "Running application..."
	@$(HOST_BUILD_FOLDER)/$(HOST_APP_NAME) $(KERNEL_BUILD_FOLDER)/$(TARGET)/$(KERNEL_NAME).xclbin 2>&1 | tee $(TEMP_RESULTS_FILE)
	@[ -f $(RESULTS_FILE) ] || echo "frequency_mhz,platform,throughput" > $(RESULTS_FILE) 
	@echo $(KERNEL_FREQUENCY_MHz),$(PLATFORM),`cat ${TEMP_RESULTS_FILE} | grep Throughput | cut -d = -f 2 | tr -d " " | cut -d "(" -f 1` >> ${RESULTS_FILE}
	@rm -f $(TEMP_RESULTS_FILE)

export
