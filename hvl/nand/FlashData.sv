// Module: FlashPacket.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Randomization for writing flash data.
package FlashData;

class FlashRD;
  static int ADDR = 0;
  static int DATA = 1;
  local const int MAXDATA = 2048;
  rand bit [15:0] address;
  randc int data;
  constraint c {data > -1; data < MAXDATA;}

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

  function void setMaxVal(int prop);
    case(prop)
        FlashRD::ADDR: this.address = '1;
        FlashRD::DATA: this.data = MAXDATA;
    endcase
  endfunction

  function void setMinVal(int prop);
    case(prop)
        FlashRD::ADDR: this.address = '0;
        FlashRD::DATA: this.data = 0;
    endcase
  endfunction

  function void setAltAddr();
    this.address = 16'haaaa;
  endfunction
endclass
endpackage
