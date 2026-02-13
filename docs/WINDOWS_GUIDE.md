# Windows Setup and Usage Guide

This guide provides detailed instructions for setting up and using the FPGA-Make-Tool on Windows 10/11.

## Prerequisites

1.  **Xilinx Vitis & Vivado**:
    *   Install Vitis (which includes Vivado).
    *   Supported versions: 2021.1 and newer (Tested up to 2023.2).
    *   **Important**: During installation, ensure you select Windows support.

2.  **Make Utility**:
    *   The tool relies on `make`.
    *   **Option A (Recommended)**: Use the `make.bat` wrapper included in this repository. It automatically finds `make`, `mingw32-make`, or `gmake` (often bundled with Xilinx).
    *   **Option B**: Install a standalone `make` (e.g., via [MinGW](https://osdn.net/projects/mingw/) or [Chocolatey](https://chocolatey.org/): `choco install make`).

## Setup Steps

1.  **Environment Variables**:
    *   You do **not** need to manually add Vitis/Vivado binaries to your global System `PATH` if you use the Xilinx Shell.
    *   **Recommended Workflow**: Launch the "Vitis 20xx.x Command Prompt" or "Vivado 20xx.x Command Prompt" from your Start Menu. This shell has all necessary paths (like `v++` and `vivado`) pre-configured.

2.  **Verify Setup**:
    *   Open your terminal (Vitis Command Prompt).
    *   Run: `v++ --version`
    *   Run: `vivado -version`
    *   If these commands work, you are ready.

## Using the `make.bat` Wrapper

If you do not have `make` installed globally, use the `make.bat` script located in the root of this repository.

### Usage
From your project directory (e.g., `unit/simple_example`), run:

```cmd
..\..\make.bat [TARGETS] [VARIABLES]
```

### Examples

*   **Dry Run** (Print commands without executing):
    ```cmd
    ..\..\make.bat -n
    ```

*   **Build Host Application**:
    ```cmd
    ..\..\make.bat build_host
    ```

*   **Full Hardware Build**:
    ```cmd
    ..\..\make.bat build_system_all TARGET=hw PLATFORM=xilinx_u200_gen3x16_xdma_2_202110_1
    ```

## Common Windows Issues

### "The system cannot find the path specified"
*   **Cause**: Makefiles are trying to use Linux-style paths or commands.
*   **Solution**: Since v1.0.0, this tool handles paths automatically. Ensure you are using the latest version of `MakefileCommon.mk`.

### "make: command not found"
*   **Cause**: `make` is not in your PATH.
*   **Solution**: Use the `make.bat` wrapper as described above.

### Path Length Limits
*   **Issue**: Windows has a 260-character path limit. Vitis builds can create deep directory structures.
*   **Solution**:
    *   Enable "Long Paths" in Windows Registry.
    *   Or keep your project close to the drive root (e.g., `C:\FPGA\Projects\`).
