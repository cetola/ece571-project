 //`include "timescale.v"
`include "sd_defines.v"
`define tTLH 10 //Clock rise time
`define tHL 10 //Clock fall time
`define tISU 6 //Input setup time
`define tIH 0 //Input hold time
`define tODL 14 //Output delay
`define DLY_TO_OUTP 47

`define BLOCKSIZE 512
localparam MEMSIZE = 24643590; // 2mb block
`define BLOCK_BUFFER_SIZE 1
`define TIME_BUSY 63

`define PRG 7
`define RCV 6
`define DATAS 5
`define TRAN 4


module sdModel(SDInterface sdPin);


typedef struct {
	//output data
	reg oeCmd;
	reg oeDat;
	reg cmdOut;
	reg [3:0] datOut;
	reg [10:0] transf_cnt;
	} outStruct;

outStruct sdOut;

//output assignment
assign sdPins.cmd = sdOut.oeCmd ? sdOut.cmdOut : 1'bz;
assign sdPins.data = sdOut.oeDat ? sdOut.datOut : 4'bz;

typedef struct {
	reg [5:0] lastCMD;
	reg cardIdentificationState;
	reg CardTransferActive;
	reg [2:0] BusWidth;
	} cardStatusStruct;

cardStatusStruct cardStatus;


typedef struct {
	//memory and input buffer
	reg InbuffStatus;
	reg [31:0] BlockAddr;
	reg [7:0] Inbuff [0:511];
	} memFlashStruct;

memFlashStruct memFlash;

reg [7:0] FLASHmem [0:MEMSIZE]; //cannot be declared in a structure

typedef struct {
	//command and CRC bits
	reg [46:0]inCmd;
	reg [5:0]cmdRead;
	reg [7:0] cmdWrite;
	reg crcIn;
	reg crcEn;
	reg crcRst;
	reg [31:0] CardStatus;
	//following definitions found at http://advdownload.advantech.com/productfile/PIS/96FMMSDI-1G-ET-AT1/Product - Datasheet/96FMMSDI-1G-ET-AT1_datasheet20170331164213.pdf
	reg [15:0] RCA;		//Relative Card Address
	reg [31:0] OCR;		//Operation conditions register
	reg [120:0] CID;	//Card identification number
	reg [120:0] CSD;	//Card specific data, info about  extra features and abilities
	reg Busy; //0 when busy
	reg [4:0] crc_c;
	} cardInfoStruct;

cardInfoStruct cardInfo;

wire [6:0] crcOut;	//cannot put wire in structure, not a variable!








//removed unecessary registers
//reg [3:0] CurrentState;
//reg [3:0] DataCurrentState;


`define RCASTART 16'h2000
`define OCRSTART 32'hff8000
`define STATUSSTART 32'h0
`define CIDSTART 128'hffffffddddddddaaaaaaaa99999999  //Just some random data not really usefull anyway
`define CSDSTART 128'hadaeeeddddddddaaaaaaaa12345678

//Flash delay?
`define outDelay 4
reg [2:0] outDelayCnt;
reg [9:0] flash_write_cnt;
reg [8:0] flash_blockwrite_cnt;

//One hot encoded command states
localparam onehotCommandStates = 4;
typedef enum logic [onehotCommandStates-1:0] {
	IDLE 		= 4'b0001,
	READ_CMD   	= 4'b0010,
	ANALYZE_CMD	= 4'b0100,
	SEND_CMD	= 4'b1000
	} commandStates;

commandStates state, next_state;

//One hot encoded data states
localparam onehotDataStates = 5;
typedef enum logic [onehotDataStates-1:0] {
	DATA_IDLE   	= 5'b00001,
    	READ_WAITS  	= 5'b00010,
   	READ_DATA  	= 5'b00100,
    	WRITE_FLASH 	= 5'b01000,
    	WRITE_DATA  	= 5'b10000
	} dataStates;

dataStates dataState, next_datastate;


parameter okcrctoken = 4'b0101;
parameter invalidcrctoken = 4'b1111;

//use 1 bit
reg ValidCmd;
reg inValidCmd;

reg [7:0] response_S;
reg [135:0] response_CMD;
integer responseType;

     reg [9:0] block_cnt;
     reg wptr;
     reg crc_ok;
     reg [3:0] last_din;


//data read and write enable
reg crcDat_rst;
reg mult_read;
reg mult_write;
reg crcDat_en;
reg [3:0] crcDat_in;
wire [15:0] crcDat_out [3:0];

genvar i;
generate	//4 CRC checkers for each data line?
for(i=0; i<4; i=i+1) begin:CRC_16_gen
  sd_crc_16 CRC_16_i (crcDat_in[i],crcDat_en, sdPin.clk, crcDat_rst, crcDat_out[i]);
end
endgenerate

//crc checker for cmd?
sd_crc_7 crc_7(
	cardInfo.crcIn,
	cardInfo.crcEn,
	sdPin.clk,
	cardInfo.crcRst,
	crcOut
	);

reg stop;

reg appendCrc;
reg [5:0] startUppCnt;

reg q_start_bit;
//Card initinCMd
initial $readmemh("../bin/ramdisk2.hex",FLASHmem);

integer k;
initial begin
	$display("Contents of Mem after reading data file:");
	for (k=0; k<512; k=k+1) $display("%d:%h",k,FLASHmem[k]);
end
reg qCmd;
reg [2:0] crcCnt;

reg add_wrong_cmd_crc;
reg add_wrong_cmd_indx;
reg add_wrong_data_crc;

initial begin
  add_wrong_data_crc<=0;
  add_wrong_cmd_indx<=0;
  add_wrong_cmd_crc<=0;
   stop<=1;
  cardStatus.cardIdentificationState<=1;
  state<=IDLE;
  dataState<=DATA_IDLE;
  cardInfo.Busy<=0;
  sdOut.oeCmd<=0;
  crcCnt<=0;
  cardStatus.CardTransferActive<=0;
  qCmd<=1;
  sdOut.oeDat<=0;
  sdOut.cmdOut<=0;
  cardInfo.cmdWrite<=0;
  memFlash.InbuffStatus<=0;
  sdOut.datOut<=0;
  cardInfo.inCmd<=0;
  cardStatus.BusWidth<=1;
  responseType=0;
  mult_read=0;
  mult_write=0;
  cardInfo.crcIn<=0;
  response_S<=0;
  cardInfo.crcEn<=0;
  cardInfo.crcRst<=0;
  cardInfo.cmdRead<=0;
  ValidCmd<=0;
  inValidCmd<=0;
  appendCrc<=0;
  cardInfo.RCA<= `RCASTART;
  cardInfo.OCR<= `OCRSTART;
  cardInfo.CardStatus <= `STATUSSTART;
  cardInfo.CID<=`CIDSTART;
  cardInfo.CSD<=`CSDSTART;
  response_CMD<=0;
  outDelayCnt<=0;
  crcDat_rst<=1;
  crcDat_en<=0;
  crcDat_in<=0;
  sdOut.transf_cnt<=0;
  memFlash.BlockAddr<=0;
  block_cnt <=0;
  wptr<=0;
  sdOut.transf_cnt<=0;
  crcDat_rst<=1;
  crcDat_en<=0;
  crcDat_in<=0;
  flash_write_cnt<=0;
  startUppCnt<=0;
  flash_blockwrite_cnt<=0;
end

integer f;

initial
	begin
	f = $fopen("sdModel_ValidCmd_log.csv");
	$fwrite(f,"ValidCmd,inValidCmd,outDelayCnt\n");
	//$fmonitor();
	end
final
	begin
	$fclose(f);
	end
//CARD logic

always_comb //@ (state or sdPin.cmd or cardInfo.cmdRead or ValidCmd or inValidCmd or cardInfo.cmdWrite or outDelayCnt)
begin : FSM_COMBO
 //next_state  = 0;
case(state)
IDLE: begin
   if (!sdPin.cmd)
     next_state = READ_CMD;
  else
     next_state = IDLE;
end
READ_CMD: begin
  if (cardInfo.cmdRead>= 47)
     next_state = ANALYZE_CMD;
  else
     next_state =  READ_CMD;
 end
 ANALYZE_CMD: begin
  if ((ValidCmd  )   && (outDelayCnt >= `outDelay ))
     next_state = SEND_CMD;
  else if (inValidCmd)
     next_state =  IDLE;
	
 else
    next_state =  ANALYZE_CMD;
 end
 SEND_CMD: begin
    if (cardInfo.cmdWrite>= response_S)
     next_state = IDLE;
  else
     next_state =  SEND_CMD;

 end


 endcase
end

always_comb // @ (dataState or cardInfo.CardStatus or cardInfo.crc_c or flash_write_cnt or sdPin.data[0] )
begin : FSM_COMBODAT
 //next_datastate  = 0;
case(dataState)
 DATA_IDLE: begin
   if ((cardInfo.CardStatus[12:9]==`RCV) ||  (mult_write == 1'b1) )
     next_datastate = READ_WAITS;
   else if ((cardInfo.CardStatus[12:9]==`DATAS )||  (mult_read == 1'b1) )
     next_datastate = WRITE_DATA;
   else
     next_datastate = DATA_IDLE;
 end

 READ_WAITS: begin
   if ( sdPin.data[0] == 1'b0 )
     next_datastate =  READ_DATA;
   else
     next_datastate =  READ_WAITS;
 end

 READ_DATA : begin
  if (cardInfo.crc_c==0  )
     next_datastate =  WRITE_FLASH;
  else begin
	if (stop == 1'b0)
     next_datastate =  READ_DATA;
    else
     next_datastate =  DATA_IDLE;
    end

 end
  WRITE_FLASH : begin
  if (flash_write_cnt>265 )
     next_datastate =  DATA_IDLE;
  else
     next_datastate =  WRITE_FLASH;

end

  WRITE_DATA : begin
    if (sdOut.transf_cnt >= `BIT_BLOCK)
       next_datastate= DATA_IDLE;
    else
		 begin
			if (stop == 1'b0)
			 next_datastate=WRITE_DATA;
			else
			 next_datastate =  DATA_IDLE;
        end
  end

 endcase
end

always_ff @ (posedge sdPin.clk  )
 begin
	$fwrite(f,"%h,%h,%h\n",ValidCmd,inValidCmd,outDelayCnt);
    q_start_bit <= sdPin.data[0];
 end

always @ (posedge sdPin.clk  )
begin : FSM_SEQ
    state <= next_state;
end

always @ (posedge sdPin.clk  )
begin : FSM_SEQDAT
    dataState <= next_datastate;
end



always @ (posedge sdPin.clk) begin
if (cardStatus.CardTransferActive) begin
 if (memFlash.InbuffStatus==0) //empty
   cardInfo.CardStatus[8]<=1;
  else
   cardInfo.CardStatus[8]<=0;
  end
else
  cardInfo.CardStatus[8]<=1;

 startUppCnt<=startUppCnt+1;
 cardInfo.OCR[31]<=~cardInfo.Busy;
 if (startUppCnt == `TIME_BUSY)
   cardInfo.Busy <=1;
end


always @ (posedge sdPin.clk) begin
   qCmd<=sdPin.cmd;
end

//read data and cmd on rising edge
always @ (posedge sdPin.clk) begin
 case(state)
   IDLE: begin
      mult_write <= 0;
      mult_read <=0;
      cardInfo.crcIn<=0;
      cardInfo.crcEn<=0;
      cardInfo.crcRst<=1;
      sdOut.oeCmd<=0;
      stop<=0;
      cardInfo.cmdRead<=0;
      appendCrc<=0;
      ValidCmd<=0;
      inValidCmd<=0;
      cardInfo.cmdWrite<=0;
      crcCnt<=0;
      response_CMD<=0;
      response_S<=0;
      outDelayCnt<=0;
      responseType=0;
    end
   READ_CMD: begin //read cmd
      cardInfo.crcEn<=1;
      cardInfo.crcRst<=0;
      cardInfo.crcIn <= #`tIH qCmd;
      cardInfo.inCmd[47-cardInfo.cmdRead]  <= #`tIH qCmd;
      cardInfo.cmdRead <= #1 cardInfo.cmdRead+1;
      if (cardInfo.cmdRead >= 40)
         cardInfo.crcEn<=0;

      if (cardInfo.cmdRead == 46) begin
          sdOut.oeCmd<=1;
     sdOut.cmdOut<=1;
      end
   end

   ANALYZE_CMD: begin//check for valid cmd
   //Wrong CRC go idle
    if (cardInfo.inCmd[46] == 0) //start
      inValidCmd<=1;
    else if (cardInfo.inCmd[7:1] != crcOut) begin
      inValidCmd<=1;
      $fdisplay(sdModel_file_desc, "**sd_Model Commando CRC Error") ;
      $display(sdModel_file_desc, "**sd_Model Commando CRC Error") ;
    end
    else if  (cardInfo.inCmd[0] != 1)  begin//stop
      inValidCmd<=1;
      $fdisplay(sdModel_file_desc, "**sd_Model Commando No Stop Bit Error") ;
      $display(sdModel_file_desc, "**sd_Model Commando No Stop Bit Error") ;
    end
    else begin
      if(outDelayCnt ==0)
        cardInfo.CardStatus[3]<=0;
      case(cardInfo.inCmd[45:40])
        0 : response_S <= 0;
        2 : response_S <= 136;
        3 : response_S <= 48;
        7 : response_S <= 48;
        8 : response_S <= 0;
        9 : response_S <= 136;
        14 : response_S <= 0;
        16 : response_S <= 48;
        17 : response_S <= 48;
	18 : response_S <= 48;
        24 : response_S <= 48;
	25 : response_S <= 48;
        33 : response_S <= 48;
        55 : response_S <= 48;
        41 : response_S <= 48;
    endcase
         case(cardInfo.inCmd[45:40])
        0 : begin
            response_CMD <= 0;
            cardStatus.cardIdentificationState<=1;
            ResetCard;
        end
        2 : begin
         if (cardStatus.lastCMD != 41 && outDelayCnt==0) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               //$display(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               cardInfo.CardStatus[3]<=1;
            end
        response_CMD[127:8] <= cardInfo.CID;
        appendCrc<=0;
        cardInfo.CardStatus[12:9] <=2;
        end
        3 :  begin
           if (cardStatus.lastCMD != 2 && outDelayCnt==0 ) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, CMD 2 should precede 3 in Startup state") ;
               //$display(sdModel_file_desc, "**Error in sequnce, CMD 2 should precede 3 in Startup state") ;
               cardInfo.CardStatus[3]<=1;
            end
        response_CMD[127:112] <= cardInfo.RCA[15:0] ;
        response_CMD[111:96] <= cardInfo.CardStatus[15:0] ;
        appendCrc<=1;
        cardInfo.CardStatus[12:9] <=3;
        cardStatus.cardIdentificationState<=0;
       end
        6 : begin
           if (cardStatus.lastCMD == 55 && outDelayCnt==0) begin
              if (cardInfo.inCmd[9:8] == 2'b10) begin
               cardStatus.BusWidth <=4;
                    $display(sdModel_file_desc, "**BUS WIDTH 4 ") ;
               end
              else
               cardStatus.BusWidth <=1;

              response_S<=48;
              response_CMD[127:96] <= cardInfo.CardStatus;
           end
           else if (outDelayCnt==0)begin
             response_CMD <= 0;
             response_S<=0;
             $fdisplay(sdModel_file_desc, "**Error Invalid CMD, %h",cardInfo.inCmd[45:40]) ;
           //  $display(sdModel_file_desc, "**Error Invalid CMD, %h",cardInfo.inCmd[45:40]) ;
            end
        end
        7: begin
         if (outDelayCnt==0) begin
          if (cardInfo.inCmd[39:24]== cardInfo.RCA[15:0]) begin
              cardStatus.CardTransferActive <= 1;
              response_CMD[127:96] <= cardInfo.CardStatus ;
              cardInfo.CardStatus[12:9] <=`TRAN;
          end
          else begin
               cardStatus.CardTransferActive <= 0;
               response_CMD[127:96] <= cardInfo.CardStatus ;
               cardInfo.CardStatus[12:9] <=3;
          end
         end
        end
        8 : response_CMD[127:96] <= 0; //V1.0 card

		9 : begin
         if (cardStatus.lastCMD != 41 && outDelayCnt==0) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               //$display(sdModel_file_desc, "**Error in sequnce, ACMD 41 should precede 2 in Startup state") ;
               cardInfo.CardStatus[3]<=1;
            end
        response_CMD[127:8] <= cardInfo.CSD;
        appendCrc<=0;
        cardInfo.CardStatus[12:9] <=2;
        end

		  12: begin
          response_CMD[127:96] <= cardInfo.CardStatus ;
          stop<=1;
		  mult_write <= 0;
          mult_read <=0;
         cardInfo.CardStatus[12:9] <= `TRAN;
        end


        16 : begin
          response_CMD[127:96] <= cardInfo.CardStatus ;

        end





        17 :  begin
          if (outDelayCnt==0) begin
            if (cardInfo.CardStatus[12:9] == `TRAN) begin //If card is in transferstate
                cardInfo.CardStatus[12:9] <=`DATAS;//Put card in data state
                response_CMD[127:96] <= cardInfo.CardStatus ;
                memFlash.BlockAddr = cardInfo.inCmd[39:8];
                assert (memFlash.BlockAddr%512 == 0) else $error("**Block Misalign Error");
		//if (memFlash.BlockAddr%512 !=0)
                  //$display("**Block Misalign Error");
          end
           else begin
             response_S <= 0;
             response_CMD[127:96] <= 0;
           end
         end

       end

     18 :  begin
          if (outDelayCnt==0) begin
            if (cardInfo.CardStatus[12:9] == `TRAN) begin //If card is in transferstate
                cardInfo.CardStatus[12:9] <=`DATAS;//Put card in data state
                response_CMD[127:96] <= cardInfo.CardStatus ;
			    mult_read <= 1;
                memFlash.BlockAddr = cardInfo.inCmd[39:8];
		assert (memFlash.BlockAddr%512 == 0) else $error("**Block Misalign Error");
                //if (memFlash.BlockAddr%512 !=0)
                  //$display("**Block Misalign Error");
          end
           else begin
             response_S <= 0;
             response_CMD[127:96] <= 0;

           end
         end

       end

        24 : begin
          if (outDelayCnt==0) begin
            if (cardInfo.CardStatus[12:9] == `TRAN) begin //If card is in transferstate
              if (cardInfo.CardStatus[8]) begin //If Free write buffer
                cardInfo.CardStatus[12:9] <=`RCV;//Put card in Rcv state
                response_CMD[127:96] <= cardInfo.CardStatus ;
                memFlash.BlockAddr = cardInfo.inCmd[39:8];
                if (memFlash.BlockAddr%512 !=0)
                  assert (memFlash.BlockAddr%512 == 0) else $error("**Block Misalign Error");
                //if (memFlash.BlockAddr%512 !=0)
                  //$display("**Block Misalign Error");
              end
              else begin
                response_CMD[127:96] <= cardInfo.CardStatus;
                $fdisplay(sdModel_file_desc, "**Error Try to blockwrite when No Free Writebuffer") ;
                $error("Try to blockwrite when No Free Writebuffer");
		//$display("**Error Try to blockwrite when No Free Writebuffer") ;
             end
           end
           else begin
             response_S <= 0;
             response_CMD[127:96] <= 0;
           end
         end
       end
        25 : begin
          if (outDelayCnt==0) begin
            if (cardInfo.CardStatus[12:9] == `TRAN) begin //If card is in transferstate
              if (cardInfo.CardStatus[8]) begin //If Free write buffer
                cardInfo.CardStatus[12:9] <=`RCV;//Put card in Rcv state
                response_CMD[127:96] <= cardInfo.CardStatus ;
                memFlash.BlockAddr = cardInfo.inCmd[39:8];
				mult_write <= 1;
                if (memFlash.BlockAddr%512 !=0)
                  assert (memFlash.BlockAddr%512 == 0) else $error("**Block Misalign Error");
                //if (memFlash.BlockAddr%512 !=0)
                  //$display("**Block Misalign Error");
              end
              else begin
                response_CMD[127:96] <= cardInfo.CardStatus;
                 $fdisplay(sdModel_file_desc, "**Error Try to blockwrite when No Free Writebuffer") ;
                 $error("Try to blockwrite when No Free Writebuffer");
		//$display("**Error Try to blockwrite when No Free Writebuffer") ;
             end
           end
           else begin
             response_S <= 0;
             response_CMD[127:96] <= 0;
           end
         end
       end

        33 : response_CMD[127:96] <= 48;
        55 :
        begin
          response_CMD[127:96] <= cardInfo.CardStatus ;
          cardInfo.CardStatus[5] <=1;      //Next CMD is AP specific CMD
          appendCrc<=1;
        end
        41 :
        begin
         if (cardStatus.cardIdentificationState) begin
            if (cardStatus.lastCMD != 55 && outDelayCnt==0) begin
               $fdisplay(sdModel_file_desc, "**Error in sequnce, CMD 55 should precede 41 in Startup state") ;
               $error( "**Error in sequnce, CMD 55 should precede 41 in Startup state") ;
               cardInfo.CardStatus[3]<=1;
            end
            else begin
             responseType=3;
             response_CMD[127:96] <= cardInfo.OCR;
             appendCrc<=0;
             cardInfo.CardStatus[5] <=0;
            if (cardInfo.Busy==1)
              cardInfo.CardStatus[12:9] <=1;
           end
        end
       end

    endcase
     ValidCmd<=1;
     cardInfo.crcIn<=0;

     outDelayCnt<=outDelayCnt+1;
     if (outDelayCnt==`outDelay)
       cardInfo.crcRst<=1;
     sdOut.oeCmd<=1;
     sdOut.cmdOut<=1;
     response_CMD[135:134] <=0;

    if (responseType != 3)
       if (!add_wrong_cmd_indx)
         response_CMD[133:128] <=cardInfo.inCmd[45:40];
      else
         response_CMD[133:128] <=0;

    if (responseType == 3)
       response_CMD[133:128] <=6'b111111;

     cardStatus.lastCMD <=cardInfo.inCmd[45:40];
    end
   end



 endcase
end

always @ ( negedge sdPin.clk) begin
 case(state)

SEND_CMD: begin
     cardInfo.crcRst<=0;
     cardInfo.crcEn<=1;
    cardInfo.cmdWrite<=cardInfo.cmdWrite+1;
    if (response_S!=0)
     sdOut.cmdOut<=0;
   else
      sdOut.cmdOut<=1;

    if ((cardInfo.cmdWrite>0) &&  (cardInfo.cmdWrite < response_S-8)) begin
      sdOut.cmdOut<=response_CMD[135-cardInfo.cmdWrite];
      cardInfo.crcIn<=response_CMD[134-cardInfo.cmdWrite];
      if (cardInfo.cmdWrite >= response_S-9)
       cardInfo.crcEn<=0;
    end
   else if (cardInfo.cmdWrite!=0) begin
     cardInfo.crcEn<=0;
     if (add_wrong_cmd_crc) begin
        sdOut.cmdOut<=0;
        crcCnt<=crcCnt+1;
     end
     else begin
     sdOut.cmdOut<=crcOut[6-crcCnt];
     crcCnt<=crcCnt+1;
     if (responseType == 3)
           sdOut.cmdOut<=1;
    end
   end
  if (cardInfo.cmdWrite == response_S-1)
    sdOut.cmdOut<=1;

  end
 endcase
end

integer outdly_cnt;

always @ (posedge sdPin.clk) begin

  case (dataState)
  DATA_IDLE: begin

     crcDat_rst<=1;
     crcDat_en<=0;
     crcDat_in<=0;

  end

  READ_WAITS: begin
      sdOut.oeDat<=0;
      crcDat_rst<=0;
      crcDat_en<=1;
      crcDat_in<=0;
      cardInfo.crc_c<=15;//
      crc_ok<=1;
  end
  READ_DATA: begin


    memFlash.InbuffStatus<=1;
    if (sdOut.transf_cnt<`BIT_BLOCK_REC) begin
       if (wptr)
         memFlash.Inbuff[block_cnt][3:0] <= sdPin.data;
       else
          memFlash.Inbuff[block_cnt][7:4] <= sdPin.data;

       if (!add_wrong_data_crc)
          crcDat_in<=sdPin.data;
        else
          crcDat_in<=4'b1010;

       crc_ok<=1;
       sdOut.transf_cnt<=sdOut.transf_cnt+1;
       if (wptr)
         block_cnt<=block_cnt+1;
       wptr<=~wptr;


    end
    else if  ( sdOut.transf_cnt <= (`BIT_BLOCK_REC +`BIT_CRC_CYCLE-1)) begin
       sdOut.transf_cnt<=sdOut.transf_cnt+1;
       crcDat_en<=0;
       last_din <=sdPin.data;

       if (sdOut.transf_cnt> `BIT_BLOCK_REC) begin
        cardInfo.crc_c<=cardInfo.crc_c-1;

          if (crcDat_out[0][cardInfo.crc_c] != last_din[0])
           crc_ok<=0;
          if  (crcDat_out[1][cardInfo.crc_c] != last_din[1])
           crc_ok<=0;
          if  (crcDat_out[2][cardInfo.crc_c] != last_din[2])
           crc_ok<=0;
          if  (crcDat_out[3][cardInfo.crc_c] != last_din[3])
           crc_ok<=0;
      end
    end
  end
  WRITE_FLASH: begin
     sdOut.oeDat<=1;
     block_cnt <=0;
     wptr<=0;
     sdOut.transf_cnt<=0;
     crcDat_rst<=1;
     crcDat_en<=0;
     crcDat_in<=0;


  end

  endcase


end



reg data_send_index;
integer write_out_index;
always @ (negedge sdPin.clk) begin

  case (dataState)
  DATA_IDLE: begin
     write_out_index<=0;
     sdOut.transf_cnt<=0;
     data_send_index<=0;
     outdly_cnt<=0;
     flash_write_cnt<=0;
  end


   WRITE_DATA: begin
      sdOut.oeDat<=1;
      outdly_cnt<=outdly_cnt+1;

      if ( outdly_cnt > `DLY_TO_OUTP) begin
         sdOut.transf_cnt <= sdOut.transf_cnt+1;
         crcDat_en<=1;
         crcDat_rst<=0;

      end
      else begin
        crcDat_en<=0;
        crcDat_rst<=1;
        sdOut.oeDat<=1;
        cardInfo.crc_c<=16;
     end

       if (sdOut.transf_cnt==1) begin

          last_din <= FLASHmem[memFlash.BlockAddr+(write_out_index)][7:4];
          sdOut.datOut<=0;
          crcDat_in<= FLASHmem[memFlash.BlockAddr+(write_out_index)][7:4];
          data_send_index<=1;
        end
        else if ( (sdOut.transf_cnt>=2) && (sdOut.transf_cnt<=`BIT_BLOCK-`CRC_OFF )) begin
          data_send_index<=~data_send_index;
          if (!data_send_index) begin
             last_din<=FLASHmem[memFlash.BlockAddr+(write_out_index)][7:4];
             crcDat_in<= FLASHmem[memFlash.BlockAddr+(write_out_index)][7:4];
          end
          else begin
             last_din<=FLASHmem[memFlash.BlockAddr+(write_out_index)][3:0];
             if (!add_wrong_data_crc)
               crcDat_in<= FLASHmem[memFlash.BlockAddr+(write_out_index)][3:0];
             else
               crcDat_in<=4'b1010;
             write_out_index<=write_out_index+1;

         end


          sdOut.datOut<= last_din;


          if ( sdOut.transf_cnt >=`BIT_BLOCK-`CRC_OFF ) begin
             crcDat_en<=0;
         end

       end
       else if (sdOut.transf_cnt>`BIT_BLOCK-`CRC_OFF & cardInfo.crc_c!=0) begin
         sdOut.datOut<= last_din;
         crcDat_en<=0;
         cardInfo.crc_c<=cardInfo.crc_c-1;
         if (cardInfo.crc_c<= 16) begin
         sdOut.datOut[0]<=crcDat_out[0][cardInfo.crc_c-1];
         sdOut.datOut[1]<=crcDat_out[1][cardInfo.crc_c-1];
         sdOut.datOut[2]<=crcDat_out[2][cardInfo.crc_c-1];
         sdOut.datOut[3]<=crcDat_out[3][cardInfo.crc_c-1];
       end
       end
       else if (sdOut.transf_cnt==`BIT_BLOCK-2) begin
          sdOut.datOut<=4'b1111;
      end
       else if ((sdOut.transf_cnt !=0) && (cardInfo.crc_c == 0 ))begin
         sdOut.oeDat<=0;
         cardInfo.CardStatus[12:9] <= `TRAN;
         end



  end



  WRITE_FLASH: begin
    flash_write_cnt<=flash_write_cnt+1;
     cardInfo.CardStatus[12:9] <= `PRG;
      sdOut.datOut[0]<=0;
       sdOut.datOut[1]<=1;
       sdOut.datOut[2]<=1;
       sdOut.datOut[3]<=1;
    if (flash_write_cnt == 0)
      sdOut.datOut<=1;
    else if(flash_write_cnt == 1)
     sdOut.datOut[0]<=1;
    else if(flash_write_cnt == 2)
     sdOut.datOut[0]<=0;


    else if ((flash_write_cnt > 2) && (flash_write_cnt < 7)) begin
      if (crc_ok)
        sdOut.datOut[0] <=okcrctoken[6-flash_write_cnt];
      else
        sdOut.datOut[0] <= invalidcrctoken[6-flash_write_cnt];
    end
    else if  ((flash_write_cnt >= 7) && (flash_write_cnt < 264)) begin
       sdOut.datOut[0]<=0;

      flash_blockwrite_cnt<=flash_blockwrite_cnt+2;
       FLASHmem[memFlash.BlockAddr+(flash_blockwrite_cnt)]<=memFlash.Inbuff[flash_blockwrite_cnt];
       FLASHmem[memFlash.BlockAddr+(flash_blockwrite_cnt+1)]<=memFlash.Inbuff[flash_blockwrite_cnt+1];

    end
    else begin
      sdOut.datOut<=1;
      memFlash.InbuffStatus<=0;
      cardInfo.CardStatus[12:9] <= `TRAN;
    end
  end
endcase
end

integer sdModel_file_desc;

initial
begin
  sdModel_file_desc = $fopen("../log/sd_model.log");
  if (sdModel_file_desc < 2)
  begin
	$fatal("Could not open/create testbench log file in /log/ directory!");
    //$display("*E Could not open/create testbench log file in /log/ directory!");
    //$finish;
  end
end

task ResetCard; //  MAC registers
begin
   add_wrong_data_crc<=0;
  add_wrong_cmd_indx<=0;
  add_wrong_cmd_crc<=0;
 cardStatus.cardIdentificationState<=1;
  state<=IDLE;
  dataState<=DATA_IDLE;
  cardInfo.Busy<=0;
  sdOut.oeCmd<=0;
  crcCnt<=0;
  cardStatus.CardTransferActive<=0;
  qCmd<=1;
  sdOut.oeDat<=0;
  sdOut.cmdOut<=0;
  cardInfo.cmdWrite<=0;
  startUppCnt<=0;
  memFlash.InbuffStatus<=0;
  sdOut.datOut<=0;
  cardInfo.inCmd<=0;
  cardStatus.BusWidth<=1;
  responseType=0;
  cardInfo.crcIn<=0;
  response_S<=0;
  cardInfo.crcEn<=0;
  cardInfo.crcRst<=0;
  cardInfo.cmdRead<=0;
  ValidCmd<=0;
  inValidCmd<=0;
  appendCrc<=0;
  cardInfo.RCA<= `RCASTART;
  cardInfo.OCR<= `OCRSTART;
  cardInfo.CardStatus <= `STATUSSTART;
  cardInfo.CID<=`CIDSTART;
  cardInfo.CSD<=`CSDSTART;
  response_CMD<=0;
  outDelayCnt<=0;
  crcDat_rst<=1;
  crcDat_en<=0;
  crcDat_in<=0;
  sdOut.transf_cnt<=0;
  memFlash.BlockAddr<=0;
  block_cnt <=0;
     wptr<=0;
     sdOut.transf_cnt<=0;
     crcDat_rst<=1;
     crcDat_en<=0;
     crcDat_in<=0;
flash_write_cnt<=0;
flash_blockwrite_cnt<=0;
end
endtask


property cmd;
@(posedge sdPin.clk) //disable iff (reset || clear)
   (state == ANALYZE_CMD) |=> inValidCmd;//##[1:400] qCmd;//|=> count == $past(din);
endproperty
assert_cmd: assert property(cmd) else $warning("Invalid command!");

endmodule
