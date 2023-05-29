# Create instance: axi_mem_intercon_1, and set properties (maximize performance)
set axi_mem_intercon_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon_1 ]
# reduce NUM_MI later for direct bram connection
set_property -dict [ list \
  CONFIG.NUM_MI {3} \
  CONFIG.NUM_SI {1} \
  CONFIG.STRATEGY {0} \
  CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
  CONFIG.S00_HAS_DATA_FIFO {0} \
  ] $axi_mem_intercon_1

# Create instance: rst_CLK_100M, and set properties
set rst_CLK_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_CLK_100M ]

if {!$set_ddr_memory} {
  # Create instance: axi_interconnect_1, and set properties (minimize area)
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property CONFIG.STRATEGY {1} $axi_interconnect_1

  # Create instance: dmem, and set properties
  set dmem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 dmem ]
  set_property -dict [ list \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.EN_SAFETY_CKT {false} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Use_RSTB_Pin {true} \
    ] $dmem

  # Create instance: imem, and set properties
  set imem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 imem ]
  set_property -dict [ list \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.EN_SAFETY_CKT {false} \
    CONFIG.Enable_B {Use_ENB_Pin} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Port_B_Clock {100} \
    CONFIG.Port_B_Enable_Rate {100} \
    CONFIG.Port_B_Write_Rate {50} \
    CONFIG.Use_RSTB_Pin {true} \
    ] $imem

  # Create instance: ps_dmem_ctrl, and set properties
  set ps_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl ps_dmem_ctrl ]
  set_property -dict [ list \
    CONFIG.SINGLE_PORT_BRAM {1} \
    ] $ps_dmem_ctrl

  # Create instance: ps_imem_ctrl, and set properties
  set ps_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl ps_imem_ctrl ]
  set_property -dict [ list \
    CONFIG.SINGLE_PORT_BRAM {1} \
    ] $ps_imem_ctrl

  # Create instance: rv_dmem_ctrl, and set properties
  set rv_dmem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl rv_dmem_ctrl ]
  set_property -dict [ list \
    CONFIG.SINGLE_PORT_BRAM {1} \
    ] $rv_dmem_ctrl

  # Create instance: rv_imem_ctrl, and set properties
  set rv_imem_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl rv_imem_ctrl ]
  set_property -dict [ list \
    CONFIG.SINGLE_PORT_BRAM {1} \
    ] $rv_imem_ctrl
  } else { # Set DDR Memory as memory for RISC-V cores
    if {[dict get $is_harvard_arch $project_name]} {
    # Create instance to merge harvard outputs: axi_merge_interconnect_1, and set properties (maximize performance)
    set axi_merge_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_merge_interconnect_1 ]

    set_property -dict [ list \
      CONFIG.NUM_MI {1} \
      CONFIG.NUM_SI {2} \
      CONFIG.STRATEGY {0} \
      CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
      CONFIG.S00_HAS_DATA_FIFO {0} \
      ] $axi_merge_interconnect_1
  }
}

if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
  # Create instance: cache_system and set basic connections and properties
  set cache_system_0 [ create_bd_cell -type ip -vlnv esa.informatik.tu-darmstadt.de:user:CacheSystem:1.0 cache_system_0 ]

  if {[dict get $is_harvard_arch $project_name]} {
    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/dmem]

    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/imem]

    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/core_dmem]

    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/core_imem]
  } else {
    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/mem]

    set_property -dict [ list \
      CONFIG.SUPPORTS_NARROW_BURST {0} \
      CONFIG.NUM_READ_OUTSTANDING {1} \
      CONFIG.NUM_WRITE_OUTSTANDING {1} \
      CONFIG.MAX_BURST_LENGTH {1} \
      ] [get_bd_intf_pins /cache_system_0/core_mem]
  }
}