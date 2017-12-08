# File: Makefile
# Authors:
# Stephano Cetola

# Options are puresim and veloce
MODE ?= puresim

all: lib build run

lib:

	@echo "Running vlib in mode $(MODE)"
	vlib work.$(MODE)
	vmap work work.$(MODE)

build:

	vlog FlashData.sv
	vlog top_nand_hvl.sv

ifeq ($(MODE),puresim)
	vlog ACounter.v
	vlog ErrLoc.v
	vlog H_gen.v
	vlog MFSM.v
	vlog nfcm_top.sv
	vlog TFSM.v
	vlog flash_interface.sv
	vlog flash_datastore.sv
	vlog flash_cmd_interface.sv
	vlog flash_tb_interface.sv
	vlog buffer_interface.sv

	vlog top_nand_hdl.sv

	#velhvl -sim $(MODE)
else
	velanalyze -extract_hvl_info +define+QUESTA top_nand_hvl.sv

	velanalyze flash_interface.sv
	velanalyze flash_datastore.sv
	velanalyze flash_cmd_interface.sv
	velanalyze flash_tb_interface.sv
	velanalyze buffer_interface.sv

	velanalyze ACounter.v
	velanalyze ErrLoc.v
	velanalyze H_gen.v
	velanalyze MFSM.v
	velanalyze nfcm_top.sv
	velanalyze TFSM.v

	velanalyze top_nand_hdl.sv

	velcomp  -top top_nand_hdl

	velhvl -sim $(MODE)
endif

run:

	vsim -c -do nand.do -sv_seed 1234 top_nand_hvl top_nand_hdl

run-inject-err:

	vsim -c -do nand.do -sv_seed 1234 +INJECTERR top_nand_hvl top_nand_hdl

clean:
	rm -rf modelsim.ini work work.puresim work.veloce transcript veloce.log veloce.map veloce.med velrunopts.ini tbxbindings.h nand.hex nand.log
