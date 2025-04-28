include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk


###################################################
# Check if the sub-make call was instructed to
# include the CSynth makefile. If yes, it means
# that the CSynth step must be invoked
###################################################
INCLUDE_CSYNTH_MAKEFILE ?= 

ifneq ($(strip $(INCLUDE_CSYNTH_MAKEFILE)),)

include $(INCLUDE_CSYNTH_MAKEFILE)

KERNEL_SOURCES_EXPANDED = $(KERNEL_SOURCES) #$(wildcard $(KERNEL_SOURCES))
KERNEL_XO_TARGET = $(addsuffix .xo,$(addprefix $(BUILD_SYSTEM_BUILD_XO_DIR)/,$(KERNEL_TOP_FUNCTION_NAME)))


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


XO_LOG_OUTPUT := $(MAKEFILE_LOG_DIR)/csynth/$(KERNEL_TOP_FUNCTION_NAME).log

.NOTPARALLEL: build_csynth_single

endif



###################################################
# Run the CSynth step
###################################################

CSYNTH_TARGETS = $(addsuffix .mk,$(CSYNTH_MAKEFILES))

.PHONY: prebuild_csynth
prebuild_csynth:

.PHONY: prebuild_kernel
prebuild_kernel:
	$(ECHO) "$(GREEN_COLOR)CSynth for xo $(KERNEL_XO_TARGET) started at $(shell date). Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	@echo "Kernel name: $(KERNEL_TOP_FUNCTION_NAME)"
	@echo "Kernel frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	@echo "Kernel prebuild steps: $(KERNEL_PREBUILD_STEPS)"
	@echo "Kernel sources: $(KERNEL_SOURCES_EXPANDED)"
	@rm -rf $(XO_LOG_OUTPUT)
	@mkdir -p $(dir $(XO_LOG_OUTPUT))

	$(ECHO) "$(GREEN_COLOR)---- Building kernel $(KERNEL_TOP_FUNCTION_NAME) ----$(DEFAULT_COLOR)"
ifneq ($(strip $(KERNEL_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS) 2>&1
endif


.PHONY: postbuild_kernel
postbuild_kernel:
	$(ECHO) "$(PINK_COLOR)---- Kernel Built $(KERNEL_TOP_FUNCTION_NAME) ----$(DEFAULT_COLOR)"

build_csynth_single: prebuild_kernel $(KERNEL_XO_TARGET) postbuild_kernel


%.mk:
	$(eval CSYNTH_MAKEFILE := $(patsubst %.mk,%,$@))
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk INCLUDE_CSYNTH_MAKEFILE=$(CSYNTH_MAKEFILE) build_csynth_single


build_csynth_all: prebuild_csynth $(CSYNTH_TARGETS)

%.xo: $(KERNEL_SOURCES_EXPANDED)
	v++ -c $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k $(KERNEL_TOP_FUNCTION_NAME) \
	 --log_dir $(BUILD_SYSTEM_BUILD_LOG_DIR)  -o '$@' $^ > $(XO_LOG_OUTPUT) 2>&1