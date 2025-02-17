ipx::package_project -root_dir IP/$ip_name -module $project_name -generated_files -import_files -force

# Set platform compatibility
set_property supported_families {virtex7 Beta qvirtex7 Beta kintex7 Beta kintex7l Beta qkintex7 Beta qkintex7l Beta artix7 Beta artix7l Beta aartix7 Beta qartix7 Beta zynq Beta qzynq Beta azynq Beta spartan7 Beta aspartan7 Beta virtexu Beta virtexuplus Beta virtexuplusHBM Beta kintexuplus Beta zynquplus Beta kintexu Beta} [ipx::current_core]

set core [ipx::current_core]

# Remove SystemC simulation sources
set sim_fg [ipx::get_file_groups xilinx_anylanguagebehavioralsimulation]
foreach file [ipx::get_files -type systemCSource -of_objects $sim_fg] {
	ipx::remove_file [get_property NAME $file] -file_group $sim_fg
}

# Basic information
set_property vendor esa.informatik.tu-darmstadt.de $core
set_property library tapasco $core
set_property name $ip_name $core
set_property display_name "$project_name Processing Element" $core
set_property description "PE containing $project_name RISC-V processor" $core
set_property vendor_display_name {ESA TU Darmstadt} $core

# Interfaces
set_property name interrupt [ipx::get_bus_interfaces INTR.INTERRUPT -of_objects $core]
set_property name CLK [ipx::get_bus_interfaces CLK.CLK -of_objects $core]
ipx::remove_bus_parameter FREQ_HZ [ipx::get_bus_interfaces CLK -of_objects $core]
ipx::remove_bus_parameter PHASE [ipx::get_bus_interfaces CLK -of_objects $core]
set_property name ARESET_N [ipx::get_bus_interfaces RST.ARESET_N -of_objects $core]

if {!$set_ddr_memory} {
	# Memory
	ipx::remove_address_block Mem1 [ipx::get_memory_maps S_AXI_BRAM -of_objects $core]
	set_property range [expr {$lmem * 2}] [ipx::get_address_blocks Mem0 -of_objects [ipx::get_memory_maps S_AXI_BRAM -of_objects $core]]
}
# Finish up
set_property core_revision 1 $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core

ipx::check_integrity -quiet $core
ipx::archive_core IP/$ip_name/esa.informatik.tu-darmstadt.de_tapasco_${ip_name}_1.0.zip $core
ipx::unload_core component_1
