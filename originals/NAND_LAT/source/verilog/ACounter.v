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
//   v01.1:| J.T    :| 06/21/09  :| just use one buffer
// --------------------------------------------------------------------
//
// 
//Description of module:
//--------------------------------------------------------------------------------
// 
// --------------------------------------------------------------------
`timescale 1 ns / 1 fs

module ACounter(
      clk,
      Res,
      Set835,
      CntEn ,
      CntOut,
      TC2048,
      TC3
   )/*synthesis ugroup="addr_group" */;
   input clk;
   input Res;
   input Set835;
   input CntEn;
   output [11:0]  CntOut;
   output  reg TC2048;
   output  reg TC3;
   
reg [11:0] cnt_state;

always@(posedge clk)
  if (Res)
    cnt_state <= 0;
  else if (Set835)
    cnt_state <=12'h835;   
  else if (CntEn)
    cnt_state <= cnt_state + 1;


always@(cnt_state)
   if (cnt_state== 12'h7FF) begin
      TC2048 <= 1; 
      TC3 <=0;
   end else if (cnt_state[7:0] == 8'h40) begin
     TC3 <= 1; 
     TC2048 <= 0;
   end
  // --elsif (cnt_state(3 downto 0) = x"7") or 
  // --      (cnt_state(3 downto 0) = x"A") or 
  // --      (cnt_state(3 downto 0) = x"D") then
  // --  TC3 <= '1'; TC2048 <= '0';
   else begin
     TC3 <=0;
     TC2048 <= 0;
   end

   
assign CntOut = cnt_state;

endmodule
