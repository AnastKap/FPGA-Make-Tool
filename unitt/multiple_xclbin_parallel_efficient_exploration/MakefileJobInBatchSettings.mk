##################################################
# Takes as inputs:
# - The BATCH_ID, which must be unique for each 
# batch (starting from 1)
# - The JOB_IN_BATCH_ID, which is the internal ID
# of the parallel job in the batch (starting
# from 1)
#################################################

# Exploration general definitions
FREQUENCY_STEP ?= 10
STARTING_FREQUENCY ?= 50



# Specific job settings
PLATFORM=xilinx_u200_xdma_201830_2
TARGET=hw
KERNEL_TOP_FUNCTION_NAMES = 
KERNEL_TOP_FUNCTION_NAME = bandwidth
KERNEL_FREQUENCY_MHz = $(shell echo $$(($(STARTING_FREQUENCY) + (($(BATCH_ID) - 1)*$(PARALLEL_JOBS_IN_BATCH) + $(JOB_IN_BATCH_ID) - 1) * $(FREQUENCY_STEP))))
KERNEL_BUILD_FOLDER = $(CUR_DIR)/$(KERNEL_BUILD_FOLDER_BASE)$(KERNEL_FREQUENCY_MHz)



build_job_user_impl:
	$(eval LOG_FILE := $(LOG_ROOT_FOLDER)/batch_$(BATCH_ID)_job_$(JOB_IN_BATCH_ID).log)
	@rm -rf $(LOG_FILE)
	@mkdir -p $(dir $(LOG_FILE))
	@echo "Running job $(JOB_IN_BATCH_ID) in batch $(BATCH_ID) \
		(Makefile output at $(LOG_FILE))"
	@make -C $(CUR_DIR)/../single_xo_single_xclbin build_kernel_xo > $(LOG_FILE) 2>&1