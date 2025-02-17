# Create instance: VexRiscvAxi4_0, and set properties
set VexRiscvAxi4_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] VexRiscvAxi4_0 ]
set cpu_clk [get_bd_pins VexRiscvAxi4_0/clk]
set_property -dict [ list \
  CONFIG.SUPPORTS_NARROW_BURST {1} \
  CONFIG.NUM_READ_OUTSTANDING {2} \
  CONFIG.NUM_WRITE_OUTSTANDING {2} \
  CONFIG.MAX_BURST_LENGTH {256} \
  ] [get_bd_intf_pins /VexRiscvAxi4_0/dBusAxi]

set_property -dict [ list \
  CONFIG.SUPPORTS_NARROW_BURST {1} \
  CONFIG.NUM_READ_OUTSTANDING {2} \
  CONFIG.NUM_WRITE_OUTSTANDING {2} \
  CONFIG.MAX_BURST_LENGTH {256} \
  ] [get_bd_intf_pins /VexRiscvAxi4_0/iBusAxi]


if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
  # Create interface connections
  connect_bd_intf_net -intf_net VexRiscvAxi4_0_dBusAxi [get_bd_intf_pins VexRiscvAxi4_0/dBusAxi] [get_bd_intf_pins cache_system_0/core_dmem]
  connect_bd_intf_net -intf_net piccolo_0_cpu_imem_master [get_bd_intf_pins VexRiscvAxi4_0/iBusAxi] [get_bd_intf_pins cache_system_0/core_imem]

  connect_bd_intf_net -intf_net cache_system_0_dmem_master [get_bd_intf_pins cache_system_0/dmem] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  set iaxi [get_bd_intf_pins cache_system_0/imem]
} else {
  # Create interface connections
  connect_bd_intf_net -intf_net VexRiscvAxi4_0_dBusAxi [get_bd_intf_pins VexRiscvAxi4_0/dBusAxi] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
  set iaxi [get_bd_intf_pins VexRiscvAxi4_0/iBusAxi]
}

# Create port connections
connect_bd_net -net RVController_0_rv_reset [get_bd_pins RVController_0/rv_reset] [get_bd_pins VexRiscvAxi4_0/reset]
save_bd_design

if {!$set_ddr_memory} {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/imem] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/dmem]
    }
  } else {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces VexRiscvAxi4_0/iBusAxi] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi]
    }
  }
} else {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/dmem] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/imem] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/dmem]
    }
  } else {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces VexRiscvAxi4_0/iBusAxi] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces VexRiscvAxi4_0/dBusAxi]
    }
  }
}