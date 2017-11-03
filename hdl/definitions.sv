//guard against re-inclusion of defs
`ifndef IMPORT_DEFS

	`define IMPORT_DEFS

	package definitions;

		//2 STATE
		typedef	byte		unsigned	uint8;
		typedef	shortint	unsigned	uint16;
		typedef	int		unsigned	uint32;
		typedef	longint		unsigned	uint64;

		//4 STATE
		typedef	logic		unsigned	[7:0]	ulogic8;
		typedef	logic		unsigned	[15:0]	ulogic16;
		typedef	logic		unsigned	[31:0]	ulogic32;
		typedef	logic		unsigned	[63:0]	ulogic64;
		typedef	logic		unsigned	[127:0]	ulogic128;
		typedef	logic		unsigned	[255:0]	ulogic256;

	endpackage

	import definitions::*;

`endif
