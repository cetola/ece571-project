Agashe - Cetola - Wiese
ECE 571 Final Project

SD Card Emulation with NAND storage.

### DIRECTORIES
setup - veloce config, makefile, and simulation scripts
hdl - synthesizable design files
hvl - testbench files
origionals - unmodified files used for reference

### Setup Instructions
Assumes you are in the root directory.

#### Testing NAND on Questa Sim
./setup/nand-setup.sh
cd nand-con
make all

#### Testing SD on Questa Sim
./setup/sd-setup.sh
cd sd-con/sim/rtl_sim/run/
vsim -do comp.do

#### Testing SPI on Questa Sim
./setup/spi-setup.sh
cd spi-con
vlib work
vlog *.sv
vsim top -do spi.do
