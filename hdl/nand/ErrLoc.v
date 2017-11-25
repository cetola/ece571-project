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
// (7,4) hamming code detect
// --------------------------------------------------------------------
`timescale 1 ns / 1 ps

module ErrLoc(
      clk,
      Res,
      F_ecc_data ,// -- ecc byte read fm flash
      WrECC,


      ECC_status
);
  input    clk;
  input    Res;
  input  [6:0]  F_ecc_data ; //-- ecc byte read fm flash
  input    WrECC ;

  output reg ECC_status;

wire check1,check2,check3;
reg [6:0] din;

always@(posedge clk)
 if (Res)
  din <= 8'h00;
 else if (WrECC)
  din <= F_ecc_data;

assign check1=din[6]^din[4]^din[2]^din[0];
assign check2=din[5]^din[4]^din[1]^din[0];
assign check3=din[3]^din[2]^din[1]^din[0];

always@(posedge clk)
 if (Res)
  ECC_status <= 1'h0;
 else
  ECC_status <= (check1 | check2 | check3);


endmodule
