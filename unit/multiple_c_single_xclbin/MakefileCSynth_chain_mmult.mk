# Kernel settings
HLS_PRE_TCL ?=

KERNEL_SOURCES ?= src/krnl_chain_mmult.cpp
KERNEL_INCLUDE_FOLDERS ?= src
KERNEL_TOP_FUNCTION_NAME = krnl_chain_mmult
KERNEL_PREBUILD_STEPS =