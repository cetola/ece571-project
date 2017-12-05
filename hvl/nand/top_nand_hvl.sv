// Module: top_nand_hvl.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Provides top-level (NAND) HVL code which runs on the Co-Model Server.
// Using Testbench Xpress (TBX) connection to Veloce, it employs the Bus
// Functional Model (BFM) method, calling into tasks in top_nand_hdl.
//TODO: rand data from readmemh

module top_nand_hvl;

import FlashData::*;

parameter NUMTEST = 10;

integer log = 1;
int errs = 0;
int tests = 0;
FlashRD rd;

  initial begin
  assert ((log = $fopen("nand.log")) != 0) else $error("%m can't open file nand.log.");

  $fwrite(log,"NAND Begin:\n\n");
  rd = new();
  top_nand_hdl.tbi.reset_wait();

//----------RANDOM
  for(int i=0; i<NUMTEST-7; i++)
    begin
    assert (rd.randomize()) else $fatal(0, "FlashRD::randomize failed");
    testData(rd);
    end

//----------EDGE CASES
//----------------------MAX ADDR
    rd.setMaxAddr();
    testData(rd);
//----------------------MIN ADDR
    rd.setMinAddr();
    testData(rd);
//----------------------ALT ADDR
    rd.setAltAddr();
    testData(rd);

//----------INJECT ERRORS
//----------------------PROTOCOL VIOLATION
    tests++;
    assert (rd.randomize()) else $fatal(0, "FlashRD::randomize failed");
    $display("Test:%d\t addr:%h", tests, rd.getAddress());
    top_nand_hdl.tbi.proto_error(rd.getAddress(), rd.getHexFile());
    assert (top_nand_hdl.PErr) else $error("%m Should have seen a write error");
    //should work as before without errors
    assert (rd.randomize()) else $fatal(0, "FlashRD::randomize failed");
    testData(rd);
//----------------------ECC ERROR
//force an ECC error
    tests++;
    assert (rd.randomize()) else $fatal(0, "FlashRD::randomize failed");
    $display("Test:%d\t addr:%h", tests, rd.getAddress());
    top_nand_hdl.tbi.ecc_error(rd.getAddress());
    assert (top_nand_hdl.RErr) else $error("%m Should have seen a Read error");
    //should work as before without errors
    assert (rd.randomize()) else $fatal(0, "FlashRD::randomize failed");
    testData(rd);
//TODO: check that ECC corrects the data by injecting errors into the datastream


  $fwrite(log, "There were %4d errors found.\n\n", errs);
  $fwrite(log, "Ran %4d tests.\n\n", tests);
  $fwrite(log, "NAND Finish");
  $fclose(log);
  $finish;

  end

  task testData;
    input FlashRD rd;
    begin
    tests++;
    $display("Test:%d\t addr:%h", tests, rd.getAddress());
    //-----------------RESET
    top_nand_hdl.tbi.reset_cycle();

    //-----------------ERASE
    top_nand_hdl.tbi.erase_cycle(rd.getAddress());
    assert (!top_nand_hdl.EErr) else $error("%m Erase error");

    //-----------------WRITE
    top_nand_hdl.tbi.write_cycle(rd.getAddress(), rd.getHexFile());
    assert (!top_nand_hdl.PErr) else $error("%m Write error");

    //-----------------READ
    top_nand_hdl.tbi.read_cycle(rd.getAddress());
    assert (!top_nand_hdl.RErr) else $error("%m ECC error");
    top_nand_hdl.tbi.read_id_cycle(rd.getAddress());
    end
  endtask

endmodule
