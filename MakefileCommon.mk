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