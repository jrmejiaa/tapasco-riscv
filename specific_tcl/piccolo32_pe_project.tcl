# Create instance: piccolo_0, and set properties
set piccolo_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] piccolo_0 ]
set cpu_clk [get_bd_pins piccolo_0/CLK]
set_property -dict [ list \
  CONFIG.SUPPORTS_NARROW_BURST {0} \
  CONFIG.NUM_READ_OUTSTANDING {1} \
  CONFIG.NUM_WRITE_OUTSTANDING {1} \
  CONFIG.MAX_BURST_LENGTH {1} \
  ] [get_bd_intf_pins /piccolo_0/cpu_dmem_master]

set_property -dict [ list \
  CONFIG.SUPPORTS_NARROW_BURST {0} \
  CONFIG.NUM_READ_OUTSTANDING {1} \
  CONFIG.NUM_WRITE_OUTSTANDING {1} \
  CONFIG.MAX_BURST_LENGTH {1} \
  ] [get_bd_intf_pins /piccolo_0/cpu_imem_master]

if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
  # Create interface connections
  connect_bd_intf_net -intf_net piccolo_0_cpu_dmem_master [get_bd_intf_pins cache_system_0/core_dmem] [get_bd_intf_pins piccolo_0/cpu_dmem_master]
  connect_bd_intf_net -intf_net piccolo_0_cpu_imem_master [get_bd_intf_pins cache_system_0/core_imem] [get_bd_intf_pins piccolo_0/cpu_imem_master]
  connect_bd_intf_net -intf_net cache_system_0_dmem_master [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins cache_system_0/dmem]
  set iaxi [get_bd_intf_pins cache_system_0/imem]
} else {
  # Create interface connections
  connect_bd_intf_net -intf_net piccolo_0_cpu_dmem_master [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins piccolo_0/cpu_dmem_master]
  set iaxi [get_bd_intf_pins piccolo_0/cpu_imem_master]
}

# Create port connections
connect_bd_net -net RVController_0_reqEN [get_bd_pins RVController_0/reqEN] [get_bd_pins piccolo_0/EN_cpu_reset_server_request_put]
connect_bd_net -net RVController_0_resEN [get_bd_pins RVController_0/resEN] [get_bd_pins piccolo_0/EN_cpu_reset_server_response_get]
connect_bd_net -net RVController_0_rv_rstn [get_bd_pins RVController_0/rv_rstn] [get_bd_pins piccolo_0/RST_N]
connect_bd_net -net piccolo_0_RDY_cpu_reset_server_request_put [get_bd_pins RVController_0/reqRDY_req_rdy] [get_bd_pins piccolo_0/RDY_cpu_reset_server_request_put]
connect_bd_net -net piccolo_0_RDY_cpu_reset_server_response_get [get_bd_pins RVController_0/resRDY_res_rdy] [get_bd_pins piccolo_0/RDY_cpu_reset_server_response_get]

# Get IP definition of DMI
set tapasco_toolflow $::env(TAPASCO_HOME_TOOLFLOW)
set_property ip_repo_paths [concat [get_property ip_repo_paths [current_project]] $tapasco_toolflow/vivado/common/ip/DMI/] [current_project]
update_ip_catalog

# Connect DMI port to the outside
create_bd_intf_port -mode Slave -vlnv esa.informatik.tu-darmstadt.de:user:DMI_rtl:1.0 DMI
connect_bd_intf_net [get_bd_intf_ports DMI] [get_bd_intf_pins piccolo_0/DMI]

if {!$set_ddr_memory} {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create specific address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/imem] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/dmem]
    }
  } else { # Not cache create address segments for only the core
    proc create_specific_addr_segs {} {
      variable lmem
      # Create specific address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces piccolo_0/cpu_dmem_master] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces piccolo_0/cpu_dmem_master] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces piccolo_0/cpu_imem_master] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces piccolo_0/cpu_dmem_master]
    }
  }
} else {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create specific address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/imem] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/dmem]
    }
  } else { # Not cache create address segments for only the core
    proc create_specific_addr_segs {} {
      variable lmem
      # Create specific address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces piccolo_0/cpu_dmem_master] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces piccolo_0/cpu_dmem_master] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces piccolo_0/cpu_imem_master] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces piccolo_0/cpu_dmem_master]
    }
  }
}