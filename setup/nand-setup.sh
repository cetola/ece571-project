#!/bin/bash
#Authors:
#Stpehano Cetola

##Setup script for testing NAND using vsim & vlog.
##Run this script from the root project directory.

#Create test dir and move files there
mkdir nand-con
cp hdl/nand/* nand-con/
cp hvl/nand/* nand-con/
cp setup/* nand-con/

#CD into nand-con and setup git for change tracking.
#cd nand-con
#git init
#git add --all
#git commit -m "init"
