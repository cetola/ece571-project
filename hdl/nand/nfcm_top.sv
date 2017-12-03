// Based on Lattice Semiconductor nfcm_top.v
// see that file for the original
//Authors:
//Stephano Cetola

`timescale 1 ns / 1 ps
module nfcm_top(
  fi,
  buff,
  PErr,
  EErr,
  RErr,
  error_bv,
  fc
);

flash_interface fi;
buffer_interface.reader buff;
flash_cmd_interface.slave fc;

//-- Status
 output reg PErr ; // -- progr err
 output reg EErr ; // -- erase err
 output reg RErr ;

//-- Err Check
  input error_bv ; // -- inject error

parameter HI= 1'b1;
parameter LO= 1'b0;

reg ires, res_t;
//
wire [7:0] FlashDataIn;
reg [7:0] FlashCmd;
reg [7:0] FlashDataOu;
wire [1:0] adc_sel;
wire [7:0] QA_1,QB_1;
wire [7:0] BF_data2flash, ECC_data;
wire Flash_BF_sel, Flash_BF_we, DIS, F_we;

//-- ColAd, RowAd
wire rar_we;
reg [7:0] addr_data;
reg [7:0] rad_1;
reg [7:0] rad_2;

wire [7:0] cad_1;
wire [7:0] cad_2;
wire [1:0] amx_sel;
//-- counter ctrls
wire CntEn, tc3, tc2048, cnt_res, acnt_res;
wire [11:0] CntOut;
//--TFSM
reg DOS;  //-- data out strobe
wire t_start, t_done;
wire [2:0] t_cmd;
//-- ECC byte sel
//wire ByteCntRes, ByteSelCntEn;
//wire [1:0] eccByteSel, eccWrSectSel;
//-- wait counter
wire WCountRes, WCountCE;
reg TC4, TC8;  //-- term counts
//reg [3:0] WCountOut;
//--
wire cmd_we ;
wire [7:0] cmd_reg;
//reg [1:0] TBF_i, RBF_i;
//reg [1:0] setRBF, resTBF;
wire SetPrErr, SetErErr,SetRrErr;
//--
wire WrECC, WrECC_e, enEcc, Ecc_en,ecc_en_tfsm;
wire setDone, set835;

wire DOS_i;
reg [7:0] FlashDataOu_i ;


assign buff.BF_dou =  QA_1;
assign BF_data2flash = QB_1;
assign cad_1 = CntOut[7:0];
assign cad_2 = {4'b0000,CntOut[11:8]};

assign acnt_res = (ires | cnt_res);
assign WrECC_e = WrECC & DIS;
assign Flash_BF_we = DIS & F_we;

assign Ecc_en = enEcc & ecc_en_tfsm;

//TODO: BRAM buffer
// use a buffer_interface.writer
// ebr_buffer buff(
//           .DataInA(BF_din),
//           .QA(QA_1),
//           .AddressA(BF_ad),
//           .ClockA(fc.clk),
//           .ClockEnA(BF_sel),
//           .WrA(BF_we),
//           .ResetA(LO),
//           .DataInB(FlashDataIn),
//           .QB(QB_1),
//           .AddressB(CntOut[10:0]),
//           .ClockB(fc.clk),
//           .ClockEnB(Flash_BF_sel),
//           .WrB(Flash_BF_we),
//           .ResetB(LO)
// );

ACounter addr_counter (
          .clk(fc.clk),
          .Res(acnt_res),
          .Set835(set835),
          .CntEn(CntEn),
          .CntOut(CntOut),
          .TC2048(tc2048),
          .TC3(tc3)
);

TFSM tim_fsm(
          .CLE(fi.CLE),
          .ALE (fi.ALE),
          .WE_n(fi.WE_n),
          .RE_n(fi.RE_n),
          .CE_n(fi.CE_n),
          .DOS (DOS_i),
          .DIS (DIS),
          .cnt_en(CntEn),
          .TC3(tc3),
          .TC2048(tc2048),
          .CLK(fc.clk),
          .RES(ires),
          .start(t_start),
          .cmd_code(t_cmd),
          .ecc_en(ecc_en_tfsm),
          .Done(t_done)
);

MFSM main_fsm
(
  .CLK ( fc.clk ),
  .RES ( ires ),
  .start ( fc.start),
  .command(fc.cmd),
  .setDone(setDone),
  .R_nB (fi.R_nB),
  .BF_sel( buff.BF_sel),
//  .TBF ( TBF_i),
//  .RBF ( RBF_i),
//  .ResTBF ( Wr_done),
//  .SetRBF ( Rd_done),
  .mBF_sel ( Flash_BF_sel),
  .BF_we( F_we),
  .io_0( FlashDataIn[0]),
  .t_start ( t_start),
  .t_cmd  ( t_cmd),
  .t_done ( t_done),
  .WrECC ( WrECC),
  .EnEcc ( enEcc),
//  .ecc2flash ( ecc2flash),
//  .byteSelCntEn ( ByteSelCntEn),
//  .byteSelCntRes( ByteCntRes),
  .AMX_sel ( amx_sel),
  .cmd_reg ( cmd_reg),
  .cmd_reg_we( cmd_we),
  .RAR_we ( rar_we),
//  .ADS (ads),
  .set835 ( set835),
  .cnt_res ( cnt_res),
  .tc8  ( TC8),
  .tc4  ( TC4),
  .wCntRes( WCountRes),
  .wCntCE ( WCountCE),
  .SetPrErr  ( SetPrErr),
  .SetErErr  (  SetErErr),
//  .SetBFerr ( setBFerr),
  .ADC_sel ( adc_sel)
);

H_gen ecc_gen(
     . clk( fc.clk),
     . Res( acnt_res),
     . Din( BF_data2flash[3:0]),
     . EN (Ecc_en),

     . eccByte ( ECC_data)
);

ErrLoc ecc_err_loc
 (
      .clk( fc.clk),
      .Res (acnt_res),
      .F_ecc_data (FlashDataIn[6:0]),
      .WrECC (WrECC_e),
      .error_bv (error_bv),
      .ECC_status (SetRrErr)
);

always@(posedge fc.clk)
begin
  res_t <= fi.rst;
  ires <= res_t;
end

always@(posedge fc.clk)
  if (rar_we) begin
    rad_1=fc.RWA[7:0];
    rad_2=fc.RWA[15:8];
  end

always@(posedge fc.clk)
begin
  FlashDataOu <= FlashDataOu_i;
  DOS <= DOS_i;
end


always@(cad_1 or cad_2 or rad_1 or rad_2 or amx_sel)
 begin
  case (amx_sel)
     2'b11 : addr_data <= rad_2;
     2'b10 : addr_data <= rad_1;
     2'b01 : addr_data <= cad_2;
     default: addr_data <= cad_1;
  endcase
 end

always@(adc_sel or BF_data2flash or FlashCmd or addr_data or ECC_data)
begin
case (adc_sel)
   2'b11 : FlashDataOu_i <= FlashCmd;
   2'b10 : FlashDataOu_i <= addr_data;
   2'b01 : FlashDataOu_i <= ECC_data;
   default: FlashDataOu_i <= BF_data2flash;
endcase
end

reg [3:0] WC_tmp;
always@(posedge fc.clk)
begin
  if ((ires ==1'b1) | (WCountRes ==1'b1))
    WC_tmp<= 4'b0000;
  else if (WCountCE ==1'b1)
    WC_tmp<= WC_tmp + 1;


  if (WC_tmp ==4'b0100) begin
    TC4 <= 1'b1;
    TC8 <= 1'b0;
  end else if (WC_tmp ==4'b1000) begin
    TC8<= 1'b1;
    TC4 <=1'b0;
  end else begin
    TC4 <=1'b0;
    TC8 <=1'b0;
  end
//  WCountOut <= WC_tmp;
end


always@(posedge fc.clk)
begin
  if (ires)
    FlashCmd <=8'b00000000;
  else if (cmd_we)
    FlashCmd <= cmd_reg;
end

always@(posedge fc.clk)
begin
  if (ires)
    fc.done <= 1'b0;
  else if (setDone)
    fc.done <=1'b1;
  else if (fc.start)
    fc.done <=1'b0;

end


always@(posedge fc.clk)
begin
  if (ires)
    PErr <=1'b0;
  else if (SetPrErr)
    PErr <= 1'b1;
  else if (fc.start)
    PErr <= 1'b0;
end

always@(posedge fc.clk)
begin
  if (ires)
    EErr <=1'b0;
  else if (SetErErr)
    EErr <=1'b1;
  else if (fc.start)
    EErr <= 1'b0;
end

always@(posedge fc.clk)
begin
  if (ires)
    RErr <=1'b0;
  else if (SetRrErr)
    RErr <= 1'b1;
  else if (fc.start)
    RErr <= 1'b0;
end


assign FlashDataIn = fi.DIO;
assign fi.DIO =(DOS == 1'b1)?FlashDataOu:8'hzz;


endmodule
