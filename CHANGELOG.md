# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-02-12

### Added
- Windows support for all Makefiles.
- `make.bat` wrapper script to automatically find and run `make` (or `mingw32-make`/`gmake`) on Windows.
- `MakefileCommon.mk` with OS detection logic (`Windows_NT` vs Linux).
- Abstract commands for file operations: `$(RM)`, `$(RMDIR)`, `$(MKDIR)`, `$(CP)`.
- `$(FIX_PATH)` macro to handle path separators (`\` on Windows, `/` on Linux).

### Changed
- Refactored `utils.mk` to generate platform-specific run scripts (`run_app.bat` for Windows, `run_app.sh` for Linux).
- Updated all root Makefiles (`CSynth`, `Xclbin`, `SingleBitstream`, `RTLPkg`) to use abstract commands.
- Removed Linux-specific `readlink -f` calls, replaced with cross-platform Python one-liners.
- Removed `date` command from logs to avoid Windows compatibility issues.
- Updated `README.md` with Windows usage instructions and missing documentation sections.

### Unit Tests
- Verified and fixed Makefiles in `unit/` directory to inherit Windows compatibility.
- **Code Simplification**:
    - Refactored `unit/single_c_single_xclbin/src/kernel_global_bandwidth.cpp`.
    - Refactored `unit/multiple_c_single_xclbin/src/host.cpp`.
    - Refactored `unit/single_rtl_single_xclbin/src/host.cpp`.
    - Refactored `unit/multiple_rtl_single_xclbin/src/host.cpp`.
    - Improvements include:
        - Replaced `malloc/free` with `std::vector` (RAII).
        - Standardized logging to `std::cout`.
        - Improved type safety and modernized C++ code.

### Fixed
- Fixed `unit/multiple_xclbin_parallel_efficient_exploration/Makefile` to support Windows commands.
- Fixed `MakefileSingleBitstream.mk` include path resolution to work without Python, solving "No such file or directory" errors on Windows.
- Robustified `MakefileSingleBitstream.mk` and `MakefileXclbin.mk` to handle missing `v++` gracefully during dry runs.
