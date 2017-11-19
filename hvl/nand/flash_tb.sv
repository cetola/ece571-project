// Module: flash_tb.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash test bench

`timescale 1 ns / 1 fs

module flash_tb();

 logic clk,rst;

 wire [7:0] DIO;
 wire CLE;// -- CLE
 wire ALE;//  -- ALE
 wire WE_n;// -- ~WE
 wire RE_n; //-- ~RE
 wire CE_n; //-- ~CE
 wire R_nB; //-- R/~B

 reg BF_sel;
 reg [10:0] BF_ad;
 reg [7:0] BF_din;
 reg BF_we;
 reg [15:0] RWA; //-- row addr
 wire [7:0] BF_dou;

 wire PErr ; // -- progr err
 wire EErr ; // -- erase err
 wire RErr ;

 reg [2:0] nfc_cmd; // -- command see below
 reg nfc_strt;//  -- pos edge (pulse) to start
 wire nfc_done;//  -- operation finished if '1'


reg[7:0] memory[0:2047];

reg [7:0] temp;

//TODO: BRAM

parameter period=16;         // suppose 60MHz

//assign DIO=ena?DIO_reg:8'hzz;
initial begin
  clk <= 1'b0;
	rst  <= 1'b1;
	BF_sel<=1'b0;
	BF_ad<=0;
	BF_din<=0;
	BF_we<=0;
	RWA<=0;
	nfc_cmd<=3'b111;
	nfc_strt<=1'b0;
	temp<=8'h24;
	#300;
	rst<=1'b0;

	kill_time;
	kill_time;

	reset_cycle;

	kill_time;
	kill_time;

	erase_cycle(16'h1234);

	kill_time;
	kill_time;

	write_cycle(16'h1234);

	kill_time;
	kill_time;

	read_cycle(16'h1234);

	kill_time;
	kill_time;

	read_id_cycle(16'h0000);

	kill_time;
	kill_time;

        #1000;
	$stop;

	end

always
   #(period/2) clk <= ~clk;

// Instantiation of the nfcm
nfcm_top nfcm(
 .DIO(DIO),
 .CLE(CLE),
 .ALE(ALE),
 .WE_n(WE_n),
 .RE_n(RE_n),
 .CE_n(CE_n),
 .R_nB(R_nB),

 .CLK(clk),
 .RES(rst),

 .BF_sel(BF_sel),
 .BF_ad (BF_ad ),
 .BF_din(BF_din),
 .BF_we (BF_we ),
 .RWA   (RWA   ),

 .BF_dou(BF_dou),
 .PErr(PErr),
 .EErr(EErr),
 .RErr(RErr),

 .nfc_cmd (nfc_cmd ),
 .nfc_strt(nfc_strt),
 .nfc_done(nfc_done)
);

// Instantiation of the nand flash interface
flash_interface nand_flash(
    .DIO(DIO),
    .CLE(CLE),// -- CLE
    .ALE(ALE),//  -- ALE
    .WE_n(WE_n),// -- ~WE
    .RE_n(RE_n), //-- ~RE
    .CE_n(CE_n), //-- ~CE
    .R_nB(R_nB), //-- R/~B
    .rst(rst)
);

flash_datastore ds(nand_flash);

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// erase block task
// NFC commands (all remaining encodings are ignored = NOP):
//-- WPA 001=write page
//-- RPA 010=read page
//-- EBL 100=erase block
//-- RET 011=reset
//-- RID 101= read ID
task reset_cycle;
begin
    @(posedge clk) ;
//    RWA=address;
    nfc_cmd=3'b011;
    nfc_strt=1'b1;

    @(posedge clk) ;
    nfc_strt=1'b0;
   wait(nfc_done);
   @(posedge clk) ;
   nfc_cmd=3'b111;
   $display($time,"  %m  \t \t  << reset function over >>");

end
endtask


task erase_cycle;
    input [15:0]  address;
begin
//    $display($time,"  %m  \t \t  << erase flash block Address = %h >>",address);
    @(posedge clk) ;
    #3;
    RWA=address;
    nfc_cmd=3'b100;
    nfc_strt=1'b1;

    @(posedge clk) ;
    #3;
    nfc_strt=1'b0;
    @(posedge clk) ;

   wait(nfc_done);
   @(posedge clk) ;
   nfc_cmd=3'b111;

   if(EErr)
     $display($time,"  %m  \t \t  << erase error >>");
   else
     $display($time,"  %m  \t \t  << erase no error >>");

end
endtask
// --------------------------------------------------------------------
// --------------------------------------------------------------------
// write page task
// NFC commands (all remaining encodings are ignored = NOP):
//-- WPA 001=write page
//-- RPA 010=read page
//-- EBL 100=erase block

task write_cycle;
    input [15:0]  address;
    integer i;
begin
//    $display($time,"  %m  \t \t  << Writing flash page Address = %h >>",address);
    @(posedge clk) ;
    #3;
    RWA=address;
    nfc_cmd=3'b001;
    nfc_strt=1'b1;
    BF_sel=1'b1;
    @(posedge clk) ;
    #3;
    nfc_strt=1'b0;
    BF_ad=0;
    for(i=0;i<2048;i=i+1) begin
       @(posedge clk) ;
       #3;
       BF_we=1'b1;
       memory[i]=$random % 256;
       BF_din<=memory[i];
       BF_ad<=#3 i;
    end
   @(posedge clk) ;
   @(posedge clk) ;
   #3;
   BF_we=1'b0;
   wait(nfc_done);
   @(posedge clk) ;
   #3;
   nfc_cmd=3'b111;
   BF_sel=1'b0;
   if(PErr)
     $display($time,"  %m  \t \t  << Writing error >>");
   else
     $display($time,"  %m  \t \t  << Writing no error >>");

end
endtask

// --------------------------------------------------------------------
// --------------------------------------------------------------------
// read page task
// NFC commands (all remaining encodings are ignored = NOP):
//-- WPA 001=write page
//-- RPA 010=read page
//-- EBL 100=erase block
task read_cycle;
    input [15:0]  address;
    integer i;

begin
    @(posedge clk) ;
    #3;
    RWA=address;
    nfc_cmd=3'b010;
    nfc_strt=1'b1;
    BF_sel=1'b1;
    BF_we=1'b0;
    BF_ad=#3 0;
    @(posedge clk) ;
    #3;
    nfc_strt=1'b0;
    @(posedge clk) ;
   wait(nfc_done);
   @(posedge clk) ;
   #3;
   nfc_cmd=3'b111;
   BF_ad<=#3 BF_ad+1;
   for(i=0;i<2048;i=i+1) begin
       @(posedge clk) ;
       temp<=memory[i];
       BF_ad<=#3 BF_ad+1;
    end

   if(RErr)
     $display($time,"  %m  \t \t  << ecc error >>");
   else
     $display($time,"  %m  \t \t  << ecc no error >>");

end
endtask


task read_id_cycle;
    input [15:0]  address;

begin
    @(posedge clk) ;
    #3;
    RWA=address;
    nfc_cmd=3'b101;
    nfc_strt=1'b1;
    BF_sel=1'b1;
    @(posedge clk) ;
    #3;
    nfc_strt=1'b0;
    @(posedge clk) ;
   wait(nfc_done);
   @(posedge clk) ;
   nfc_cmd=3'b111;
      $display($time,"  %m  \t \t  << read id function over >>");

end
endtask



// --------------------------------------------------------------------
// Task for waiting

task kill_time;
  begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
  end
endtask // of kill_time;

// ---------------------------------------------------------------------


endmodule
