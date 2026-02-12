########################## Default Definitions ##########################
# OS Detection and Command Abstraction
ifeq ($(OS),Windows_NT)
    RM = cmd /c del /F /Q
    RMDIR = cmd /c rmdir /S /Q
    MKDIR = cmd /c mkdir
    CP = cmd /c copy /Y
    # Macro to fix paths for Windows (replace / with \)
    FIX_PATH = $(subst /,\,$(1))
    EXT = .exe
    NULL = NUL
    ECHO:= @cmd /c echo
else
    RM = rm -f
    RMDIR = rm -rf
    MKDIR = mkdir -p
    CP = cp -f
    FIX_PATH = $(1)
    EXT =
    NULL = /dev/null
    ECHO:= @echo
endif

# Terminal Colors (Disable on Windows to prevent syntax errors with quotes)
ifneq ($(strip $(NO_TERMINAL_COLOR)),)
ifeq ($(OS),Windows_NT)
    DEFAULT_COLOR := 
    GREEN_COLOR := 
    PINK_COLOR := 
else
    DEFAULT_COLOR := "\033[39m"
    GREEN_COLOR := "\033[92m"
    PINK_COLOR := "\033[95m"
endif
else
    DEFAULT_COLOR := 
    GREEN_COLOR := 
    PINK_COLOR := 
endif