// Module: flash_cmd.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// Thinking about commands as classes
package FlashUtils;

class flash_cmd;
  local logic [2:0] cmd;  // -- command see below
  local logic start;      //  -- pos edge (pulse) to start
  local logic done;        //  -- operation finished if '1'

  function new();
    this.cmd = 3'b111;
    this.start = 1'b0;
    this.done = 1'b0;
  endfunction

  function logic [2:0] getCmd();
    getCmd = this.cmd;
  endfunction

  function void setCmd(logic [2:0] cmd);
    this.cmd = cmd;
  endfunction

  function logic getStart();
    getStart = this.start;
  endfunction

  function void setStart(logic start);
    this.start = start;
  endfunction

  function logic getDone();
    getDone = this.done;
  endfunction

  function void setDone(logic done);
    this.done = done;
  endfunction

endclass

endpackage
