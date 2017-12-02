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

  function new();
    this.data = '0;
    this.address = '0;
  endfunction

  function getData();
    getData = this.data;
  endfunction

  function setData(int d);
    this.data = d;
  endfunction

  function getAddress();
    getAddress = this.address;
  endfunction

  function setAddress(bit [15:0] addr);
    this.address = addr;
  endfunction
endclass
endpackage
