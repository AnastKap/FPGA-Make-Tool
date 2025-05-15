KERNEL_TOP_FUNCTION_NAME = krnl_vadd_2clk_rtl
KERNEL_SOURCES = src/hdl/*
XO_BASE_NAME = krnl_vadd_2clk_rtl

IP_SETTINGS_TCL = ./scripts/package_kernel.tcl

PKG_TCL_SCRIPT = ./scripts/gen_xo.tcl
