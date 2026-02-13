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
    # Windows lacks a native 'seq', using Python as a robust fallback
    SEQ_0_N_MINUS_1 = python -c "print(' '.join(map(str, range($(1)))))"
    SEQ_1_TO_N = python -c "print(' '.join(map(str, range(1, $(1)+1))))"
    SEQ_START_STEP_END = python -c "print(' '.join(map(str, range($(1), $(3)+1, $(2)))))"
    CALC_EXPRESSION = python -c "print(int($(1)))"
else
    RM = rm -f
    RMDIR = rm -rf
    MKDIR = mkdir -p
    CP = cp -f
    FIX_PATH = $(1)
    EXT =
    NULL = /dev/null
    ECHO:= @echo
    SEQ_0_N_MINUS_1 = seq 0 $$(($(1)-1))
    SEQ_1_TO_N = seq 1 $(1)
    SEQ_START_STEP_END = seq $(1) $(2) $(3)
    CALC_EXPRESSION = echo $$(( $(1) ))
endif

SECTION_DASHES = ----------------------------------------

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