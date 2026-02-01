NUMBER_OF_BATCHES ?= 3
PARALLEL_JOBS_IN_BATCH ?= 3

KERNEL_BUILD_FOLDER_BASE ?= .buildExplorationFPGA_


post_batch_build:
	python3 $(CUR_DIR)/append_dataset.py
	@rm -rf $(CUR_DIR)/$(KERNEL_BUILD_FOLDER_BASE)*