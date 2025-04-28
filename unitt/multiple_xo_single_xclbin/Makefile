KERNEL_FREQUENCY_MHz ?= 200

BUILD_FOLDER ?= .build_kernel_chain

CSYNTH_MAKEFILES ?= ./MakefileCSynth_chain_mmult.mk ./MakefileCSynth_simple_mmult.mk
XCLBIN_MAKEFILE ?= ./MakefileXclbin.mk

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
MAIN_MAKEFILE_PATH ?= ../../MakefileSingleBitstream.mk

include $(MAIN_MAKEFILE_PATH)
