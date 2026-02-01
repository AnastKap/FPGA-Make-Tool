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
RTL_TO_XO_TARGET = $(addsuffix .xo,$(addprefix $(BUILD_SYSTEM_BUILD_XO_DIR)/,$(XO_BASE_NAME)))
CREATE_RTL_PROJ_TCL = $(abspath )

XO_LOG_OUTPUT := $(MAKEFILE_LOG_DIR)/rtl_pkg/rtl_to_xo/$(XO_BASE_NAME).log
IP_SETTINGS_TCL_ABS = $(abspath IP_SETTINGS_TCL)

.NOTPARALLEL: build_rtl_to_xo

endif


###################################################
# Run the RTL to XO step
###################################################

RTL_TO_XO_TARGETS = $(addsuffix .mk,$(RTL_PKG_MAKEFILES))

.PHONY: prebuild_rtl_to_xo_all
prebuild_rtl_to_xo_all:

.PHONY: prebuild_rtl_to_xo
prebuild_rtl_to_xo:
	$(ECHO) "$(GREEN_COLOR)---- Packaging RTL kernel $(KERNEL_TOP_MODULE_NAME) ----$(DEFAULT_COLOR)"
	
	$(ECHO) "$(GREEN_COLOR)RTL to xo $(RTL_TO_XO_TARGET) started at $(shell date). Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	@echo "Kernel top module name: $(KERNEL_TOP_MODULE_NAME)"
	@echo "Kernel frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	@echo "Kernel prebuild steps: $(KERNEL_PREBUILD_STEPS)"
	@echo "Kernel sources: $(KERNEL_SOURCES_EXPANDED)"
	@mkdir -p $(dir $(XO_LOG_OUTPUT))



.PHONY: postbuild_rtl_to_xo
postbuild_rtl_to_xo:
	$(ECHO) "$(PINK_COLOR)---- RTL packaged to XO $(KERNEL_TOP_MODULE_NAME) ----$(DEFAULT_COLOR)"


.PHONY: build_rtl_to_xo_single
build_rtl_to_xo_single: prebuild_rtl_to_xo $(RTL_TO_XO_TARGET) postbuild_rtl_to_xo


%.mk:
	$(eval RTL_PKG_MAKEFILE := $(patsubst %.mk,%,$@))
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileRTLPkg.mk INCLUDE_RTL_PKG_MAKEFILE=$(RTL_PKG_MAKEFILE) build_rtl_to_xo_single


.PHONY: build_rtl_to_xo_all
build_rtl_to_xo_all: prebuild_rtl_to_xo_all $(RTL_TO_XO_TARGETS)

%.xo: $(KERNEL_SOURCES_EXPANDED)
	$(eval XO_BASENAME := $(basename $(notdir $@)))
	@rm -rf $(XO_LOG_OUTPUT)
	vivado -mode batch -source $(BUILD_SYSTEM_ABS_PATH)/scripts/rtl_to_xo.tcl \
		-tclargs $(BUILD_SYSTEM_ABS_PATH) $(BUILD_SYSTEM_BUILD_TEMP_DIR) $@ $(XO_BASE_NAME) \
		$(IP_SETTINGS_TCL) $(KERNEL_TOP_MODULE_NAME) $(KERNEL_SOURCES_EXPANDED)> $(XO_LOG_OUTPUT) 2>&1
