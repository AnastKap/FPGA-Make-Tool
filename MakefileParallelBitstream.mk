include $(shell readlink -f $(dir $(lastword $(MAKEFILE_LIST)))/MakefileCommon.mk)

include $(GENERAL_SETTINGS_MAKEFILE)
export


##################################################
##################################################
# The following definitions are general
##################################################
##################################################

SECTION_DASHES = $(shell echo "----------------------------------------")



##################################################
##################################################
# The following definitions are applied when 
# building a single job in a batch
##################################################
##################################################


include $(BATCH_SETTINGS_MAKEFILE)
export

build_job: build_job_user_impl


##################################################
##################################################
# The following definitions are applied when 
# building a batch
##################################################
##################################################

IN_BATCH_JOB_TARGETS = $(foreach i,$(shell seq 0 $$(($(PARALLEL_JOBS_IN_BATCH)-1))),job_in_batch_$(i))

job_in_batch_%:
	$(eval JOB_IN_BATCH_ID := $(patsubst job_in_batch_%,%,$@))
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_ROOT_DIR)/MakefileParallelBitstream.mk BATCH_ID=$(BATCH_ID) JOB_IN_BATCH_ID=$(JOB_IN_BATCH_ID) build_job

post_batch_completion: $(IN_BATCH_JOB_TARGETS)
	@echo Running post batch completion step...
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_ROOT_DIR)/MakefileParallelBitstream.mk BATCH_ID=$(BATCH_ID) JOB_IN_BATCH_ID=$(JOB_IN_BATCH_ID) post_batch_build

.PHONY: build_batch_all
build_batch_all: post_batch_completion



##################################################
##################################################
# The following definitions are applied when 
# invoking the whole build system
##################################################
##################################################

BATCH_TARGETS = $(foreach i,$(shell seq 1 $(NUMBER_OF_BATCHES)),build_batch_$(i))

.PHONY: build_system_init
build_system_init:
	@rm -rf $(LOG_ROOT_FOLDER)
ifneq ($(PRE_PARALLEL_STEP),)
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_ROOT_DIR)/MakefileParallelBitstream.mk $(PRE_PARALLEL_STEP)
endif 

build_batch_%:
	$(eval BATCH_ID := $(patsubst build_batch_%,%,$@))
	@echo $(GREEN_COLOR)$(SECTION_DASHES)$(DEFAULT_COLOR)
	@echo $(GREEN_COLOR)Building batch $(BATCH_ID)$(DEFAULT_COLOR)
	@echo $(GREEN_COLOR)$(SECTION_DASHES)$(DEFAULT_COLOR)
	@$(MAKE) -f $(BUILD_SYSTEM_ABS_ROOT_DIR)/MakefileParallelBitstream.mk BATCH_ID=$(BATCH_ID) -j$(PARALLEL_JOBS_IN_BATCH) build_batch_all
	@echo $(PINK_COLOR)$(SECTION_DASHES)$(DEFAULT_COLOR)
	@echo $(PINK_COLOR)Batch $(BATCH_ID) built$(DEFAULT_COLOR)
	@echo $(PINK_COLOR)$(SECTION_DASHES)$(DEFAULT_COLOR)

.PHONY: build_system_all
build_system_all: build_system_init $(BATCH_TARGETS)
	