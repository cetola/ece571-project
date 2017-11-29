// Module: flash_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash testbench interface
// interactions between HVL and HDL code
// HVL runs on co-model server while HDL runs on veloce

`timescale 1 ns / 1 ps

interface flash_tb_interface(
  flash_cmd_interface.master fc,
  buffer_interface.writer buff,
  flash_interface fi); // pragma attribute flash_tb_interface partition_interface_xif

logic [0:2047][7:0] memory;

task reset_wait(); //pragma tbx xtf
  @(negedge fi.rst);
endtask : reset_wait

// --------------------------------------------------------------------
//  RESET
// --------------------------------------------------------------------
task reset_cycle; //pragma tbx xtf
begin
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
end
endtask

// --------------------------------------------------------------------
// ERASE
// --------------------------------------------------------------------
task erase_cycle; //pragma tbx xtf
    input [15:0]  address;
begin
    $display($time,"  %m  \t \t  << erase flash block Address = %h >>",address);
    @(posedge fc.clk);
    #3;
    fc.RWA=address;
    fc.cmd=3'b100;
    fc.start=1'b1;

    @(posedge fc.clk);
    #3;
    fc.start=1'b0;
    @(posedge fc.clk);

   wait(fc.done);
   @(posedge fc.clk);
   fc.cmd=3'b111;

   $display("erase done");

end
endtask : erase_cycle

// --------------------------------------------------------------------
//    WRITE
// --------------------------------------------------------------------

task write_cycle; //pragma tbx xtf
    input [15:0]  address;
    integer i;

begin
    $display($time,"  %m  \t \t  << Writing flash page Address = %h >>",address);
    @(posedge fc.clk);
    #3;
    fc.RWA = address;
    fc.cmd = 3'b001;
    fc.start = 1'b1;
    buff.BF_sel = 1'b1;
    @(posedge fc.clk);
    #3;
    fc.start = 1'b0;
    buff.BF_ad = 0;
    for(i=0;i<2048;i=i+1) begin
       @(posedge fc.clk);
       #3;
       buff.BF_we = 1'b1;
       memory[i]=$random % 256;
       buff.BF_din <= memory[i];
       buff.BF_ad <= #3 i;
    end
   @(posedge fc.clk);
   @(posedge fc.clk);
   #3;
   buff.BF_we = 1'b0;
   wait(fc.done);
   @(posedge fc.clk);
   #3;
   fc.cmd = 3'b111;
   buff.BF_sel = 1'b0;
   $display("Wrote to addres: %h", address);
end
endtask : write_cycle

// --------------------------------------------------------------------
//    READ
// --------------------------------------------------------------------

task read_cycle; //pragma tbx xtf
  input [15:0]  address;
  integer i;
  logic [7:0] temp;

  begin
  temp<=8'h24;
  @(posedge fc.clk);
  #3;
  fc.RWA = address;
  fc.cmd = 3'b010;
  fc.start = 1'b1;
  buff.BF_sel = 1'b1;
  buff.BF_we = 1'b0;
  buff.BF_ad = #3 0;
  @(posedge fc.clk);
  #3;
  fc.start = 1'b0;
  @(posedge fc.clk);
  wait(fc.done);
  @(posedge fc.clk);
  #3;
  fc.cmd = 3'b111;
  buff.BF_ad <= #3 buff.BF_ad + 1;
  for(i=0;i<2048;i=i+1) begin
    @(posedge fc.clk);
    temp <= memory[i];
    buff.BF_ad <= #3 buff.BF_ad + 1;
  end
  $display("Read from address %h.", address);
end
endtask : read_cycle

// --------------------------------------------------------------------
//    READ ID
// --------------------------------------------------------------------

task read_id_cycle; //pragma tbx xtf
  input [15:0]  address;

  begin
  @(posedge fc.clk);
  #3;
  fc.RWA = address;
  fc.cmd = 3'b101;
  fc.start = 1'b1;
  buff.BF_sel = 1'b1;
  @(posedge fc.clk);
  #3;
  fc.start = 1'b0;
  @(posedge fc.clk);
  wait(fc.done);
  @(posedge fc.clk);
  fc.cmd = 3'b111;
  $display($time,"  %m  \t \t  << read id function over >>");
  end
endtask : read_id_cycle

endinterface
