if { $::argc < 5 } {
    puts "ERROR: Program \"$::argv0\" requires at least 5 arguments!\n"
    puts "Usage: $::argv0 <build_system_root_dir> <build_system_temp_dir> <xoname> <krnl_name> <ip_settings_tcl> <file1> ...\n"
    exit 1
}

set build_sys_root  [lindex $::argv 0]
set build_system_temp_dir [lindex $::argv 1]
set xoname [lindex $::argv 2]
set krnl_name [lindex $::argv 3]
set ip_settings_tcl [lindex $::argv 4]
set xoname_basename [file rootname [file tail $xoname]]
puts "Basename of xoname: $xoname_basename"

set file_list [lrange $::argv 5 end]
puts "Source files given: $file_list"

set path_to_packaged "${build_system_temp_dir}/packaged_kernel_${xoname_basename}"
set path_to_tmp_project "${build_system_temp_dir}/tmp_kernel_pack_${xoname_basename}"

source -notrace ${build_sys_root}/scripts/pkg_vivado_krnl.tcl

if {[file exists "${xoname}"]} {
    file delete -force "${xoname}"
}

package_xo -xo_path ${xoname} -kernel_name ${krnl_name} -ip_directory ${path_to_packaged}
