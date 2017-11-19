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
	vlog flash_interface.sv
ifeq ($(MODE),puresim)
	vlog ACounter.v
	vlog ErrLoc.v
	vlog H_gen.v
	vlog MFSM.v
	vlog nfcm_top.v
	vlog TFSM.v
	vlog flash_tb.sv
else
	velanalyze ACounter.v
	velanalyze ErrLoc.v
	velanalyze H_gen.v
	velanalyze MFSM.v
	velanalyze nfcm_top.v
	velanalyze TFSM.v

	velcomp -top nfcm_top

	velhvl -sim $(MODE)
endif

endif

run:

	vsim -c -do top.do top_hvl top_hdl

run-nand:

	vsim -c -do nand.do nfcm_tb

clean:
	rm -rf modelsim.ini work work.puresim work.veloce transcript veloce.log veloce.map veloce.med velrunopts.ini tbxbindings.h
