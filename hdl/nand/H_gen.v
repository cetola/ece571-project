//-------------------------------------------------------------------------
//  >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//-------------------------------------------------------------------------
//  Copyright (c) 2006-2010 by Lattice Semiconductor Corporation
//
//-------------------------------------------------------------------------
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice Semiconductor provides no warranty
//   regarding the use or functionality of this code.
//-------------------------------------------------------------------------
//
//    Lattice Semiconductor Corporation
//    5555 NE Moore Court
//    Hillsboro, OR 97124
//    U.S.A
//
//    TEL: 1-800-Lattice (USA and Canada)
//    503-268-8001 (other locations)
//
//    web: http://www.latticesemi.com/
//    email: techsupport@latticesemi.com
//
//-------------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author :| Mod. Date :| Changes Made:
//   V01.0:| A.Y    :| 09/30/06  :| Initial ver
//   v01.1:| J.T    :| 06/21/09  :| juse (7,4) hamming code
// --------------------------------------------------------------------
//
//
//Description of module:
//--------------------------------------------------------------------------------
// (7,4) hamming code
// --------------------------------------------------------------------
`timescale 1 ns / 1 ps

module H_gen(
      clk ,
      Res ,
      Din ,
      EN ,//  -- enable ECC

      eccByte

 );
 input     clk ;
 input     Res ;
 input [3:0]    Din ;
 input     EN ; // -- enable ECC

 output reg [7:0]   eccByte;

wire rp1,rp2,rp3;
wire [7:0] ecc;
assign rp1= ((Din[3] ^ Din[2] ^ Din[0])==1'b1)?1:0;
assign rp2= ((Din[3] ^ Din[1] ^ Din[0])==1'b1)?1:0;
assign rp3= ((Din[2] ^ Din[1] ^ Din[0])==1'b1)?1:0;

assign ecc[7]=1'b0;
assign ecc[6]=rp1;
assign ecc[5]=rp2;
assign ecc[4]=Din[3];
assign ecc[3]=rp3;
assign ecc[2]=Din[2];
assign ecc[1]=Din[1];
assign ecc[0]=Din[0];


always@(posedge clk)
  if (Res) begin
      eccByte<=8'h00;
  end else if (EN) begin
      eccByte<=ecc;
    end
endmodule
