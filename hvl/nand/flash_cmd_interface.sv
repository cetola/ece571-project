// Module: flash_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash command interface

interface flash_cmd_interface(
  input logic clk
);

logic [2:0] cmd = 3'b111;  // -- command, see below
logic start = 1'b0;        //  -- pos edge (pulse) to start
logic done;                //  -- operation finished if '1'
logic [15:0] RWA = 16'b0;  //-- row addr

//-- NFC commands (all remaining encodings are ignored = NOP):
//-- WPA 001=write page
//-- RPA 010=read page
//-- EBL 100=erase block
//-- RET 011=reset
//-- RID 101= read ID

modport master (
  input clk,
  output cmd,
  output start,
  input done,
  output RWA
  );

modport slave (
  input clk,
  input cmd,
  input start,
  output done,
  input RWA
  );
endinterface
