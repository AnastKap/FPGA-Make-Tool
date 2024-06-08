.DEFAULT_GOAL=help

include $(shell find . -name utils.mk)


########################## Default Definitions ##########################



########################## Folder & File settings ##########################
KERNEL_XO_FOLDER = $(KERNEL_BUILD_FOLDER)/$(TARGET)/xo
KERNEL_TEMP_DIR = $(KERNEL_BUILD_FOLDER)/$(TARGET)/temp_files
KERNEL_LOG_FOLDER = $(KERNEL_BUILD_FOLDER)/$(TARGET)/log


KERNEL_SOURCES_EXPANDED = $(wildcard $(KERNEL_SOURCES))
KERNEL_XCLBIN = $(KERNEL_BUILD_FOLDER)/$(TARGET)/$(KERNEL_NAME).xclbin


HOST_OUT_FOLDER = $(BUILD_FOLDER)/host
HOST_OBJ_FOLDER = $(HOST_OUT_FOLDER)/objs
HOST_OBJS = $(addprefix $(HOST_OBJ_FOLDER)/,$(foreach source,$(HOST_SOURCES),$(subst .cpp,.o,$(source))))

EMCONFIG_DIR = $(HOST_OUT_FOLDER)


########################## Compiler & linker options ##########################
# Kernel compiler global settings
VPP_PFLAGS := 
VPP_FLAGS += --save-temps --temp_dir $(KERNEL_TEMP_DIR)
VPP_FLAGS += $(addprefix -I,$(wildcard $(KERNEL_INCLUDE_FOLDERS)))
ifneq ($(TARGET), hw)
VPP_FLAGS += -g
endif
VPP_LDFLAGS :=
ifdef CONFIG_FILE
CONFIG_FILE_FLAG = --config $(CONFIG_FILE)
endif
# Host compiler global settings
CXXFLAGS += -fmessage-length=0
LDFLAGS += -lrt -lstdc++ 
LDFLAGS += -luuid -lxrt_coreutil
LDFLAGS += -L$(XILINX_XRT)/lib -pthread -lOpenCL
#Include Required Host Source Files
CXXFLAGS += $(addprefix -I,$(HOST_INCLUDE_FOLDERS))
CXXFLAGS += -I$(XILINX_XRT)/include -I$(XILINX_VIVADO)/include -Wall -O0 -g -std=c++1y
HOST_SRCS += $(XF_PROJ_ROOT)/common/includes/cmdparser/cmdlineparser.cpp $(XF_PROJ_ROOT)/common/includes/logger/logger.cpp ./src/host.cpp
CMD_ARGS = -x $(BUILD_DIR)/vadd.xclbin 


MK_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
COMMON_REPO ?= $(shell bash -c 'export MK_PATH=$(MK_PATH); echo $${MK_PATH%hello_world/*}')
PWD = $(shell readlink -f .)
XF_PROJ_ROOT = $(shell readlink -f $(COMMON_REPO))



############################## Setting Targets ##############################
.PHONY: all clean docs emconfig
all: check-platform check-device check-vitis $(BUILD_DIR)/vadd.xclbin emconfig

prebuild: check-vitis

	#@mkdir -p $(EMCONFIG_DIR)


	$(ECHO) "\033[92m---- Tools used ----\033[39m"
	@whereis v++

.PHONY: prebuild_kernel
prebuild_kernel: prebuild
	@mkdir -p $(KERNEL_BUILD_FOLDER)
	@mkdir -p $(KERNEL_LOG_FOLDER)
	@mkdir -p $(KERNEL_TEMP_DIR)
	@mkdir -p $(KERNEL_XO_FOLDER)

	$(ECHO) "\033[92m---- Building kernel ----\033[39m"
ifneq ($(strip $(KERNEL_PREBUILD_STEPS)),)
	make -f $(firstword $(MAKEFILE_LIST)) $(KERNEL_PREBUILD_STEPS)
endif

.PHONY: build_kernel
build_kernel: prebuild_kernel $(KERNEL_XCLBIN)
	$(ECHO) "\033[95m---- Kernel built ----\033[39m"

.PHONY: prebuild_host
prebuild_host:
	@mkdir -p $(HOST_OUT_FOLDER)
	@mkdir -p $(HOST_OBJ_FOLDER)
	$(foreach cpp_file,$(HOST_SOURCES),$(shell mkdir -p $(HOST_OBJ_FOLDER)/$(dir $(cpp_file))))
	
	$(ECHO) "\033[92m---- Building host ----\033[39m"

.PHONY: build_host
build_host: prebuild_host $(HOST_OUT_FOLDER)/$(HOST_APP_NAME)
	$(ECHO) "\033[95m---- Host built ----\033[39m"
	@cp xrt.ini $(HOST_OUT_FOLDER)/xrt.ini
	emconfigutil --platform $(PLATFORM) --od $(HOST_OUT_FOLDER)

.PHONY: build
build: build_host build_kernel
	@-$(RMDIR) .Xil

.PHONY: xclbin
xclbin: build




############################## Building the kernels ##############################
$(KERNEL_XO_FOLDER)/$(KERNEL_NAME).xo: $(KERNEL_SOURCES_EXPANDED)
	$(ECHO) "\033[92mCompiling sources: $^\033[39m"
	v++ -c $(VPP_FLAGS) -t $(TARGET) --platform $(PLATFORM) -k $(KERNEL_TOP_FUNCTION_NAME) \
		$(CONFIG_FILE_FLAG) --log_dir $(KERNEL_LOG_FOLDER)  -o '$@' $^

$(KERNEL_XCLBIN): $(KERNEL_XO_FOLDER)/$(KERNEL_NAME).xo
	$(ECHO) "\033[92mLinking object files to xclbin...\033[39m"
	v++ -l $(VPP_FLAGS) $(VPP_LDFLAGS) -t $(TARGET) --platform $(PLATFORM) --log_dir $(KERNEL_LOG_FOLDER) -o '$@' $^



############################## Building the host application ##############################
$(HOST_OBJ_FOLDER)/%.o: %.cpp
	$(ECHO) "\033[92mCompiling $<...\033[39m"
	g++ -c -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

$(HOST_OUT_FOLDER)/$(HOST_APP_NAME): $(HOST_OBJS)
	$(ECHO) "\033[92mLinking object files to final host application...\033[39m"
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

