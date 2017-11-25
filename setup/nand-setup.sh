#!/bin/bash
mkdir nand-con
cp hdl/nand/* nand-con/
cp hvl/nand/* nand-con/
cp setup/* nand-con/
cd nand-con
git init
git add --all
git commit -m "init"
