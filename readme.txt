Agashe - Cetola - Wiese
ECE 571 Final Project

SD Card Emulation with NAND storage.

### DIRECTORIES
setup - veloce config, makefile, and simulation scripts
hdl - synthesizable design files
hvl - testbench files
originals - unmodified files used for reference

### Setup Instructions
Assumes you are in the root directory.

#### Testing NAND on Questa Sim
./setup/nand-setup.sh
cd nand-con
make all
##This injects errors, so expect to see assertion failures
make run-inject-err

#### Testing SD on Questa Sim
./setup/sd-setup.sh
cd sd-con/sim/rtl_sim/run/
vsim -do comp.do
##This integrates SV code into the original design. sdModel.sv and sd_controller_top_tb.sv were modified from existing 
Verilog files (added assertions, enumerated datatypes, final block, warning and error messages, structures).
SDInterfaces.sv was added to act as an interface between sdModel.sv and sd_controller_top_tb.sv.

#### Testing SPI on Questa Sim
./setup/spi-setup.sh
cd spi-con
vlib work
vlog *.sv
vsim top -do spi.do
