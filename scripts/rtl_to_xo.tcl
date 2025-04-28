if { $::argc != 4 } {
    puts "ERROR: Program \"$::argv0\" requires 4 arguments!\n"
    puts "Usage: $::argv0 <build_system_root_dir> <build_system_temp_dir> <xoname> <krnl_name> <ip_dir>\n"
    exit 1
}

set build_sys_root  [lindex $::argv 0]
set build_system_temp_dir [lindex $::argv 1]
set xoname [lindex $::argv 2]
set krnl_name [lindex $::argv 3]

set path_to_packaged "${build_system_temp_dir}/packaged_kernel_${krnl_name}"
set path_to_tmp_project "${build_system_temp_dir}/tmp_kernel_pack_${krnl_name}"

source -notrace ${build_sys_root}/scripts/pkg_vivado_krnl.tcl

if {[file exists "${xoname}"]} {
    file delete -force "${xoname}"
}

package_xo -xo_path ${xoname} -kernel_name ${krnl_name} -ip_directory ${path_to_packaged}
