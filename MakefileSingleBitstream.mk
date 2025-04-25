.DEFAULT_GOAL=help



########################## Default Definitions ##########################
RM = rm -f
RMDIR = rm -rf

ECHO:= @echo

ifeq ($(strip $(NO_TERMINAL_COLOR)),)
DEFAULT_COLOR := "\\033[39m"
GREEN_COLOR := "\\033[92m"
PINK_COLOR := "\\033[95m"
else
DEFAULT_COLOR := 
GREEN_COLOR := 
PINK_COLOR := 
endif


########################## Folder & File settings ##########################
SINGLE_BITSTREAM_BUILD_FOLDER = $(KERNEL_BUILD_FOLDER)/$(TARGET)
KERNEL_XO_FOLDER = $(KERNEL_BUILD_FOLDER)/$(TARGET)/xo
KERNEL_TEMP_DIR = $(KERNEL_BUILD_FOLDER)/$(TARGET)/temp_files
KERNEL_LOG_FOLDER = $(KERNEL_BUILD_FOLDER)/$(TARGET)/log


KERNEL_SOURCES_EXPANDED = $(KERNEL_SOURCES) #$(wildcard $(KERNEL_SOURCES))
KERNEL_XCLBIN = $(KERNEL_BUILD_FOLDER)/$(TARGET)/$(KERNEL_NAME).xclbin



HOST_OUT_FOLDER = $(HOST_BUILD_FOLDER)
HOST_OBJ_FOLDER = $(HOST_OUT_FOLDER)/objs
HOST_OBJS = $(addprefix $(HOST_OBJ_FOLDER)/,$(foreach source,$(HOST_SOURCES),$(subst .cpp,.o,$(source))))

EMCONFIG_DIR = $(HOST_OUT_FOLDER)

MAKEFILE_LOG_FOLDER = $(SINGLE_BITSTREAM_BUILD_FOLDER)/.makefilelogs


################ Makefile internal settings ##############################
XO_TARGETS = $(addsuffix .xo,$(addprefix $(KERNEL_XO_FOLDER)/,$(KERNEL_TOP_FUNCTION_NAMES)))



################ Makefile internal settings ##############################
XO_TARGETS = $(addsuffix .xo,$(addprefix $(KERNEL_XO_FOLDER)/,$(KERNEL_TOP_FUNCTION_NAMES)))



########################## Compiler & linker options ##########################
# Kernel compiler global settings
VPP_FLAGS := -R2 $(ADDITIONAL_VPP_FLAGS)
VPP_FLAGS += --save-temps --temp_dir $(KERNEL_TEMP_DIR)
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
# Host compiler global settings
CXXFLAGS += -fmessage-length=0
LDFLAGS += -lrt -lstdc++ 
LDFLAGS += -luuid -lxrt_coreutil
LDFLAGS += -L$(XILINX_XRT)/lib -pthread -lOpenCL
#Include Required Host Source Files
CXXFLAGS += $(addprefix -I,$(HOST_INCLUDE_FOLDERS))
CXXFLAGS += -I$(XILINX_XRT)/include -I$(XILINX_HLS)/include -Wall -O0 -g -std=c++1y
CXXFLAGS += -D__HOST__ $(ADDITIONAL_CXX_FLAGS)
HOST_SRCS += $(XF_PROJ_ROOT)/common/includes/cmdparser/cmdlineparser.cpp $(XF_PROJ_ROOT)/common/includes/logger/logger.cpp ./src/host.cpp
CMD_ARGS = -x $(BUILD_DIR)/vadd.xclbin 


MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
COMMON_REPO ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo $${MK_PATH%hello_world/*}')
PWD = $(shell readlink -f .)
XF_PROJ_ROOT = $(shell readlink -f $(COMMON_REPO))



############################## Setting Targets ##############################
.PHONY: all clean docs emconfig
all: check-platform check-device check-vitis $(BUILD_DIR)/vadd.xclbin emconfig

prebuild:
	$(ECHO) "$(GREEN_COLOR)---- Tools used ----$(DEFAULT_COLOR)"
	@echo "Vitis version: $(shell v++ --version)"
	@echo "Build folder: $(KERNEL_BUILD_FOLDER)"
	@echo "Kernel name: $(KERNEL_NAME)"
	@echo "Kernel frequency: $(KERNEL_FREQUENCY_MHz) MHz"
	@echo "Kernel prebuild steps: $(KERNEL_PREBUILD_STEPS)"

.PHONY: prebuild_kernel
prebuild_kernel: prebuild
	@mkdir -p $(KERNEL_BUILD_FOLDER)
	@mkdir -p $(KERNEL_LOG_FOLDER)
	@mkdir -p $(KERNEL_TEMP_DIR)
	@mkdir -p $(KERNEL_XO_FOLDER)
	@rm -rf $(MAKEFILE_LOG_FOLDER)
	@mkdir -p $(MAKEFILE_LOG_FOLDER)

	$(ECHO) "$(GREEN_COLOR)---- Building kernel ----$(DEFAULT_COLOR)"
ifneq ($(strip $(KERNEL_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS) 2>&1
endif

prebuild_xclbin:
ifneq ($(strip $(XCLBIN_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS)
endif

.PHONY: build_kernel

build_kernel_xo: prebuild_kernel $(KERNEL_XO_FOLDER)/$(KERNEL_TOP_FUNCTION_NAME).xo
	$(ECHO) "$(GREEN_COLOR)---- Kernel built ----$(DEFAULT_COLOR)"

build_xclbin: prebuild_kernel $(KERNEL_XCLBIN)

.PHONY: prebuild_host
prebuild_host:
	@mkdir -p $(HOST_OUT_FOLDER)
	@mkdir -p $(HOST_OBJ_FOLDER)
	$(foreach cpp_file,$(HOST_SOURCES),$(shell mkdir -p $(HOST_OBJ_FOLDER)/$(dir $(cpp_file))))
	
	$(ECHO) "$(GREEN_COLOR)---- Building host ----$(DEFAULT_COLOR)"
ifneq ($(strip $(HOST_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(HOST_PREBUILD_STEPS)
endif

.PHONY: build_host
build_host: prebuild_host $(HOST_OUT_FOLDER)/$(HOST_APP_NAME)
	$(ECHO) "$(PINK_COLOR)---- Host built ----$(DEFAULT_COLOR)"
	@cp xrt.ini $(HOST_OUT_FOLDER)/xrt.ini
ifeq ($(strip $(TARGET)), hw_emu)
	emconfigutil --platform $(PLATFORM) --od $(HOST_OUT_FOLDER)
endif

.PHONY: build
build: build_host build_kernel
	@-$(RMDIR) .Xil

.PHONY: xclbin
xclbin: build




############################## Building the kernels ##############################
%.xo: $(KERNEL_SOURCES_EXPANDED)
	$(eval XO_TOP_FUNC_NAME := $(shell basename $(basename $@)))
	$(eval XO_LOG_OUTPUT := $(MAKEFILE_LOG_FOLDER)/csynth/$(XO_TOP_FUNC_NAME).log)
	@mkdir -p $(dir $(XO_LOG_OUTPUT))
	$(ECHO) "$(GREEN_COLOR)CSynth for xo $@ started at $(shell date). Makefile output at $(XO_LOG_OUTPUT)$(DEFAULT_COLOR)"
	v++ -c $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k $(XO_TOP_FUNC_NAME) \
	 --log_dir $(KERNEL_LOG_FOLDER)  -o '$@' $^ > $(XO_LOG_OUTPUT)

$(KERNEL_XCLBIN): $(XO_TARGETS)
	$(ECHO) "$(GREEN_COLOR)Linking object files to xclbin...$(DEFAULT_COLOR)"
	v++ -l $(VPP_FLAGS) $(VPP_LDFLAGS) -t $(TARGET) --platform $(PLATFORM) --log_dir $(KERNEL_LOG_FOLDER) -o '$@' $^



############################## Building the host application ##############################
$(HOST_OBJ_FOLDER)/%.o: %.cpp
	$(ECHO) "$(GREEN_COLOR)Compiling $<...$(DEFAULT_COLOR)"
	g++ -c -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

$(HOST_OUT_FOLDER)/$(HOST_APP_NAME): $(HOST_OBJS)
	$(ECHO) "$(GREEN_COLOR)Linking object files to final host application...$(DEFAULT_COLOR)"
	g++ -o $@ $^ $(LDFLAGS)



emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(PLATFORM) --od $(EMCONFIG_DIR)


############################## Cleaning Rules ##############################
# Cleaning stuff
clean_host:
	-$(RMDIR) $(HOST_OUT_FOLDER)

clean:
	-$(RMDIR) $(KERNEL_BUILD_FOLDER)/$(TARGET) .Xil
	-$(RMDIR) .Xil

