# File: Makefile
# Authors:
# Stephano Cetola

MODE ?= puresim

all: lib build run

lib:
	vlib work.$(MODE)
	vmap work work.$(MODE)

build:
	vlog definitions.sv
	vlog top_hvl.sv

	#NAND Flash
	vlog flash_interface.sv

ifeq ($(MODE),puresim)
	#NAND Flash
	vlog ACounter.v
	vlog ErrLoc.v
	vlog H_gen.v
	vlog MFSM.v
	vlog nfcm_top.v
	vlog TFSM.v
	vlog flash_tb.sv


else
	velanalyze Acounter.v
	velanalyze ErrLoc.v
	velanalyze H_gen.v
	velanalyze MFSM.v
	velanalyze nfcm_top.v
	velanalyze TFSM.v

	velcomp -top top_hdl

	velhvl -sim $(MODE)

endif

run:

	vsim -c -do top.do top_hvl top_hdl

nand-run:

	vsim -c -do nand.do nand_tb

clean:
	rm -rf modelsim.ini work work.puresim work.veloce transcript
