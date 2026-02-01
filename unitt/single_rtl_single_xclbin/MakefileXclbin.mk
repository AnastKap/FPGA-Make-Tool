ifeq ($(findstring zc, $(PLATFORM)), zc)
CONFIG_FILE ?= vadd_soc.cfg
else ifeq ($(findstring vck, $(PLATFORM)), vck)
CONFIG_FILE ?= vadd_soc.cfg
else
CONFIG_FILE ?= vadd_pcie.cfg
endif

FROM_STEP ?=

PROJECT_NAME = rtl_vadd_2clks

KERNEL_TOP_FUNCTION_NAMES = krnl_vadd_2clk_rtl