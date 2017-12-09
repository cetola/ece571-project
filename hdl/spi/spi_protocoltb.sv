///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////Created By : Kaustubh Agashe
/////Description : top module ----> module upTop : instantiates module top which models the testbench functionality.
/////number of slaves, slave select, and data width of the data to be transferred can be changed through the 
////module upTop. 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package Randomize;            		//class created. used for randomisation of NUMSLAVES,SS, data_width.
class Packet;
int data_width = 8;
randc bit [7:0] D;
rand int SS,NUMSLAVES;
static int count = 0; 			// Number of objects created
int id;

constraint c {
		D inside {[1:data_width]};
	     }

constraint d {SS < 10;}

constraint e {NUMSLAVES < 32 ;}

endclass

endpackage
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SPItb #(
	parameter data_width = 8,
	parameter NUMSLAVES = 12,
	parameter clkwidth = 100,
	parameter SS = 10);
	
	

typedef logic [data_width-1:0] DTYPE;


import Randomize::*;

logic mainclk,reset;		//clock added

DTYPE D;

DTYPE temp,j;			//to record the original data to be transferred.



int S,passed,failed,total_tests;
int index;
bit Request;
bit Done;

genvar i;

SPIBus #(.DTYPE(DTYPE),.NUMSLAVES(NUMSLAVES)) SPI(); //SPI interface instantiation.

generate 					//SPI slave connections generated depending on NUMSLAVES.
for(i = 1'b0; i < NUMSLAVES; i=i+1'b1)
begin : loop
SPISlave #(.DTYPE(DTYPE),.ID(i)) Slave(SPI);
end : loop
endgenerate

SPIMaster #(.DTYPE(DTYPE),.clkwidth(clkwidth)) M1(SPI,D,S,Request,Done,mainclk,reset);
							//SPI master instantiated
always @ (D)begin		//update data
temp = D;
$display("D=%d",temp);
end

always #clkwidth mainclk=~mainclk;

initial begin
Packet p;			//handle created
p = new();			//object created
			
p.data_width = data_width;	//update randomized data width
reset = 1'b0;			
mainclk=1'b0;
$display("In initial block. packetCount=%d",p.count);

passed=0;
failed=0;
total_tests=0;

for(int j=0; j<10; j=j+1) begin	 	//generating testcases with randomoized data width,NUMSLAVES and SS.
$display("INSIDE J LOOP");
#200 Request = 0;
#100 Request = 1;
     S = SS;
assert (p.randomize(D)) $display("randomization successful");		//randomizing data
else $fatal(0, "Packet::randomize failed");
	
     D = p.D;

/////Self testing results
wait(Done);				
$display("clk=%b, MR = %b, SR %d = %b, Done=%b",SPI.SCLK,D,SS,SPItb.loop[SS].Slave.SR,Done);
if(((SPItb.loop[SS].Slave.SR) === temp)) begin
$display("TEST PASSED");
passed=passed+1;
end
else begin
$display("TEST FAILED");
failed=failed+1;
end   
end

for(int z=0;z<6;z=z+1) begin		//checking for all 0s, all 1s, Xs and Zs
$display("INSIDE Z LOOP");

#200 Request = 0;
#100 Request = 1;
     S = SS;
if(z==0)  D = '0;	
else if(z==1)  D = '1;
else if(z==2)  D = 'x;	
else if(z==3)  D = {(data_width/2){2'b10}};	
else if(z==4)  D = {(data_width/2){2'b01}};	
else D = 'z;
	

//Self testing
wait(Done);
$display("clk=%b, MR = %b, SR %d = %b, Done=%b",SPI.SCLK,D,SS,SPItb.loop[SS].Slave.SR,Done);
if(((SPItb.loop[SS].Slave.SR) === temp))begin
$display("TEST PASSED");
passed=passed+1;
end
else begin
$display("TEST FAILED");
failed=failed+1;
end
end
 $stop;
end



always@(M1.MR,Done,Request,SPI.SCLK,mainclk,SPItb.loop[SS].Slave.SR,reset)			
$display($time," mainclk=%b, reset=%b, spi.sclk=%b, Request=%b, MR=%b, Done=%b, SR=%b",mainclk,reset,SPI.SCLK,Request,M1.MR,Done, SPItb.loop[SS].Slave.SR);

final begin					//Check and print test results.
$display("NUMSLAVES=%d, datawidth=%d, SS=%d",NUMSLAVES,data_width,SS);
$display("total tests=%d, passed=%d, failed=%d",passed+failed,passed,failed);
if(failed==0) $display("TEST PASSED ! ! !");
else $display("TEST FAILED ! ! !");
end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////TOP///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////MODULE/////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module upTop;



import Randomize::*;


initial begin
Packet packet;
packet=new();

end
//works for data_width > 1 with no upper limit and variable number of slaves with NUMSLAVES > 0 and slave select <= NUMSLAVES.
SPItb #(.data_width(16),.NUMSLAVES(10),.SS(2)) SPI_protocol();

endmodule
