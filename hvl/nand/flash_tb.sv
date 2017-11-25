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

 logic BF_sel, BF_we;
 logic [10:0] BF_ad;
 logic [7:0] BF_din;
 wire [7:0] BF_dou;

 wire PErr ; // -- progr err
 wire EErr ; // -- erase err
 wire RErr ;

logic [0:2047][7:0] memory;
logic [7:0] temp;
//TODO: BRAM
parameter period=16;         // suppose 60MHz

//-------------------------------Interfaces
flash_cmd_interface fc(
  .clk(clk)
  );

flash_tb_interface tbi(fc.master);

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

 .BF_sel(BF_sel),
 .BF_ad (BF_ad ),
 .BF_din(BF_din),
 .BF_we (BF_we ),

 .BF_dou(BF_dou),
 .PErr(PErr),
 .EErr(EErr),
 .RErr(RErr),

 .fc(fc.slave)
);

initial begin
  $display("fingers crossed");
  clk <= 1'b0;
	rst  <= 1'b1;
	BF_sel<=1'b0;
	BF_ad<=0;
	BF_din<=0;
	BF_we<=0;

	temp<=8'h24;
	#300;
	rst<=1'b0;

	kill_time;

	tbi.reset_cycle();

	kill_time;

	tbi.erase_cycle(16'h1234);

	kill_time;

	//write_cycle(16'h1234);

	kill_time;

	//read_cycle(16'h1234);

	kill_time;

	//read_id_cycle(16'h0000);

	kill_time;

        #1000;
	$stop;

	end

always
   #(period/2) clk <= ~clk;

// --------------------------------------------------------------------
// Task for waiting

task kill_time;
  begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
  end
endtask // of kill_time;

// ---------------------------------------------------------------------


endmodule
