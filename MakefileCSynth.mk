include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk


%.xo: $(KERNEL_SOURCES_EXPANDED)
	$(eval XO_TOP_FUNC_NAME := $(shell basename $(basename $@)))
	$(eval XO_LOG_OUTPUT := $(MAKEFILE_LOG_FOLDER)/csynth/$(XO_TOP_FUNC_NAME).log)
	@mkdir -p $(dir $(XO_LOG_OUTPUT))
	$(ECHO) "$(GREEN_COLOR)CSynth for xo $@ started at $(shell date). Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	v++ -c $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k $(XO_TOP_FUNC_NAME) \
	 --log_dir $(KERNEL_LOG_FOLDER)  -o '$@' $^ > $(XO_LOG_OUTPUT)