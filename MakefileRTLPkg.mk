include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk


###################################################
# Check if the sub-make call was instructed to
# include the RTLPkg makefile. If yes, it means
# that the RTL to XO step must be invoked
###################################################

INCLUDE_RTL_PKG_MAKEFILE ?= 

ifneq ($(strip $(INCLUDE_RTL_PKG_MAKEFILE)),)

include $(INCLUDE_RTL_PKG_MAKEFILE)

KERNEL_SOURCES_EXPANDED = $(wildcard $(KERNEL_SOURCES))
RTL_TO_XO_TARGET = $(addsuffix .xo,$(addprefix $(BUILD_SYSTEM_BUILD_XO_DIR)/,$(KERNEL_TOP_FUNCTION_NAME)))
CREATE_RTL_PROJ_TCL = $(abspath )

XO_LOG_OUTPUT := $(MAKEFILE_LOG_DIR)/rtl_pkg/rtl_to_xo/$(KERNEL_TOP_FUNCTION_NAME).log

.NOTPARALLEL: build_rtl_to_xo

endif


###################################################
# Run the RTL to XO step
###################################################

.PHONY: prebuild_rtl_to_xo
prebuild_rtl_to_xo:
	$(ECHO) "$(GREEN_COLOR)RTL to xo $(RTL_TO_XO_TARGET) started at $(shell date). Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	@echo "Kernel name: $(KERNEL_TOP_FUNCTION_NAME)"
	@echo "Kernel frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	@echo "Kernel prebuild steps: $(KERNEL_PREBUILD_STEPS)"
	@echo "Kernel sources: $(KERNEL_SOURCES_EXPANDED)"
	@rm -rf $(XO_LOG_OUTPUT)
	@mkdir -p $(dir $(XO_LOG_OUTPUT))

	$(ECHO) "$(GREEN_COLOR)---- Building kernel $(KERNEL_TOP_FUNCTION_NAME) ----$(DEFAULT_COLOR)"


.PHONY: postbuild_rtl_to_xo
postbuild_rtl_to_xo:
	$(ECHO) "$(PINK_COLOR)---- RTL packaged to XO $(KERNEL_TOP_FUNCTION_NAME) ----$(DEFAULT_COLOR)"

build_rtl_to_xo: prebuild_rtl_to_xo $(RTL_TO_XO_TARGET) postbuild_rtl_to_xo

%.xo: $(KERNEL_SOURCES_EXPANDED)
	$(eval XO_BASENAME := $(basename $(notdir $@)))
	vivado -mode batch -source $(BUILD_SYSTEM_ABS_PATH)/scripts/rtl_to_xo.tcl \
		-tclargs $(BUILD_SYSTEM_ABS_PATH) $(BUILD_SYSTEM_BUILD_TEMP_DIR) $@ $(KERNEL_TOP_FUNCTION_NAME) \
		> $(XO_LOG_OUTPUT) 2>&1