# Troubleshooting Guide

This guide covers common issues encountered while using the FPGA-Make-Tool.

## Build Environment Issues

### `make: command not found`
**Symptoms:** Running `make` directly results in an error.
**Cause:** GNU Make is not installed or not in your system PATH.
**Solution:**
1.  **Windows**: Use the included `make.bat` wrapper (e.g., `..\..\make.bat`).
2.  **Linux**: Install make via `sudo apt install make` (on Ubuntu/Debian).

### `v++: command not found` or `vivado: command not found`
**Symptoms:** The build fails immediately with an error about missing `v++` or `vivado`.
**Cause:** Xilinx tools are not sourced/setup in the current shell.
**Solution:**
1.  **Windows**: Launch the "Vitis 20xx.x Command Prompt" from the Start Menu.
2.  **Linux**: Run `source <Vitis_install_path>/settings64.sh`.

### `lsb_release: command not found`
**Symptoms:** You see this error message at the start of a build on Windows.
**Cause:** `lsb_release` is a Linux command.
**Solution:**
- This is harmless visual noise.
- **Fixed in v1.0.0**: Update to the latest version of `utils.mk` to suppress this error.

## Compilation & Linking Issues

### "The system cannot find the path specified" (Windows)
**Symptoms:** Build fails with path errors, often mentioning `/` vs `\`.
**Cause:** Using older versions of Makefiles that don't handle Windows paths correctly.
**Solution:** Ensure you are using the v1.0.0+ Makefiles which use `$(call FIX_PATH, ...)` macro.

### "Filename too long" or "Path too long"
**Symptoms:** Build fails during Vitis linking or synthesis with obscure file access errors.
**Cause:** Windows has a 260-character path limit, and Vitis creates deep directory structures.
**Solution:**
1.  Move your project closer to the drive root (e.g., `C:\FPGA\`).
2.  Enable long paths in Windows Registry (Computer Configuration > Administrative Templates > System > Filesystem > Enable Win32 long paths).

### "No rule to make target ..."
**Symptoms:** Make stops with an error about missing targets.
**Cause:**
1.  The source file listed in `HOST_SOURCES` or `KERNEL_SOURCES` doesn't exist.
2.  The path to the source file is incorrect.
**Solution:** Double-check your `MakefileVitis.mk` variables and ensure path separators are correct (forward slashes `/` work best in Makefiles even on Windows, as the tool handles conversion).
