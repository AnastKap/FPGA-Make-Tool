include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk


###################################################
# Check if the sub-make call was instructed to
# include the Xclbin makefile. If yes, it means
# that the Xclbin step must be invoked
###################################################
INCLUDE_XCLBIN_MAKEFILE ?= 

ifneq ($(strip $(INCLUDE_XCLBIN_MAKEFILE)),)

include $(INCLUDE_XCLBIN_MAKEFILE)

XO_TARGETS = $(wildcard $(BUILD_SYSTEM_BUILD_XO_DIR)/*.xo)
KERNEL_XCLBIN = $(BUILD_SYSTEM_BUILD_FOLDER)/$(PROJECT_NAME).xclbin

MAKEFILE_LOG_FOLDER = $(KERNEL_BUILD_FOLDER)/.makefilelogs

VPP_FLAGS := -R2 $(ADDITIONAL_VPP_FLAGS)
VPP_FLAGS += --save-temps --temp_dir $(BUILD_SYSTEM_BUILD_TEMP_DIR)
VPP_FLAGS += $(addprefix -I,$(KERNEL_INCLUDE_FOLDERS) $(wildcard $(KERNEL_INCLUDE_FOLDERS)))
ifneq ($(TARGET), hw)
VPP_FLAGS += -g
endif
VPP_LDFLAGS :=
ifdef FROM_STEP
VPP_LDFLAGS += --from_step $(FROM_STEP)
endif
ifdef CONFIG_FILE
CONFIG_FILE_FLAG = --config $(CONFIG_FILE)
VPP_LDFLAGS += $(CONFIG_FILE_FLAG)
endif
ifdef HLS_PRE_TCL
VPP_FLAGS += --hls.pre_tcl $(HLS_PRE_TCL)
endif
ifdef KERNEL_FREQUENCY_MHz
VPP_FLAGS += --kernel_frequency $(KERNEL_FREQUENCY_MHz)
endif

ifneq ($(strip $(KERNEL_TO_STEP_LINK)),)
VPP_VALID_STEPS = $(shell v++ --list_steps --target hw --link | sed -n -e '3p' -e '6p' | sed 's/,/ /g' | paste -sd ' ')
ifeq ($(filter $(KERNEL_TO_STEP_LINK),$(VPP_VALID_STEPS)),)
$(error Makefile variable KERNEL_TO_STEP_LINK was defined but given an invalid value ($(KERNEL_TO_STEP_LINK)). Please check the list of valid steps using 'v++ --list_steps --target hw --link' command.)
endif
VPP_LDFLAGS += --to_step $(KERNEL_TO_STEP_LINK)
endif
ifneq ($(strip $(KERNEL_REUSE_IMPL_DCP)),)
VPP_LDFLAGS += --reuse_impl $(KERNEL_REUSE_IMPL_DCP)
endif

endif

###################################################
# Run the Xclbin step
###################################################

prebuild_xclbin:
	$(ECHO) "$(GREEN_COLOR)Xclbin for xo $@ started at $(shell date).\
		Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	@echo "Kernel config file: $(CONFIG_FILE)"
	@echo "Kernel frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	@echo "Kernel prebuild steps: $(KERNEL_PREBUILD_STEPS)"
	@echo "Kernel sources: $(KERNEL_SOURCES_EXPANDED)"
	@mkdir -p $(KERNEL_BUILD_FOLDER)
	@rm -rf $(MAKEFILE_LOG_FOLDER)
	@mkdir -p $(MAKEFILE_LOG_FOLDER)

	$(ECHO) "$(GREEN_COLOR)---- Building kernel ----$(DEFAULT_COLOR)"
ifneq ($(strip $(KERNEL_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS) 2>&1
endif

build_xclbin: $(KERNEL_XCLBIN)


############################## Building the kernels ##############################

$(KERNEL_XCLBIN): $(XO_TARGETS)
	$(ECHO) "$(GREEN_COLOR)Linking object files to xclbin...$(DEFAULT_COLOR)"
	v++ -l $(VPP_FLAGS) $(VPP_LDFLAGS) -t $(TARGET) --platform $(PLATFORM) --log_dir $(BUILD_SYSTEM_BUILD_LOG_DIR) -o '$@' $^
