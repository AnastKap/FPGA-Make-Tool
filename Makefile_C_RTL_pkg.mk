########################## Include other steps ##########################
include $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk
include $(BUILD_SYSTEM_ABS_PATH)/MakefileRTLPkg.mk


###################################################
# Run the CSynth and RTL Pkg steps
###################################################

build_c_pkg:
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk build_csynth_all

build_rtl_pkg:
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileRTLPkg.mk build_rtl_to_xo_all


build_c_rtl_pkg: build_c_pkg build_rtl_pkg
	