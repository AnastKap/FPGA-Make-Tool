########################## User settings #######################
BUILD_FOLDER = build/
PROJECT_NAME = vadd

# Kernel settings
KERNEL_SOURCE_FOLDER = src/kernel

# Host settings
HOST_APP_NAME = host
HOST_SOURCES = $(wildcard src/host/*)
HOST_INCLUDE_FOLDERS = $(wildcard inc/host)

# Misc definitions
PLATFORM = xilinx_u200_gen3x16_xdma_2_202110_1