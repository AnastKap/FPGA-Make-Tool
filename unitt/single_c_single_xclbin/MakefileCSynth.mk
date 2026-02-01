# Kernel settings
HLS_PRE_TCL ?= hls_config.tcl

KERNEL_SOURCES ?= src/kernel.cpp
KERNEL_INCLUDE_FOLDERS ?=
KERNEL_TOP_FUNCTION_NAME = bandwidth
KERNEL_PREBUILD_STEPS =