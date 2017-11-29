module top;
parameter data_width = 32;
parameter NUMSLAVES = 12;
parameter SS = 10;
typedef logic [data_width-1:0] DTYPE;
DTYPE D;
DTYPE temp;
int S;
bit Request;
bit Done;
genvar i;
SPIBus #(.DTYPE(DTYPE),.NUMSLAVES(NUMSLAVES)) SPI();
generate 
for(i = 1'b0; i < NUMSLAVES; i=i+1'b1)
begin : loop
SPISlave #(.DTYPE(DTYPE),.ID(i)) Slave(SPI);
end
endgenerate
SPIMaster #(.DTYPE(DTYPE)) M1(SPI,D,S,Request,Done);

always @ (D)
temp = D;


initial
begin
$display("In initial block");
S = 10;
D = 16'b1001001110010011;
Request = 0;
#100 Request = 1;


wait(Done);
$display("MR = %b, Done=%b",M1.MR,Done);
if((top.loop[SS].Slave.SR === temp))
$display("TEST PASSED");
else
$display("TEST FAILED");
//$display("SR[0] = %b",S0.SR);
//$display("SR[1] = %b",S1.SR);

#100 Request = 0;
#100 Request = 1;
#100 S = 10;
D = 8'b10010011;



wait(Done);
$display("MR = %b, Done=%b",M1.MR,Done);
if((top.loop[SS].Slave.SR === temp))
$display("TEST PASSED");
else
$display("TEST FAILED");
//$display("SR[0] = %b",S0.SR);
//$display("SR[1] = %b",S1.SR);




$stop();
end

always@(M1.MR,Done,Request)
$display($time,"Request=%b, MR=%b, Done=%b",Request,M1.MR,Done);

//final
//$display("MR=%b,S0.SR=%b,S1.SR=%b,done=%b",M1.MR,S0.SR,S1.SR,Done);

endmodule
//////////////////////////////////////////////////////////////////////////////////////


