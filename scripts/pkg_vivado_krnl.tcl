set path_to_hdl "./src/hdl"

create_project -force kernel_pack $path_to_tmp_project 
add_files -norecurse ${file_list}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project -root_dir $path_to_packaged -vendor xilinx.com -library RTLKernel -taxonomy /KernelIP -import_files -set_current false
ipx::unload_core $path_to_packaged/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $path_to_packaged $path_to_packaged/component.xml

source ${ip_settings_tcl}

close_project -delete
