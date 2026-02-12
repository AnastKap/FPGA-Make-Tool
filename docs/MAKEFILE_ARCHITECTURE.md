# Makefile Architecture

The FPGA-Make-Tool is built on a modular Makefile architecture designed for reusability and cross-platform compatibility. This document explains the internal structure and how the different files interact.

## File Hierarchy

The build system relies on a hierarchy of includes. The main entry point is typically a project-specific Makefile (e.g., `MakefileSingleBitstream.mk`) which then includes specialized modules.

```mermaid
graph TD
    UserMakefile[User Makefile (MakefileVitis.mk)] -->|include| RootMakefile[Root Makefile (e.g. MakefileSingleBitstream.mk)]
    RootMakefile -->|include| Common[MakefileCommon.mk]
    RootMakefile -->|include| CSynth[MakefileCSynth.mk]
    RootMakefile -->|include| Xclbin[MakefileXclbin.mk]
    
    CSynth -->|uses| Common
    Xclbin -->|uses| Common
    
    Utils[utils.mk] -->|include| Common
```

## Core Modules

### 1. `MakefileCommon.mk`
This file is the foundation of cross-platform compatibility.
- **OS Detection**: It checks `$(OS)` to determine if running on Windows or Linux.
- **Command Abstraction**:
    - `RM`: `del /F /Q` (Windows) vs `rm -f` (Linux)
    - `RMDIR`: `rmdir /S /Q` (Windows) vs `rm -rf` (Linux)
    - `MKDIR`: `mkdir` (Windows) vs `mkdir -p` (Linux)
    - `CP`: `copy /Y` (Windows) vs `cp -f` (Linux)
- **Path Handling**:
    - Defines `FIX_PATH` macro to convert forward slashes (`/`) to backslashes (`\`) on Windows for shell commands.
    - Sets `EXT` for executables (`.exe` on Windows).

### 2. `MakefileCSynth.mk`
Handles the **High-Level Synthesis (HLS)** step.
- Converts C/C++ kernel code into RTL (Register Transfer Level) code.
- Generates `.xo` (Xilinx Object) files.
- Uses `v++ -c` (compile mode).

### 3. `MakefileXclbin.mk`
Handles the **Linking** step.
- Takes generated `.xo` files and links them into a `.xclbin` (Xilinx Container Binary) bitstream.
- Uses `v++ -l` (link mode).
- Manages platform linking (`--platform`) and target (`hw`, `hw_emu`, `sw_emu`).

### 4. `utils.mk`
Provides helper functions and environment checks.
- Validates `XILINX_VITIS` and `XILINX_XRT` environment variables.
- Generates launch scripts (`run_app.bat` / `run_app.sh`).

## Key Variables

When using the tool, several key variables control the build process:

| Variable                   | Description                                                                                 | Default / Example |
| :------------------------- | :------------------------------------------------------------------------------------------ | :---------------- |
| `TARGET`                   | Build target: `sw_emu` (Software Emulation), `hw_emu` (Hardware Emulation), `hw` (Hardware) | `sw_emu`          |
| `PLATFORM`                 | FPGA Platform to target (found in Vitis installation)                                       | `xilinx_u200...`  |
| `PROJECT_NAME`             | Name of the output project/application                                                      | `vadd`            |
| `KERNEL_TOP_FUNCTION_NAME` | The name of the top-level C++ function for the kernel                                       | `vadd`            |
| `HOST_SOURCES`             | List of C++ source files for the host application                                           | `src/host.cpp`    |
| `KERNEL_SOURCES`           | List of C++ source files for the kernel                                                     | `src/kernel.cpp`  |
