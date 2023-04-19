SILENTCMD=
ifndef VERBOSE
SILENTCMD=@
endif

SHELL=/bin/bash
BRAM_SIZE?=0x4000
PYNQ=xc7z020clg400-1
XLEN?=32
CACHE?=false
MAXI?=1

ifndef TAPASCO_HOME
$(error TAPASCO_HOME is not set, make sure to source setup.sh in TaPaSCo dir)
endif

ifndef XILINX_VIVADO
$(error XILINX_VIVADO is not set, make sure that Vivado is setup correctly)
endif

null :=
space := $(null) #
comma := ,
CORE_LIST=$(patsubst riscv/%,%,$(wildcard riscv/*))
PE_LIST=$(addsuffix _pe, $(CORE_LIST))
PE_LIST_SEPARATED=$(subst $(space),$(comma),$(strip $(PE_LIST)))

all: $(PE_LIST)

list:
	@echo $(CORE_LIST)

%_pe: %_setup
	vivado -nolog -nojournal -mode batch -source riscv_pe_project.tcl -tclargs --part $(PYNQ) --bram $(BRAM_SIZE) --cache $(CACHE) --maxi $(MAXI) --project_name $@
	$(SILENTCMD)PE_ID=$$(($$(echo $(PE_LIST) | sed s/$@.*// | wc -w) + 1742)); \
	tapasco -v import IP/$@/esa.informatik.tu-darmstadt.de_tapasco_$@_1.0.zip as $${PE_ID} --skipEvaluation

%_setup: riscv/%/setup.sh
	$<

uninstall:
	$(SILENTCMD)rm -rf $(TAPASCO_WORK_DIR)/core/{${PE_LIST_SEPARATED}}*

clean: uninstall
	$(SILENTCMD)rm -rf IP/{${PE_LIST_SEPARATED},riscv}
	$(SILENTCMD)rm -rf Orca dummy* ${PE_LIST} package_picorv32
	$(SILENTCMD)rm -rf riscv/flute32/{Flute,*RV*}
	$(SILENTCMD)rm -rf riscv/piccolo32/{Piccolo,*RV*}
	$(SILENTCMD)rm -rf riscv/picorv32/picorv32
	$(SILENTCMD)rm -rf riscv/scr1/scr1
	$(SILENTCMD)rm -rf riscv/swerv/{swerv_eh1,wdc_risc-v_swerv_eh1.zip}
	$(SILENTCMD)rm -rf riscv/swerv_eh2/{swerv_eh2,wdc_risc-v_swerv_eh2.zip,.Xil,component.xml}
	$(SILENTCMD)rm -rf riscv/swerv_eh2/Cores-SweRV-EH2/snapshots
	$(SILENTCMD)rm -rf riscv/cva5/{cva5,openhwgroup_risc-v_cva5.zip}
	$(SILENTCMD)rm -rf riscv/vexriscv/{SpinalHDL,VexRiscv}
	$(SILENTCMD)rm -rf riscv/cva6/cva6
