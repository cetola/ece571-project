// Module: flash_tb.sv
// Based on nfcm_tb.v from Lattice Semiconductor
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash test bench

`timescale 1 ns / 1 fs

module flash_tb();

 logic clk,rst;

 wire [7:0] DIO;
 wire CLE, ALE, WE_n, RE_n, CE_n, R_nB;

 wire PErr ; // -- progr err
 wire EErr ; // -- erase err
 wire RErr ;

logic [7:0] temp;
//TODO: BRAM
parameter period=16;         // suppose 60MHz

//-------------------------------Interfaces
flash_cmd_interface fc(
  .clk(clk)
  );

buffer_interface buff();

flash_tb_interface tbi(fc.master, buff.writer);

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

flash_datastore ds(nand_flash);

// Instantiation of the nfcm
nfcm_top nfcm(
 .fi(nand_flash),

 .buff(buff.reader),

 .PErr(PErr),
 .EErr(EErr),
 .RErr(RErr),

 .fc(fc.slave)
);

initial begin
  $display("fingers crossed");
  clk <= 1'b0;
  rst  <= 1'b1;

  temp<=8'h24;
  #300;
  rst<=1'b0;

  tbi.reset_cycle();
  tbi.erase_cycle(16'h1234);
  tbi.write_cycle(16'h1234);
  //read_cycle(16'h1234);
  //read_id_cycle(16'h0000);

  #1000;
  $stop;
end

always
   #(period/2) clk <= ~clk;

endmodule
