interface SDInterface(
	input clk
);

	trireg cmd;
	tri [3:0] data;

endinterface
