// Module: top_hdl.sv
// Authors:
//
// Description:
//  sythesizable constructs for running on Veloce simulator

`include "definitions.sv"

module top_hdl(); // pragma attribute top_hdl partition_module_xrtl

	timeunit 1ns;
	timeprecision 1ps;

	logic clk = 1'b0;
	logic reset = 1'b0;

	initial begin
		clk = 1'b0;
		forever #0.5 clk = !clk;
	end

	initial begin
		reset = 1'b0;
		#2 reset = 1'b1;
	end

endmodule
