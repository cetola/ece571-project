// Module: top_nand_hdl.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// clk - global clock signal
// rst - active low NAND async reset
//
// Provides top-level (at least for NAND) HDL code to run on Veloce, so it
// should only contain sythesizable stuff. (TBD)

`timescale 1 ns / 1 ps

module top_nand_hdl(); //pragma attribute top_hdl parition_module_xrtl

 logic clk,rst;

 wire [7:0] DIO;
 wire CLE, ALE, WE_n, RE_n, CE_n, R_nB;

 wire PErr ; // -- progr err
 wire EErr ; // -- erase err
 wire RErr ;

parameter period=16;         // 60MHz

/************************************************************************/
/* MODULES */
/************************************************************************/

flash_cmd_interface fc(.clk(clk));

buffer_interface buff();

flash_interface nand_flash(
  .DIO(DIO),
  .CLE(CLE),
  .ALE(ALE),
  .WE_n(WE_n),
  .RE_n(RE_n),
  .CE_n(CE_n),
  .R_nB(R_nB),
  .rst(rst)
);

flash_tb_interface tbi(fc.master, buff.writer, nand_flash);

flash_datastore ds(nand_flash);

nfcm_top nfcm(
  .fi(nand_flash),
  .buff(buff.reader),
  .fc(fc.slave),
  .PErr(PErr),
  .EErr(EErr),
  .RErr(RErr)
);

// TBX clkgen
initial begin
  clk = 1'b0;
  forever #(period/2) clk = ~clk;
end

initial begin
  rst  <= 1'b1;
  #3;
  rst<=1'b0;
end

endmodule
