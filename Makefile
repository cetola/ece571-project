## File: Makefile
## Authors:
## Stephano Cetola <cetola@pdx.edu>
##

all: work build run

work:
	vlib work

build:
	vlog definitions.sv
	vlog top_hvl.sv

run:
	vsim -c top_hvl

