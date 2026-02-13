NUMBER_OF_BATCHES ?= 3
PARALLEL_JOBS_IN_BATCH ?= 3

KERNEL_BUILD_FOLDER_BASE ?= .buildExplorationFPGA_


post_batch_build:
	python $(TEST_DIR)/append_dataset.py
	-@$(RMDIR) $(call FIX_PATH,$(TEST_DIR)/$(KERNEL_BUILD_FOLDER_BASE)*)