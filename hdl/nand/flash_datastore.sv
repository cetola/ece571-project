// Module: flash_datastore.sv
// Based on flash_interface.v from Lattice Semiconductor
// Authors:
// Stephano Cetola <cetola@pdx.edu>
//
// Description:
// NAND flash datastore
// This would be implemented by actual NAND flash.
// For our project, it would more likely be backed up
// by block device storage on an FPGA board. Maybe even
// by an actual SD Card to maximize the irony.

`timescale 1 ns / 1 fs

module flash_datastore(flash_interface fi);

logic [7:0] memory [0:2112];
logic dat_en;
logic[7:0] datout;
logic[7:0] command;
logic[7:0] row1,row2,col1,col2,idaddr;

assign fi.DIO=dat_en?datout:8'hzz;

always@(posedge fi.WE_n or fi.rst)
 if(fi.rst) begin
  command<= 8'hff;
 end else
  if(!fi.CE_n && fi.CLE) begin
   command=fi.DIO;
   case(command)
    8'h60:
      $display($time,"ns : auto block erase setup command");
    8'hd0:
      $display($time,"ns : erase address:%h",{row1,row2});
    8'h70:
      $display($time,"ns : read status command");
    8'h80:
      $display($time,"ns : write page setup command");
    8'h85:begin
      $display($time,"ns : write page row address:%h",{row1,row2});
      $display($time,"ns : random data write command");
    end
    8'h10:begin
      $display($time,"ns : random write page column address:%h",{col1,col2});
      $display($time,"ns : write page command");
    end
    8'h00:
       $display($time,"ns : read page setup command");
    8'h30:begin
       $display($time,"ns : read page row address:%h,column address:%h",{row1,row2},{col1,col2});
       $display($time,"ns : read page command");
    end
    8'h05:
       $display($time,"ns : random read page setup command");
    8'he0:begin
       $display($time,"ns : random read page column address:%h",{col1,col2});
       $display($time,"ns : random read page command");
    end
    8'hff:begin
       $display($time,"ns:  reset function ");
    end
    8'h90:begin
        $display($time,"ns:  read ID function ");
    end
   endcase
  end

always@(posedge fi.WE_n or fi.rst)
 if(fi.rst) begin
  row1<= 8'h00;
  row2<= 8'h00;
  col1<= 8'h00;
  col2<= 8'h00;
  idaddr<=8'h00;
 end else
  if(!fi.CE_n && fi.ALE) begin
   case(command)
    8'h60: begin
      row1<=fi.DIO;
      row2<=row1;
    end
//    8'hd0:
//      $display($time,"ns : erase address:%h",{row1,row2});
    8'h80:begin
      row1<= fi.DIO;
      row2<= row1;
      col1<= row2;
      col2<= col1;

    end
    8'h85:begin
      col1<= fi.DIO;
      col2<= col1;
  //    $display($time,"ns : write page row address:%h, column address:%h",{row1,row2},{col1,col2});
    end
//    8'h10:
//      $display($time,"ns : random write page column address:%h",{col1,col2});
    8'h00:begin
      row1<= fi.DIO;
      row2<= row1;
      col1<= row2;
      col2<= col1;
    end
//    8'h30:
//       $display($time,"ns : read page row address:%h,column address:%h",{row1,row2},{col1,col2});
    8'h05:begin
       col1<= fi.DIO;
       col2<= col1;
    end
//    8'he0:
//       $display($time,"ns : random read page column address:%h",{col1,col2});
    8'h90:begin
       idaddr<=fi.DIO;
    end
   endcase
  end

reg [11:0] con1,con1_835;
integer i;
always@(posedge fi.WE_n or fi.rst)
 if(fi.rst) begin
  con1_835<=12'h835;
  con1<=0;
  for(i=0;i<2113;i=i+1) begin
   memory[i]= 8'h00;
  end
 end else
  if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h80) begin
    memory[con1]=fi.DIO;
    con1<=con1+1;
  end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h85) begin
    memory[con1_835]=fi.DIO;
    con1_835<=con1_835+1;
  end

reg [1:0] con;
always@(negedge fi.RE_n or fi.rst)// or fi.CE_n or fi.ALE or fi.CLE)
 if(fi.rst) begin
  con<=0;
 end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h90) begin
  con<=con+1;
 end



reg [11:0] con2,con2_835;
always@(negedge fi.RE_n or fi.rst)// or fi.CE_n or fi.ALE or fi.CLE)
 if(fi.rst) begin
  con2<=0;
  datout<=0;
  con2_835<=12'h835;
 end else
  if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h30) begin
     datout<=memory[con2];
     con2<=con2+1;
     con2_835<=12'h835;
  end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'he0) begin
    datout<=memory[con2_835];
    con2_835<=con2_835+1;
  end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h70) begin
    datout<=8'h00;
    con2<=0;
    con2_835<=0;
  end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h90) begin
    con2<=0;
    con2_835<=12'h0;
    if(con==2'b00) begin
      datout<=8'hec;
      $display($time,"ns : id code:%h",datout);
    end else if(con==2'b01) begin
      datout<=8'hf1;
      $display($time,"ns : id code:%h",datout);
    end else if(con==2'b10) begin
      datout<=8'h00;
      $display($time,"ns : id code:%h",datout);
    end else if(con==2'b11) begin
      datout<=8'h15;
      $display($time,"ns : id code:%h",datout);
    end
  end else begin
    con2<=0;
    datout<=0;
    con2_835<=12'h835;
  end

always@(posedge fi.RE_n or fi.rst or con2 or con2_835)// or fi.CE_n or fi.ALE or fi.CLE)
 if(fi.rst) begin
  dat_en<=0;
 end else
  if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h30) begin
    if(con2!=2048)
      dat_en<=1;
    else
      #50
      dat_en<=0;
  end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'he0) begin
    if(con2_835!=2113)
      dat_en<=1;
    else
      #50
      dat_en<=0;

   end else if(!fi.CE_n && !fi.ALE && !fi.CLE && command==8'h90) begin
      dat_en<=1;
       #50
       dat_en<=0;
  end else if(command==8'h70) begin
    dat_en<=1;
    #151
    dat_en<=0;

  end //else begin


always@(fi.RE_n or fi.rst or fi.CE_n or fi.ALE or fi.CLE or fi.WE_n)
 if(fi.rst) begin
  fi.R_nB<=1;
 end else
  if(command==8'hd0) begin
    #60
    fi.R_nB<=0;
    #200
    fi.R_nB<=1;
  end else if(command==8'h10) begin
    #60
    fi.R_nB<=0;
    #200
    fi.R_nB<=1;
  end else if(command==8'h30) begin
    #60
    fi.R_nB<=0;
    #200
    fi.R_nB<=1;
  end else
    fi.R_nB<=1;
endmodule
