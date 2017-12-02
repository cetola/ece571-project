// Module: top_nand_hvl.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Provides top-level (NAND) HVL code which runs on the Co-Model Server.
// Using Testbench Xpress (TBX) connection to Veloce, it employs the Bus
// Functional Model (BFM) method, calling into tasks in top_nand_hdl.

module top_nand_hvl;

import FlashData::*;

integer log = 1;
int errs = 0;
FlashRD rd;

  initial begin
  assert ((log = $fopen("nand.log")) != 0) else $error("%m can't open file nand.log.");

  $fwrite(log,"NAND Begin:\n\n");
  rd = new();
  assert (rd.randomize())
  else $fatal(0, "FlashRD::randomize failed");
  $display("wait for reset");
  top_nand_hdl.tbi.reset_wait();
  $display("reset cycle");
  top_nand_hdl.tbi.reset_cycle();
  $display("erase cycle: %h", rd.getAddress());
  top_nand_hdl.tbi.erase_cycle(rd.getAddress());
  assert (!top_nand_hdl.EErr) else $error("%m Erase error");
  $display("write cycle");
  top_nand_hdl.tbi.write_cycle(16'h1234, $random % 256);
  assert (!top_nand_hdl.PErr) else $error("%m Write error");
  $display("read mem cycle");
  top_nand_hdl.tbi.read_cycle(16'h1234);
  assert (!top_nand_hdl.RErr) else $error("%m ECC error");
  $display("read ID cycle");
  top_nand_hdl.tbi.read_id_cycle(16'h0000);


  $fwrite(log, "There were %4d errors found.\n\n", errs);
  $fwrite(log, "NAND Finish");
  $fclose(log);
  $finish;

  end

endmodule
