// Module: FlashPacket.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Randomization for writing flash address.
package FlashData;

class FlashRD;
  local randc bit [15:0] address;
  static logic [7:0] temp [0:2047];
  local string hexFile;

  function new(string f="nand.hex");
    this.hexFile = f;
    for(int i=0;i<2048;i++) begin
        FlashRD::temp[i] = $urandom_range(255);
    end
    $writememh(this.hexFile, FlashRD::temp);
  endfunction

  function string getHexFile();
    getHexFile = this.hexFile;
  endfunction

  function bit [15:0] getAddress();
    getAddress = this.address;
  endfunction

  function void setAddress(bit [15:0] addr);
    this.address = addr;
  endfunction

  function void setMaxAddr();
    this.address = '1;
  endfunction

  function void setMinAddr();
    this.address = '0;
  endfunction

  function void setAltAddr();
    this.address = 16'hAAAA;
  endfunction
endclass
endpackage
