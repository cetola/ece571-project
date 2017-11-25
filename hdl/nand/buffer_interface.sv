// Module: buffer_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// buffer interface, eventually implemented as BRAM

interface buffer_interface();

  logic BF_sel, BF_we;
  logic [10:0] BF_ad;
  logic [7:0] BF_dou, BF_din;

  modport reader (
    input BF_sel,
    input BF_we,
    input BF_ad,
    input BF_dou
    );

  modport writer (
    input BF_sel,
    input BF_we,
    input BF_ad,
    output BF_din
    );
endinterface
