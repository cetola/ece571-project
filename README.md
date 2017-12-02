# SD/SDHC Card Emulator
Agashe - Cetola - Wiese
ECE 571 Final Project

SD Card Emulation with NAND storage.

### Directories  
setup - veloce config, makefile, and simulation scripts  
hdl - synthesizable design files  
hvl - testbench files  
origionals - unmodified files used for reference

### Setup Instructions
Assumes you are in the root directory.

#### Testing NAND on Questa Sim
```bash
./setup/nand-setup.sh  
cd nand-con  
make MODULES=nand lib  
make MODULES=nand build  
make nand-run  
```

#### Testing SD on Questa Sim
```bash
./setup/sd-setup.sh  
cd sd-con/sim/rtl_sim/run/  
vsim -do comp.do  
```

#### Testing SPI on Questa Sim
```bash
./setup/spi-setup.sh  
cd spi-con  
vlib work  
vlog *.sv
vsim top -do spi.do
```
