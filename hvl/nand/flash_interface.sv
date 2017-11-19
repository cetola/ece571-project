// Module: flash_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash interface

interface flash_interface(
  inout [7:0] DIO, //data input / output
  input CLE,       //command latch
  input ALE,       //address latch
  input WE_n,      //write enable
  input RE_n,      //read enable
  input CE_n,      //chip enable
  output reg R_nB, //flash ready, "not busy"
  input rst       //reset
);
endinterface
