#!/bin/bash
#Authors:
#Stpehano Cetola

##Setup script for testing SD using ModelSim.
##Run this script from the root project directory.

#Create test dir, setup origional app, then overlay changes
mkdir sd-con
cp -r originals/OpenCoresSDCard/* sd-con/
cp -r hdl/sdc/* sd-con/bench/sdc_dma/verilog/
cp setup/comp.do sd-con/sim/rtl_sim/run/
mkdir sd-con/sim/rtl_sim/log
chmod -R a+r sd-con

#CD into nand-con and setup git for change tracking.
cd sd-con
git init
git add --all
git commit -m "init"
