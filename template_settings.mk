########################## User settings #######################
BUILD_FOLDER = build/
PROJECT_NAME = vadd
CONFIG_FILE = vitis_build.cfg

# Kernel settings
KERNEL_SOURCE_FOLDER = src/kernel
KERNEL_INCLUDE_FOLDERS = inc/kernel
KERNEL_TOP_FUNCTION_NAME = full_diffusion_ijk

# Host settings
HOST_APP_NAME = host
HOST_SOURCES = $(wildcard src/host/*)
HOST_INCLUDE_FOLDERS = $(wildcard inc/host)

# Misc definitions
PLATFORM = xilinx_u200_gen3x16_xdma_2_202110_1

include tools/FPGA_Make_Tool/Makefile