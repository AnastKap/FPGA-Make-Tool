.DEFAULT_GOAL := all

# Exploration definitions
FREQUENCY_STEP ?= 10
STARTING_FREQUENCY ?= 50
NUMBER_OF_FREQ_STEPS ?= 20


# User settings
#PARALLEL_JOBS ?= 1
PLATFORM ?= xilinx_u200_xdma_201830_2
TARGET ?= hw



# Run settings
CUR_DIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

LOG_ROOT_FOLDER ?= $(CUR_DIR)/.logs

KERNEL_TOP_FUNCTION_NAME = FPGA_Diffusion_Convection_kernel
#KERNEL_BUILD_FOLDER_BASE ?= $(CUR_DIR)/.buildExplorationFPGA
ENDING_FREQUENCY = $(shell echo $$(($(STARTING_FREQUENCY) + ($(NUMBER_OF_FREQ_STEPS) - 1) \* $(FREQUENCY_STEP))))
EXPLORATION_FREQUENCIES = $(addsuffix MHz, $(shell for i in $$(seq $(STARTING_FREQUENCY) \
								$(FREQUENCY_STEP) $(ENDING_FREQUENCY)); do echo $$i; done))

TARGETS := $(EXPLORATION_FREQUENCIES)

.PHONY: prebuild
include ../../MakefileCommon.mk

.PHONY: prebuild
prebuild:
	-@$(MKDIR) $(call FIX_PATH,$(LOG_ROOT_FOLDER))

%MHz: prebuild
	$(eval CURRENT_RUN_FREQUENCY := $(patsubst %MHz,%,$@))
	$(eval LOG_FILE := $(LOG_ROOT_FOLDER)/$@.log)
	@echo "Running exploration for $@..."
	@$(MAKE) -j1 -C ../../ -f MakefileVitis.mk TARGET=$(TARGET) PLATFORM=$(PLATFORM) \
		KERNEL_BUILD_FOLDER=$(KERNEL_BUILD_FOLDER_BASE)_$@ KERNEL_FREQUENCY_MHz=$(CURRENT_RUN_FREQUENCY) \
		KERNEL_TOP_FUNCTION_NAME=$(KERNEL_TOP_FUNCTION_NAME) build_kernel_xo > $(LOG_FILE) 2>&1

.PHONY: all
all: $(TARGETS)
	@echo "Running all kernels"

clean_all:
	@echo "Cleaning exploration"
clean_all:
	@echo "Cleaning exploration"
	-@$(RMDIR) $(call FIX_PATH,$(LOG_ROOT_FOLDER))
	-@$(RMDIR) $(call FIX_PATH,$(KERNEL_BUILD_FOLDER_BASE)_*)




################### New #############################
.DEFAULT_GOAL := build_system_all



GENERAL_SETTINGS_MAKEFILE = $(abspath $(CUR_DIR)/MakefileGeneralSettings.mk)
BATCH_SETTINGS_MAKEFILE = $(abspath $(CUR_DIR)/MakefileJobInBatchSettings.mk)
POST_BATCH_TARGET = post_batch_build
BUILD_SYSTEM_LOG_ROOT_FOLDER = $(CUR_DIR)/.build_system_logs
BUILD_SYSTEM_ABS_ROOT_DIR = $(abspath $(CUR_DIR)/../..)

include $(BUILD_SYSTEM_ABS_ROOT_DIR)/MakefileParallelBitstream.mk
