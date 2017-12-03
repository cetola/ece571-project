// Module: FlashPacket.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Randomization for writing flash data.
package FlashData;

class FlashRD;
  rand bit [15:0] address;
  randc int data;
  constraint c {data < 2049;}

  function int getData();
    getData = this.data;
  endfunction

  function void setData(int d);
    this.data = d;
  endfunction

  function bit [15:0] getAddress();
    getAddress = this.address;
  endfunction

  function void setAddress(bit [15:0] addr);
    this.address = addr;
  endfunction
endclass
endpackage
