/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////Created By: kaustubh Agashe. Started off with the in class code on SPI and modified it.//////////////////////////////////////
////Description: Basic functionality of master and slave in master module and slave module respectively./////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

interface SPIBus(); 				//SPI INTERFACE

parameter NUMSLAVES = 1;			//parameterising number of slaves
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

//////////////////////////////////SLAVE MODULE////////////////////////////////////////////////
module SPISlave #(parameter type DTYPE = logic [7:0], parameter ID = 0) (SPIBus.Slave SPI);

DTYPE SR;
initial
$display("slave called");

assign SPI.MISO[ID] = SPI.SS[ID] ? 'z : SR[0];

always_ff @(negedge SPI.SCLK) begin

if (SPI.SS[ID] === 0) begin

SR <= {SPI.MOSI, SR[$bits(DTYPE)-1:1]};
end
//$display($time," clk=%b, id=%b,SR=%b",SPI.SCLK,ID,SR);
end

endmodule

///////////////////////////MASTER MODULE////////////////////////////////////////////////////////////

module SPIMaster #(parameter type DTYPE = logic [7:0], parameter clkwidth = 100) (SPIBus.Master SPI, input DTYPE Data,
				   input int ID, input logic Request, output logic Done, input mainclk, input reset);
 
DTYPE MR;


enum {OFF,ON} load_MR,tristate;

assign SPI.MOSI = MR[0];



initial


$display("master called");


always_ff @(negedge SPI.SCLK)
begin
$display("inside masters always negedge block. tristate=%d, load_MR=%d",tristate,load_MR);

if(tristate==ON) begin
MR <= 'z;
end
else if(load_MR==ON) begin
	MR <= Data;
end
else begin 
MR <= { SPI.MISO, MR[$bits(DTYPE)-1:1]}; 

end
end

always_ff@(posedge mainclk, negedge mainclk)begin
if(reset)
tristate = ON;
else if($rose(Request))begin
load_MR = ON;
tristate = OFF;
end
else begin
load_MR = OFF;
tristate = OFF;
end

end



always @(Request)
begin
$display("in SPI Master always block. $bits(DTYPE) = %d",$bits(DTYPE));

$display("in SPIMaster after checking Request/Done");
Done = 0;
SPI.SS[ID] = 0;

#100;
if(Request) begin
for (int i = 0; i <= $bits(DTYPE); i++)
begin
$display("In SPIMaster loop, i = %d",i);

SPI.SCLK = 1;
#(clkwidth)
SPI.SCLK = 0;
#(clkwidth);
end
$display("...out of loop");
Done = 1'b1;

SPI.SS[ID] = 1'b1;
end
end

endmodule

