########################## Default Definitions ##########################
# OS Detection and Command Abstraction
ifeq ($(OS),Windows_NT)
    RM = del /F /Q
    RMDIR = rmdir /S /Q
    MKDIR = mkdir
    CP = copy /Y
    # Macro to fix paths for Windows (replace / with \)
    FIX_PATH = $(subst /,\,$(1))
    EXT = .exe
    NULL = NUL
else
    RM = rm -f
    RMDIR = rm -rf
    MKDIR = mkdir -p
    CP = cp -f
    FIX_PATH = $(1)
    EXT =
    NULL = /dev/null
endif

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