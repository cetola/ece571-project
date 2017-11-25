// Module: flash_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash testbench interface
// interactions between HVL and HDL code
// HVL runs on co-model server while HDL runs on veloce

`timescale 1 ns / 1 fs

interface flash_tb_interface(flash_cmd_interface.master fc, buffer_interface.writer buff);

logic [0:2047][7:0] memory;

// --------------------------------------------------------------------
//  RESET
// --------------------------------------------------------------------
task reset_cycle;
begin
    kill_time();
    $display("reset start");
    @(posedge fc.clk);
    fc.cmd = 3'b011;
    fc.start = 1'b1;
    @(posedge fc.clk);
    fc.start = 1'b0;
   wait(fc.done);
   @(posedge fc.clk);
   fc.cmd = 3'b111;
   $display($time,"  %m  \t \t  << reset function over >>");
   kill_time();
end
endtask

// --------------------------------------------------------------------
// ERASE
// --------------------------------------------------------------------
task erase_cycle;
    input [15:0]  address;
begin
    $display($time,"  %m  \t \t  << erase flash block Address = %h >>",address);
    @(posedge fc.clk) ;
    #3;
    fc.RWA=address;
    fc.cmd=3'b100;
    fc.start=1'b1;

    @(posedge fc.clk) ;
    #3;
    fc.start=1'b0;
    @(posedge fc.clk) ;

   wait(fc.done);
   @(posedge fc.clk) ;
   fc.cmd=3'b111;

   $display("erase done");
   kill_time();
   //TODO: check for errors in the tb
   // if(EErr)
   //   $display($time,"  %m  \t \t  << erase error >>");
   // else
   //   $display($time,"  %m  \t \t  << erase no error >>");

end
endtask : erase_cycle

// --------------------------------------------------------------------
//    WRITE
// --------------------------------------------------------------------

task write_cycle;
    input [15:0]  address;
    integer i;

begin
    $display($time,"  %m  \t \t  << Writing flash page Address = %h >>",address);
    @(posedge fc.clk) ;
    #3;
    fc.RWA = address;
    fc.cmd = 3'b001;
    fc.start = 1'b1;
    buff.BF_sel = 1'b1;
    @(posedge fc.clk) ;
    #3;
    fc.start = 1'b0;
    buff.BF_ad = 0;
    for(i=0;i<2048;i=i+1) begin
       @(posedge fc.clk) ;
       #3;
       buff.BF_we = 1'b1;
       memory[i]=$random % 256;
       buff.BF_din <= memory[i];
       buff.BF_ad <= #3 i;
    end
   @(posedge fc.clk) ;
   @(posedge fc.clk) ;
   #3;
   buff.BF_we = 1'b0;
   wait(fc.done);
   @(posedge fc.clk) ;
   #3;
   fc.cmd = 3'b111;
   buff.BF_sel = 1'b0;
   $display("Wrote to addres: %h value: %p.", address, memory);
   kill_time();
   //TODO: check for errors
   // if(PErr)
   //   $display($time,"  %m  \t \t  << Writing error >>");
   // else
   //   $display($time,"  %m  \t \t  << Writing no error >>");

end
endtask : write_cycle

// --------------------------------------------------------------------
//    WRITE
// --------------------------------------------------------------------

task read_cycle;
  input [15:0]  address;
  integer i;
  logic [7:0] temp;

  begin
  temp<=8'h24;
  @(posedge fc.clk) ;
  #3;
  fc.RWA = address;
  fc.cmd = 3'b010;
  fc.start = 1'b1;
  buff.BF_sel = 1'b1;
  buff.BF_we = 1'b0;
  buff.BF_ad = #3 0;
  @(posedge fc.clk) ;
  #3;
  fc.start = 1'b0;
  @(posedge fc.clk) ;
  wait(fc.done);
  @(posedge fc.clk) ;
  #3;
  fc.cmd = 3'b111;
  buff.BF_ad <= #3 buff.BF_ad + 1;
  for(i=0;i<2048;i=i+1) begin
    @(posedge fc.clk) ;
    temp <= memory[i];
    buff.BF_ad <= #3 buff.BF_ad + 1;
  end
  $display("Read value %p from address %h.", memory, address);
  kill_time();
  //TODO: assert, throw error
  // if(RErr)
  // $display($time,"  %m  \t \t  << ecc error >>");
  // else
  // $display($time,"  %m  \t \t  << ecc no error >>");

end
endtask : read_cycle

// --------------------------------------------------------------------
//    READ ID
// --------------------------------------------------------------------

task read_id_cycle;
  input [15:0]  address;

  begin
  @(posedge fc.clk) ;
  #3;
  fc.RWA = address;
  fc.cmd = 3'b101;
  fc.start = 1'b1;
  buff.BF_sel = 1'b1;
  @(posedge fc.clk) ;
  #3;
  fc.start = 1'b0;
  @(posedge fc.clk) ;
  wait(fc.done);
  @(posedge fc.clk) ;
  fc.cmd = 3'b111;
  $display($time,"  %m  \t \t  << read id function over >>");
  kill_time();
  end
endtask : read_id_cycle

task kill_time;
  begin
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
    @(posedge fc.clk);
  end
endtask

endinterface
