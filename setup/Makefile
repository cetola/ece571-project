# File: Makefile
# Authors:
# Stephano Cetola

# Options are puresim and veloce
MODE ?= puresim

# Options: all nand spi sd
MODULES ?= all

all: lib build run

lib:

	@echo "Running vlib in mode $(MODE)"
	vlib work.$(MODE)
	vmap work work.$(MODE)

build:

	@echo "Running vlog for modules: $(MODULES)"
ifeq ($(MODULES),all)
	#ALL	
	vlog definitions.sv
	vlog top_hvl.sv
else ifeq ($(MODULES),nand)
	#NAND Flash
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

	velhvl -sim $(MODE)
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

endif

run:

	vsim -c -do top.do top_hvl top_hdl

run-nand:

	vsim -c -do nand.do top_nand_hvl top_nand_hdl

clean:
	rm -rf modelsim.ini work work.puresim work.veloce transcript veloce.log veloce.map veloce.med velrunopts.ini tbxbindings.h
