/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// 
////
////
////
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

module SPISlave #(parameter type DTYPE = logic [7:0], parameter ID = 0) (SPIBus SPI);

DTYPE SR;
initial
$display("slave called");
assign SPI.MISO[ID] = SPI.SS[ID] ? 'z : SR[0];

always_ff @(negedge SPI.SCLK)
if (SPI.SS[ID] === 0)
SR <= {SPI.MOSI, SR[$bits(DTYPE)-1:1]};


always@(SR)
$display("id=%b,sr=%b",ID,SR);
endmodule

module SPIMaster #(parameter type DTYPE = logic [7:0]) (SPIBus SPI, input DTYPE Data,
input int ID, input logic Request, output logic Done);

DTYPE MR;

assign SPI.MOSI = MR[0];

initial
$display("master called");

always_ff @(negedge SPI.SCLK)
begin
if($rose(Request))
MR <= Data;
else 
MR <= { &SPI.MISO, MR[$bits(DTYPE)-1:1]}; // delay for setup time of slave?
end

always @(Request)
begin
$display("in SPI Master always block. $bits(DTYPE) = %d",$bits(DTYPE));
begin
$display("in SPIMaster after checking Request/Done");
Done = 0;
SPI.SS[ID] = 0;
//MR = Data;
#100;
if(Request) begin
for (int i = 0; i <= $bits(DTYPE); i++)
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
end
endmodule
