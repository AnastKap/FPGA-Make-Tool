.DEFAULT_GOAL=build_system_all


########################## General ##########################
BUILD_SYSTEM_ABS_PATH ?= $(shell readlink -f $(dir $(lastword $(MAKEFILE_LIST))))

include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk




########################## Folder & File settings ##########################
BUILD_SYSTEM_BUILD_FOLDER = $(abspath $(BUILD_FOLDER)/$(TARGET))

BUILD_SYSTEM_BUILD_XO_DIR = $(BUILD_SYSTEM_BUILD_FOLDER)/xo
BUILD_SYSTEM_BUILD_TEMP_DIR = $(BUILD_SYSTEM_BUILD_FOLDER)/temp_files
BUILD_SYSTEM_BUILD_LOG_DIR = $(BUILD_SYSTEM_BUILD_FOLDER)/log

MAKEFILE_LOG_DIR = $(BUILD_SYSTEM_BUILD_FOLDER)/.makefilelogs

HOST_OUT_FOLDER = $(HOST_BUILD_FOLDER)
HOST_OBJ_FOLDER = $(HOST_OUT_FOLDER)/objs
HOST_OBJS = $(addprefix $(HOST_OBJ_FOLDER)/,$(foreach source,$(HOST_SOURCES),$(subst .cpp,.o,$(source))))

EMCONFIG_DIR = $(HOST_OUT_FOLDER)


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


########################## Include other steps ##########################
include $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk
include $(BUILD_SYSTEM_ABS_PATH)/MakefileXclbin.mk


############################## Setting Targets ##############################
.PHONY: all clean docs emconfig
all: check-platform check-device check-vitis $(BUILD_DIR)/vadd.xclbin emconfig

prebuild:
	$(ECHO) "$(GREEN_COLOR)---- Tools used ----$(DEFAULT_COLOR)"
	@echo "Vitis version: $(shell v++ --version)"
	@echo "Build folder: $(BUILD_SYSTEM_BUILD_FOLDER)"
	@mkdir -p $(BUILD_SYSTEM_BUILD_FOLDER)
	@mkdir -p $(MAKEFILE_LOG_DIR)



prebuild_xclbin:
ifneq ($(strip $(XCLBIN_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS)
endif

.PHONY: build_kernel

build_kernel_xo: build_csynth_all

build_xclbin: $(KERNEL_XCLBIN)

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


############################## Run the flow ##############################
export
build_system_all: prebuild
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk build_csynth_all
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileXclbin.mk INCLUDE_XCLBIN_MAKEFILE=$(XCLBIN_MAKEFILE) build_xclbin