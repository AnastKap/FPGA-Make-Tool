.DEFAULT_GOAL=build_system_all


########################## General ##########################
MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CUR_DIR := $(patsubst %/,%,$(dir $(MK_PATH)))
BUILD_SYSTEM_ABS_PATH := $(CUR_DIR)

# Check Vitis Version safely
include $(BUILD_SYSTEM_ABS_PATH)/MakefileCommon.mk

# Check Vitis Version safely
Vitis_Version_Check := $(shell v++ --version 2> $(NULL))
ifeq ($(strip $(Vitis_Version_Check)),)
    VITIS_VERSION := Vitis not found
else
    VITIS_VERSION := $(Vitis_Version_Check)
endif

AR = ar

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


COMMON_REPO ?= $(abspath $(MK_PATH)/../../..)
PWD = $(shell cd)
XF_PROJ_ROOT = $(COMMON_REPO)


########################## Include other steps ##########################
include $(BUILD_SYSTEM_ABS_PATH)/MakefileCSynth.mk
include $(BUILD_SYSTEM_ABS_PATH)/MakefileXclbin.mk


############################## Setting Targets ##############################
.PHONY: all clean docs emconfig
all: check-platform check-device check-vitis $(BUILD_DIR)/vadd.xclbin emconfig

prebuild:
	$(ECHO) $(GREEN_COLOR)---- Tools used ----$(DEFAULT_COLOR)
	@echo "Vitis version: $(VITIS_VERSION)"
	@echo "Build folder: $(BUILD_SYSTEM_BUILD_FOLDER)"
	-@$(MKDIR) $(call FIX_PATH,$(BUILD_SYSTEM_BUILD_FOLDER))
	-@$(MKDIR) $(call FIX_PATH,$(BUILD_SYSTEM_BUILD_TEMP_DIR))
	-@$(MKDIR) $(call FIX_PATH,$(BUILD_SYSTEM_BUILD_LOG_DIR))
	-@$(MKDIR) $(call FIX_PATH,$(MAKEFILE_LOG_DIR))
ifneq ($(strip $(BUILD_SYSTEM_PREBUILD_STEPS)),)
	$(MAKE) -f $(firstword $(MAKEFILE_LIST)) $(BUILD_SYSTEM_PREBUILD_STEPS) 2>&1
endif



prebuild_xclbin:
ifneq ($(strip $(XCLBIN_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS)
endif

.PHONY: build_kernel

build_kernel_xo: build_csynth_all

build_xclbin: $(KERNEL_XCLBIN)

.PHONY: prebuild_host
prebuild_host:
	-@$(MKDIR) $(call FIX_PATH,$(HOST_OUT_FOLDER))
	-@$(MKDIR) $(call FIX_PATH,$(HOST_OBJ_FOLDER))
	$(foreach cpp_file,$(HOST_SOURCES),$(shell $(MKDIR) $(call FIX_PATH,$(HOST_OBJ_FOLDER)/$(dir $(cpp_file)))))
	
	$(ECHO) $(GREEN_COLOR)---- Building host ----$(DEFAULT_COLOR)
ifneq ($(strip $(HOST_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(HOST_PREBUILD_STEPS)
endif

.PHONY: build_host
ifeq ($(strip $(HOST_STATIC_LIB)),0)
build_host: prebuild_host $(HOST_OUT_FOLDER)/$(HOST_APP_NAME)
else
build_host: prebuild_host $(HOST_OUT_FOLDER)/$(HOST_STATIC_LIB_NAME)
endif	
	$(ECHO) $(PINK_COLOR)---- Host built ----$(DEFAULT_COLOR)
ifeq ($(strip $(HOST_XRT_INI_PATH)),)
	@$(CP) xrt.ini $(call FIX_PATH,$(HOST_OUT_FOLDER)/xrt.ini)
else
	@$(CP) $(call FIX_PATH,$(HOST_XRT_INI_PATH)) $(call FIX_PATH,$(HOST_OUT_FOLDER)/xrt.ini)
endif
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
	$(ECHO) $(GREEN_COLOR)Compiling $<...$(DEFAULT_COLOR)
	g++ -c -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

$(HOST_OUT_FOLDER)/$(HOST_APP_NAME): $(HOST_OBJS)
	$(ECHO) $(GREEN_COLOR)Linking object files to final host application...$(DEFAULT_COLOR)
	g++ -o $@ $^ $(LDFLAGS)

$(HOST_OUT_FOLDER)/$(HOST_STATIC_LIB_NAME): $(HOST_OBJS)
	$(ECHO) $(GREEN_COLOR)Linking object files to final host static library...$(DEFAULT_COLOR)
	$(AR) rcs $@ $^


emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(PLATFORM) --od $(EMCONFIG_DIR)


############################## Cleaning Rules ##############################
# Cleaning stuff
clean_host:
	-$(RMDIR) $(call FIX_PATH,$(HOST_OUT_FOLDER))

clean:
	-$(RMDIR) $(call FIX_PATH,$(BUILD_FOLDER)) .Xil
	-$(RMDIR) .Xil


############################## Run the flow ##############################
export
build_system_all: prebuild
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/Makefile_C_RTL_pkg.mk build_c_rtl_pkg
ifneq ($(strip $(XCLBIN_MAKEFILE)),)
	$(MAKE) -f $(BUILD_SYSTEM_ABS_PATH)/MakefileXclbin.mk INCLUDE_XCLBIN_MAKEFILE=$(XCLBIN_MAKEFILE) build_xclbin
endif