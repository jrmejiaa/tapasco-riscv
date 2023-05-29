# Create instance: VexRiscvAxi4_0, and set properties
set picorv32_0 [ create_bd_cell -type ip -vlnv [dict get $cpu_vlnv $project_name] picorv32_0 ]
set cpu_clk [get_bd_pins picorv32_0/clk]
set_property -dict [list CONFIG.BARREL_SHIFTER {1} CONFIG.ENABLE_FAST_MUL {1} CONFIG.ENABLE_DIV {1} CONFIG.PROGADDR_IRQ {0x00100000} CONFIG.STACKADDR [expr {$lmem * 2}]] [get_bd_cells picorv32_0]

set_property -dict [ list \
  CONFIG.SUPPORTS_NARROW_BURST {0} \
  CONFIG.NUM_READ_OUTSTANDING {1} \
  CONFIG.NUM_WRITE_OUTSTANDING {1} \
  CONFIG.MAX_BURST_LENGTH {1} \
  ] [get_bd_intf_pins /picorv32_0/mem_axi]

if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
  # Create instance: axi_lite2full, and set properties (maximize performance)
  set axi_lite2full [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_lite2full ]
  
  set_property -dict [ list \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {1} \
    CONFIG.STRATEGY {0} \
    CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
    CONFIG.S00_HAS_DATA_FIFO {0} \
    ] $axi_lite2full

  # Create interface connections
  connect_bd_intf_net -intf_net picorv32_0_lite2full [get_bd_intf_pins picorv32_0/mem_axi] [get_bd_intf_pins axi_lite2full/S00_AXI]
  connect_bd_intf_net -intf_net picorv32_0_mem_axi [get_bd_intf_pins axi_lite2full/M00_AXI] [get_bd_intf_pins cache_system_0/core_mem]
  connect_bd_intf_net -intf_net cache_system_0_mem [get_bd_intf_pins axi_mem_intercon_1/S00_AXI] [get_bd_intf_pins cache_system_0/mem]
} else {
  # PicoRV32 only has one AXI master port, attach both memories to axi_mem_intercon_1
  connect_bd_intf_net [get_bd_intf_pins picorv32_0/mem_axi] [get_bd_intf_pins axi_mem_intercon_1/S00_AXI]
}

# Create port connections
connect_bd_net -net RVController_0_rv_rstn [get_bd_pins RVController_0/rv_rstn] [get_bd_pins picorv32_0/resetn]

save_bd_design

if {!$set_ddr_memory} {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/mem]
    }
  } else {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs rv_dmem_ctrl/S_AXI/Mem0] SEG_rv_dmem_ctrl_Mem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs rv_imem_ctrl/S_AXI/Mem0] SEG_rv_imem_ctrl_Mem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces picorv32_0/mem_axi]
    }
  }
} else {
  if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces cache_system_0/mem] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces cache_system_0/mem]
    }
  } else {
    proc create_specific_addr_segs {} {
      variable lmem
      # Create address segments
      create_bd_addr_seg -range 0x00010000 -offset 0x11000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs RVController_0/saxi/reg0] SEG_RVController_0_reg0
      create_bd_addr_seg -range $lmem -offset $lmem [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs M_AXI/Reg] M_AXI_DMem0
      create_bd_addr_seg -range $lmem -offset 0x00000000 [get_bd_addr_spaces picorv32_0/mem_axi] [get_bd_addr_segs M_AXI/Reg] M_AXI_IMem0
    }

    proc get_external_mem_addr_space {} {
      return [get_bd_addr_spaces picorv32_0/mem_axi]
    }
  }
}