// Module: flash_interface.sv
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash testbench interface

`timescale 1 ns / 1 fs

interface flash_tb_interface(flash_cmd_interface.master fc, buffer_interface.writer buff);

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
    logic [0:2047][7:0] memory;
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
// --------------------------------------------------------------------
// read page task
// NFC commands (all remaining encodings are ignored = NOP):
//-- WPA 001=write page
//-- RPA 010=read page
//-- EBL 100=erase block
// task read_cycle;
//     input [15:0]  address;
//     integer i;
//
// begin
//     @(posedge clk) ;
//     #3;
//     RWA=address;
//     nfc_cmd=3'b010;
//     nfc_strt=1'b1;
//     BF_sel=1'b1;
//     BF_we=1'b0;
//     BF_ad=#3 0;
//     @(posedge clk) ;
//     #3;
//     nfc_strt=1'b0;
//     @(posedge clk) ;
//    wait(nfc_done);
//    @(posedge clk) ;
//    #3;
//    nfc_cmd=3'b111;
//    BF_ad<=#3 BF_ad+1;
//    for(i=0;i<2048;i=i+1) begin
//        @(posedge clk) ;
//        temp<=memory[i];
//        BF_ad<=#3 BF_ad+1;
//     end
//    $display("Read value %p from address %h.", memory, address);
//    if(RErr)
//      $display($time,"  %m  \t \t  << ecc error >>");
//    else
//      $display($time,"  %m  \t \t  << ecc no error >>");
//
// end
// endtask


// task read_id_cycle;
//     input [15:0]  address;
//
// begin
//     @(posedge clk) ;
//     #3;
//     RWA=address;
//     nfc_cmd=3'b101;
//     nfc_strt=1'b1;
//     BF_sel=1'b1;
//     @(posedge clk) ;
//     #3;
//     nfc_strt=1'b0;
//     @(posedge clk) ;
//    wait(nfc_done);
//    @(posedge clk) ;
//    nfc_cmd=3'b111;
//       $display($time,"  %m  \t \t  << read id function over >>");
//
// end
// endtask

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
