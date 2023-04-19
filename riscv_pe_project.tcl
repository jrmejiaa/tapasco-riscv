#*****************************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# riscv_pe_project.tcl: Tcl script for re-creating project 'riscv_pe'
#
# Generated by Vivado on Wed Sep 19 18:34:31 CEST 2018
# IP Build 2085800 on Fri Dec 15 22:25:07 MST 2017
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************
# NOTE: In order to use this script for source control purposes, please make sure that the
#       following files are added to the source control system:-
#
# 1. This project restoration tcl script (riscv_pe_project.tcl) that was generated.
#
# 2. The following source(s) files that were local or imported into the original project.
#    (Please see the '$orig_proj_dir' and '$origin_dir' variable setting below at the start of the script)
#
#
# 3. The following remote source files that were added to the original project:-
#
#    <none>
#
#*****************************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set project_name "riscv_pe"

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set project_name $::user_project_name
}

variable script_file
set script_file "riscv_pe_project.tcl"

source common/parse_args.tcl

# sets is_cache_available
source common/cache_availability.tcl

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/$project_name"]"

# Create project
create_project -force ${project_name} ./${project_name} -part $part

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
# None

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${project_name}.cache/ip" -objects $obj
set_property -name "part" -value "$part" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
source common/ip_repo_path.tcl
set ip_paths [get_property "ip_repo_paths" $obj]
puts $ip_paths
set_property "ip_repo_paths" $ip_paths $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Proc to create BD riscv_pe
proc cr_bd_riscv_pe { parentCell lmem } {
  variable project_name
  variable cache
  variable maxi_ports
  variable is_cache_available

  # CHANGE DESIGN NAME HERE
  set design_name ${project_name}

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name
  # sets cpu_vlnv
  source common/cpu_vlnv.tcl
  set current_core [dict get $cpu_vlnv $project_name]
  source common/check_ips.tcl

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  source common/place_tapasco_control.tcl

  source common/place_local_memory.tcl

  source specific_tcl/${project_name}_project.tcl

  source common/connect_common_interfaces.tcl
  
  # Create port connections
  
  source common/connect_common_ports.tcl
  
  
  # Create address segments
  source common/common_addr_segments.tcl
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
  close_bd_design $design_name 
}
# End of cr_bd_riscv_pe()
cr_bd_riscv_pe "" $lmem

set bd_file [get_files ${project_name}.bd]
make_wrapper -files $bd_file -top
add_files -norecurse [file join [file dirname $bd_file] hdl/${project_name}_wrapper.v]
set_property synth_checkpoint_mode Singular $bd_file
generate_target all $bd_file

puts "INFO: Project created:$project_name"
puts "INFO: Packaging PE IP"
source common/package.tcl

exit
