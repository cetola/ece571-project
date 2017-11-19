Agashe - Cetola - Wiese
ECE 571 Final Project

SD Card Emulation with with NAND storage.

DIRECTORIES
setup - veloce config, makefile, and simulation scripts
hdl - synthesizable design files
hvl - testbench files

SETUP INSTRUCTIONS

TESTING NAND ON QUESTA SIM
mkdir nand-con
cp hdl/nand/* nand-con/
cp hvl/nand/* nand-con/
cp setup/* nand-con/
cd nand-con
make lib
make build
make nand-run
