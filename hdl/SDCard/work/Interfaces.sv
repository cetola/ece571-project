//Copied from Mark Faust's ECE 571 lecture at Portland State University
interface SPIBus();
parameter NUMSLAVES = 1;
parameter type DTYPE = logic [7:0];

logic SCLK;
logic MOSI;
logic [NUMSLAVES-1:0] MISO;
logic [NUMSLAVES-1:0] SS;

modport Slave(
	output MISO,
	input SCLK,
	input MOSI,
	input SS
	);

modport Master(
	input MISO,
	output SCLK,
	output MOSI,
	output SS
	);
endinterface

interface sdPins(
	input sdClk,
  	inout cmd,
  	inout [3:0] dat
	);//(input logic sdClk;
	/*logic sdClk;
  	logic cmd;
  	logic [3:0] dat;*/

	
endinterface

interface flash_interface(
  inout [7:0] DIO, //data input / output
  input CLE,       //command latch
  input ALE,       //address latch
  input WE_n,      //write enable
  input RE_n,      //read enable
  input CE_n,      //chip enable
  output reg R_nB, //flash ready, "not busy"
  input rst        //reset
);
endinterface

/*
module SPISlave #(parameter type DTYPE = logic [7:0], parameter ID = 0) (SPIBus SPI);
DTYPE SR;
assign SPI.MISO[ID] = SPI.SS[ID] ? 'z : SR[0];
always_ff @(negedge SPI.SCLK)
	if (SPI.SS[ID] === 0)
	SR <= {SPI.MOSI, SR[$bits(DTYPE)-1:1]};
endmodule

module SPIMaster #(parameter type DTYPE = logic [7:0]) (SPIBus SPI, input DTYPE Data,
 input int ID, input logic Request, output logic Done);
DTYPE MR;
assign SPI.MOSI = MR[0];
always_ff @(negedge SPI.SCLK)
begin
MR <= { &SPI.MISO, MR[$bits(DTYPE)-1:1]}; // delay for setup time of slave?
end
always @(Request)
begin
$display("in SPI Master always block. $bits(DTYPE) = %d",$bits(DTYPE));
begin
$display("in SPIMaster after checking Request/Done");
Done = 0;
SPI.SS[ID] = 0;
MR = Data;
#100;
for (int i = 0; i < $bits(DTYPE); i++)
begin
$display("In SPIMaster loop, i = %d",i);
SPI.SCLK = 1;
#100
SPI.SCLK = 0;
#100;
end
$display("...out of loop");
Done = 1;
SPI.SS[ID] = 1;
end
end
endmodule
module top;
typedef logic [7:0] DTYPE;
DTYPE D;
int S;
bit Request;
bit Done;
SPIBus #(.DTYPE(DTYPE),.NUMSLAVES(2)) SPI();
SPISlave #(.DTYPE(DTYPE),.ID(0)) S0(SPI);
SPISlave #(.DTYPE(DTYPE),.ID(1)) S1(SPI);
SPIMaster #(.DTYPE(DTYPE)) M1(SPI,D,S,Request,Done);
initial
begin
$display("In initial block");
S = 0;
D = 8'b10010010;
Request = 1;
wait(Done);
$display("MR = %b",M1.MR);
$display("SR[0] = %b",S0.SR);
$display("SR[1] = %b",S1.SR);
$finish();
end
endmodule*/