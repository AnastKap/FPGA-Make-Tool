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

VPP_FLAGS := -R2 $(ADDITIONAL_VPP_FLAGS)
VPP_FLAGS += --save-temps --temp_dir $(BUILD_SYSTEM_BUILD_TEMP_DIR)
VPP_FLAGS += $(addprefix -I,$(KERNEL_INCLUDE_FOLDERS) $(wildcard $(KERNEL_INCLUDE_FOLDERS)))
ifneq ($(TARGET), hw)
VPP_FLAGS += -g
endif
VPP_LDFLAGS := $(ADDITIONAL_VPP_LDFLAGS)
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
VPP_VALID_STEPS = $(shell v++ --list_steps --target hw --link 2> $(NULL) | sed -n -e '3p' -e '6p' | sed 's/,/ /g' | paste -sd ' ')
ifeq ($(filter $(KERNEL_TO_STEP_LINK),$(VPP_VALID_STEPS)),)
$(error Makefile variable KERNEL_TO_STEP_LINK was defined but given an invalid value ($(KERNEL_TO_STEP_LINK)). Please check the list of valid steps using 'v++ --list_steps --target hw --link' command.)
endif
VPP_LDFLAGS += --to_step $(KERNEL_TO_STEP_LINK)
endif
ifneq ($(strip $(KERNEL_REUSE_IMPL_DCP)),)
VPP_LDFLAGS += --reuse_impl $(KERNEL_REUSE_IMPL_DCP)
endif

XCLBIN_LOG_OUTPUT := $(MAKEFILE_LOG_DIR)/xclbin/$(PROJECT_NAME).log

.NOTPARALLEL: build_xclbin

endif

###################################################
# Run the Xclbin step
###################################################

.PHONY: prebuild_xclbin
prebuild_xclbin:
	$(ECHO) $(GREEN_COLOR)Xclbin for xo $@ started. Makefile output at $(XCLBIN_LOG_OUTPUT)$(DEFAULT_COLOR)
	@echo "Xclbin config file: $(CONFIG_FILE)"
	@echo "Xclbin frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	-@$(MKDIR) $(call FIX_PATH,$(dir $(XCLBIN_LOG_OUTPUT)))

ifneq ($(strip $(KERNEL_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS) 2>&1
endif

.PHONY: postbuild_xclbin
postbuild_xclbin:
	$(ECHO) $(PINK_COLOR)---- Xclbin Built at $(KERNEL_XCLBIN) ----$(DEFAULT_COLOR)

build_xclbin: prebuild_xclbin $(KERNEL_XCLBIN) postbuild_xclbin


############################## Building the kernels ##############################

$(KERNEL_XCLBIN): $(XO_TARGETS)
	-@$(RM) $(call FIX_PATH,$(XCLBIN_LOG_OUTPUT))
	v++ -l $(VPP_FLAGS) $(VPP_LDFLAGS) -t $(TARGET) --platform $(PLATFORM) \
		--log_dir $(BUILD_SYSTEM_BUILD_LOG_DIR) -o '$@' $^ > $(XCLBIN_LOG_OUTPUT) 2>&1
