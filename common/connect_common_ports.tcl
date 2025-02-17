# Connections for clocks, local memory and everything that's independent from the processor
connect_bd_net -net ARESET_N_1 [get_bd_ports ARESET_N] [get_bd_pins rst_CLK_100M/ext_reset_in]
connect_bd_net -net CLK_1 [get_bd_ports CLK] [get_bd_pins AXIGate_0/CLK] [get_bd_pins RVController_0/CLK] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_mem_intercon_1/ACLK] [get_bd_pins axi_mem_intercon_1/M0*_ACLK] [get_bd_pins axi_mem_intercon_1/S0*_ACLK] [get_bd_pins dmaOffset/CLK] $cpu_clk [get_bd_pins ps_dmem_ctrl/s_axi_aclk] [get_bd_pins ps_imem_ctrl/s_axi_aclk] [get_bd_pins rst_CLK_100M/slowest_sync_clk] [get_bd_pins rv_dmem_ctrl/s_axi_aclk] [get_bd_pins rv_imem_ctrl/s_axi_aclk]
connect_bd_net -net RVController_0_tapasco_intr [get_bd_ports interrupt] [get_bd_pins RVController_0/tapasco_intr]
connect_bd_net -net rst_CLK_100M_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_mem_intercon_1/ARESETN] [get_bd_pins rst_CLK_100M/interconnect_aresetn]
connect_bd_net -net rst_CLK_100M_peripheral_aresetn [get_bd_pins AXIGate_0/RST_N] [get_bd_pins RVController_0/RST_N] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_mem_intercon_1/M00_ARESETN] [get_bd_pins axi_mem_intercon_1/M0*_ARESETN] [get_bd_pins axi_mem_intercon_1/S0*_ARESETN] [get_bd_pins dmaOffset/RST_N] [get_bd_pins ps_dmem_ctrl/s_axi_aresetn] [get_bd_pins ps_imem_ctrl/s_axi_aresetn] [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins rv_dmem_ctrl/s_axi_aresetn] [get_bd_pins rv_imem_ctrl/s_axi_aresetn]

if {$maxi_ports == 2} {
  connect_bd_net -net CLK_1 [get_bd_pins dmaOffset2/CLK]
  connect_bd_net -net rst_CLK_100M_peripheral_aresetn [get_bd_pins dmaOffset2/RST_N]
}

if {($set_ddr_memory && [info exists iaxi]) || ($set_ddr_memory && $project_name eq "cva6_pe")} {
  connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_merge_interconnect_1/ACLK] [get_bd_pins axi_merge_interconnect_1/S00_ACLK] [get_bd_pins axi_merge_interconnect_1/M00_ACLK] [get_bd_pins axi_merge_interconnect_1/S01_ACLK]
  connect_bd_net [get_bd_pins rst_CLK_100M/interconnect_aresetn] [get_bd_pins axi_merge_interconnect_1/ARESETN] [get_bd_pins axi_merge_interconnect_1/S00_ARESETN] [get_bd_pins axi_merge_interconnect_1/M00_ARESETN] [get_bd_pins axi_merge_interconnect_1/S01_ARESETN]
}

if { $set_cache_sys && [dict get $is_cache_available $project_name] } {
  connect_bd_net -net CLK_1 [get_bd_pins cache_system_0/CLK]
  connect_bd_net [get_bd_pins RVController_0/rv_rstn] [get_bd_pins cache_system_0/RST_N]
  if {![dict get $is_harvard_arch $project_name]} {
    connect_bd_net [get_bd_ports CLK] [get_bd_pins axi_lite2full/ACLK] [get_bd_pins axi_lite2full/S00_ACLK] [get_bd_pins axi_lite2full/M00_ACLK]
    connect_bd_net [get_bd_pins rst_CLK_100M/peripheral_aresetn] [get_bd_pins axi_lite2full/ARESETN] [get_bd_pins axi_lite2full/S00_ARESETN] [get_bd_pins axi_lite2full/M00_ARESETN]
  }
}
