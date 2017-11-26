-- VHDL netlist generated by SCUBA ispLever_v8.0_PROD_Build (41)
-- Module  Version: 7.1
--D:\ispTOOLS8_0\ispfpga\bin\nt\scuba.exe -w -lang vhdl -synth synplify -bus_exp 7 -bb -arch mj5g00 -type bram -wp 11 -rp 1010 -data_width 8 -rdata_width 8 -num_rows 2048 -outdataA REGISTERED -outdataB REGISTERED -writemodeA NORMAL -writemodeB NORMAL -resetmode ASYNC -cascade -1 -e 

-- Mon Jan 11 16:21:07 2010

library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library MACHXO;
use MACHXO.components.all;
-- synopsys translate_on

entity ebr_buffer is
    port (
        DataInA: in  std_logic_vector(7 downto 0); 
        DataInB: in  std_logic_vector(7 downto 0); 
        AddressA: in  std_logic_vector(10 downto 0); 
        AddressB: in  std_logic_vector(10 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        ResetA: in  std_logic; 
        ResetB: in  std_logic; 
        QA: out  std_logic_vector(7 downto 0); 
        QB: out  std_logic_vector(7 downto 0));
end ebr_buffer;

architecture Structure of ebr_buffer is

    -- internal signal declarations
    signal scuba_vhi: std_logic;
    signal scuba_vlo: std_logic;

    -- local component declarations
    component VHI
        port (Z: out  std_logic);
    end component;
    component VLO
        port (Z: out  std_logic);
    end component;
    component DP8KB
    -- synopsys translate_off
        generic (DATA_WIDTH_B : in Integer; DATA_WIDTH_A : in Integer; 
                CSDECODE_B : in std_logic_vector(2 downto 0); 
                CSDECODE_A : in std_logic_vector(2 downto 0); 
                RESETMODE : in String; WRITEMODE_B : in String; 
                WRITEMODE_A : in String; GSR : in String; 
                REGMODE_B : in String; REGMODE_A : in String);
    -- synopsys translate_on
        port (CEA: in  std_logic; CLKA: in  std_logic; 
            WEA: in  std_logic; CSA0: in  std_logic; CSA1: in  std_logic; 
            CSA2: in  std_logic; RSTA: in  std_logic; CEB: in  std_logic; 
            CLKB: in  std_logic; WEB: in  std_logic; CSB0: in  std_logic; 
            CSB1: in  std_logic; CSB2: in  std_logic; 
            RSTB: in  std_logic; DIA0: in  std_logic; 
            DIA1: in  std_logic; DIA2: in  std_logic; 
            DIA3: in  std_logic; DIA4: in  std_logic; 
            DIA5: in  std_logic; DIA6: in  std_logic; 
            DIA7: in  std_logic; DIA8: in  std_logic; 
            DIA9: in  std_logic; DIA10: in  std_logic; 
            DIA11: in  std_logic; DIA12: in  std_logic; 
            DIA13: in  std_logic; DIA14: in  std_logic; 
            DIA15: in  std_logic; DIA16: in  std_logic; 
            DIA17: in  std_logic; ADA0: in  std_logic; 
            ADA1: in  std_logic; ADA2: in  std_logic; 
            ADA3: in  std_logic; ADA4: in  std_logic; 
            ADA5: in  std_logic; ADA6: in  std_logic; 
            ADA7: in  std_logic; ADA8: in  std_logic; 
            ADA9: in  std_logic; ADA10: in  std_logic; 
            ADA11: in  std_logic; ADA12: in  std_logic; 
            DIB0: in  std_logic; DIB1: in  std_logic; 
            DIB2: in  std_logic; DIB3: in  std_logic; 
            DIB4: in  std_logic; DIB5: in  std_logic; 
            DIB6: in  std_logic; DIB7: in  std_logic; 
            DIB8: in  std_logic; DIB9: in  std_logic; 
            DIB10: in  std_logic; DIB11: in  std_logic; 
            DIB12: in  std_logic; DIB13: in  std_logic; 
            DIB14: in  std_logic; DIB15: in  std_logic; 
            DIB16: in  std_logic; DIB17: in  std_logic; 
            ADB0: in  std_logic; ADB1: in  std_logic; 
            ADB2: in  std_logic; ADB3: in  std_logic; 
            ADB4: in  std_logic; ADB5: in  std_logic; 
            ADB6: in  std_logic; ADB7: in  std_logic; 
            ADB8: in  std_logic; ADB9: in  std_logic; 
            ADB10: in  std_logic; ADB11: in  std_logic; 
            ADB12: in  std_logic; DOA0: out  std_logic; 
            DOA1: out  std_logic; DOA2: out  std_logic; 
            DOA3: out  std_logic; DOA4: out  std_logic; 
            DOA5: out  std_logic; DOA6: out  std_logic; 
            DOA7: out  std_logic; DOA8: out  std_logic; 
            DOA9: out  std_logic; DOA10: out  std_logic; 
            DOA11: out  std_logic; DOA12: out  std_logic; 
            DOA13: out  std_logic; DOA14: out  std_logic; 
            DOA15: out  std_logic; DOA16: out  std_logic; 
            DOA17: out  std_logic; DOB0: out  std_logic; 
            DOB1: out  std_logic; DOB2: out  std_logic; 
            DOB3: out  std_logic; DOB4: out  std_logic; 
            DOB5: out  std_logic; DOB6: out  std_logic; 
            DOB7: out  std_logic; DOB8: out  std_logic; 
            DOB9: out  std_logic; DOB10: out  std_logic; 
            DOB11: out  std_logic; DOB12: out  std_logic; 
            DOB13: out  std_logic; DOB14: out  std_logic; 
            DOB15: out  std_logic; DOB16: out  std_logic; 
            DOB17: out  std_logic);
    end component;
    attribute MEM_LPC_FILE : string; 
    attribute MEM_INIT_FILE : string; 
    attribute CSDECODE_B : string; 
    attribute CSDECODE_A : string; 
    attribute WRITEMODE_B : string; 
    attribute WRITEMODE_A : string; 
    attribute GSR : string; 
    attribute RESETMODE : string; 
    attribute REGMODE_B : string; 
    attribute REGMODE_A : string; 
    attribute DATA_WIDTH_B : string; 
    attribute DATA_WIDTH_A : string; 
    attribute MEM_LPC_FILE of ebr_buffer_0_0_1 : label is "ebr_buffer.lpc";
    attribute MEM_INIT_FILE of ebr_buffer_0_0_1 : label is "";
    attribute CSDECODE_B of ebr_buffer_0_0_1 : label is "0b000";
    attribute CSDECODE_A of ebr_buffer_0_0_1 : label is "0b000";
    attribute WRITEMODE_B of ebr_buffer_0_0_1 : label is "NORMAL";
    attribute WRITEMODE_A of ebr_buffer_0_0_1 : label is "NORMAL";
    attribute GSR of ebr_buffer_0_0_1 : label is "DISABLED";
    attribute RESETMODE of ebr_buffer_0_0_1 : label is "ASYNC";
    attribute REGMODE_B of ebr_buffer_0_0_1 : label is "OUTREG";
    attribute REGMODE_A of ebr_buffer_0_0_1 : label is "OUTREG";
    attribute DATA_WIDTH_B of ebr_buffer_0_0_1 : label is "4";
    attribute DATA_WIDTH_A of ebr_buffer_0_0_1 : label is "4";
    attribute MEM_LPC_FILE of ebr_buffer_0_1_0 : label is "ebr_buffer.lpc";
    attribute MEM_INIT_FILE of ebr_buffer_0_1_0 : label is "";
    attribute CSDECODE_B of ebr_buffer_0_1_0 : label is "0b000";
    attribute CSDECODE_A of ebr_buffer_0_1_0 : label is "0b000";
    attribute WRITEMODE_B of ebr_buffer_0_1_0 : label is "NORMAL";
    attribute WRITEMODE_A of ebr_buffer_0_1_0 : label is "NORMAL";
    attribute GSR of ebr_buffer_0_1_0 : label is "DISABLED";
    attribute RESETMODE of ebr_buffer_0_1_0 : label is "ASYNC";
    attribute REGMODE_B of ebr_buffer_0_1_0 : label is "OUTREG";
    attribute REGMODE_A of ebr_buffer_0_1_0 : label is "OUTREG";
    attribute DATA_WIDTH_B of ebr_buffer_0_1_0 : label is "4";
    attribute DATA_WIDTH_A of ebr_buffer_0_1_0 : label is "4";

begin
    -- component instantiation statements
    scuba_vhi_inst: VHI
        port map (Z=>scuba_vhi);

    ebr_buffer_0_0_1: DP8KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "000", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "ASYNC", 
        REGMODE_B=> "OUTREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  4, 
        DATA_WIDTH_A=>  4)
        -- synopsys translate_on
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>scuba_vlo, 
            CSA1=>scuba_vlo, CSA2=>scuba_vlo, RSTA=>ResetA, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>scuba_vlo, 
            CSB1=>scuba_vlo, CSB2=>scuba_vlo, RSTB=>ResetB, 
            DIA0=>DataInA(0), DIA1=>DataInA(1), DIA2=>DataInA(2), 
            DIA3=>DataInA(3), DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>scuba_vlo, 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>scuba_vlo, ADA2=>AddressA(0), 
            ADA3=>AddressA(1), ADA4=>AddressA(2), ADA5=>AddressA(3), 
            ADA6=>AddressA(4), ADA7=>AddressA(5), ADA8=>AddressA(6), 
            ADA9=>AddressA(7), ADA10=>AddressA(8), ADA11=>AddressA(9), 
            ADA12=>AddressA(10), DIB0=>DataInB(0), DIB1=>DataInB(1), 
            DIB2=>DataInB(2), DIB3=>DataInB(3), DIB4=>scuba_vlo, 
            DIB5=>scuba_vlo, DIB6=>scuba_vlo, DIB7=>scuba_vlo, 
            DIB8=>scuba_vlo, DIB9=>scuba_vlo, DIB10=>scuba_vlo, 
            DIB11=>scuba_vlo, DIB12=>scuba_vlo, DIB13=>scuba_vlo, 
            DIB14=>scuba_vlo, DIB15=>scuba_vlo, DIB16=>scuba_vlo, 
            DIB17=>scuba_vlo, ADB0=>scuba_vlo, ADB1=>scuba_vlo, 
            ADB2=>AddressB(0), ADB3=>AddressB(1), ADB4=>AddressB(2), 
            ADB5=>AddressB(3), ADB6=>AddressB(4), ADB7=>AddressB(5), 
            ADB8=>AddressB(6), ADB9=>AddressB(7), ADB10=>AddressB(8), 
            ADB11=>AddressB(9), ADB12=>AddressB(10), DOA0=>QA(0), 
            DOA1=>QA(1), DOA2=>QA(2), DOA3=>QA(3), DOA4=>open, 
            DOA5=>open, DOA6=>open, DOA7=>open, DOA8=>open, DOA9=>open, 
            DOA10=>open, DOA11=>open, DOA12=>open, DOA13=>open, 
            DOA14=>open, DOA15=>open, DOA16=>open, DOA17=>open, 
            DOB0=>QB(0), DOB1=>QB(1), DOB2=>QB(2), DOB3=>QB(3), 
            DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, DOB8=>open, 
            DOB9=>open, DOB10=>open, DOB11=>open, DOB12=>open, 
            DOB13=>open, DOB14=>open, DOB15=>open, DOB16=>open, 
            DOB17=>open);

    scuba_vlo_inst: VLO
        port map (Z=>scuba_vlo);

    ebr_buffer_0_1_0: DP8KB
        -- synopsys translate_off
        generic map (CSDECODE_B=> "000", CSDECODE_A=> "000", WRITEMODE_B=> "NORMAL", 
        WRITEMODE_A=> "NORMAL", GSR=> "DISABLED", RESETMODE=> "ASYNC", 
        REGMODE_B=> "OUTREG", REGMODE_A=> "OUTREG", DATA_WIDTH_B=>  4, 
        DATA_WIDTH_A=>  4)
        -- synopsys translate_on
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>scuba_vlo, 
            CSA1=>scuba_vlo, CSA2=>scuba_vlo, RSTA=>ResetA, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>scuba_vlo, 
            CSB1=>scuba_vlo, CSB2=>scuba_vlo, RSTB=>ResetB, 
            DIA0=>DataInA(4), DIA1=>DataInA(5), DIA2=>DataInA(6), 
            DIA3=>DataInA(7), DIA4=>scuba_vlo, DIA5=>scuba_vlo, 
            DIA6=>scuba_vlo, DIA7=>scuba_vlo, DIA8=>scuba_vlo, 
            DIA9=>scuba_vlo, DIA10=>scuba_vlo, DIA11=>scuba_vlo, 
            DIA12=>scuba_vlo, DIA13=>scuba_vlo, DIA14=>scuba_vlo, 
            DIA15=>scuba_vlo, DIA16=>scuba_vlo, DIA17=>scuba_vlo, 
            ADA0=>scuba_vlo, ADA1=>scuba_vlo, ADA2=>AddressA(0), 
            ADA3=>AddressA(1), ADA4=>AddressA(2), ADA5=>AddressA(3), 
            ADA6=>AddressA(4), ADA7=>AddressA(5), ADA8=>AddressA(6), 
            ADA9=>AddressA(7), ADA10=>AddressA(8), ADA11=>AddressA(9), 
            ADA12=>AddressA(10), DIB0=>DataInB(4), DIB1=>DataInB(5), 
            DIB2=>DataInB(6), DIB3=>DataInB(7), DIB4=>scuba_vlo, 
            DIB5=>scuba_vlo, DIB6=>scuba_vlo, DIB7=>scuba_vlo, 
            DIB8=>scuba_vlo, DIB9=>scuba_vlo, DIB10=>scuba_vlo, 
            DIB11=>scuba_vlo, DIB12=>scuba_vlo, DIB13=>scuba_vlo, 
            DIB14=>scuba_vlo, DIB15=>scuba_vlo, DIB16=>scuba_vlo, 
            DIB17=>scuba_vlo, ADB0=>scuba_vlo, ADB1=>scuba_vlo, 
            ADB2=>AddressB(0), ADB3=>AddressB(1), ADB4=>AddressB(2), 
            ADB5=>AddressB(3), ADB6=>AddressB(4), ADB7=>AddressB(5), 
            ADB8=>AddressB(6), ADB9=>AddressB(7), ADB10=>AddressB(8), 
            ADB11=>AddressB(9), ADB12=>AddressB(10), DOA0=>QA(4), 
            DOA1=>QA(5), DOA2=>QA(6), DOA3=>QA(7), DOA4=>open, 
            DOA5=>open, DOA6=>open, DOA7=>open, DOA8=>open, DOA9=>open, 
            DOA10=>open, DOA11=>open, DOA12=>open, DOA13=>open, 
            DOA14=>open, DOA15=>open, DOA16=>open, DOA17=>open, 
            DOB0=>QB(4), DOB1=>QB(5), DOB2=>QB(6), DOB3=>QB(7), 
            DOB4=>open, DOB5=>open, DOB6=>open, DOB7=>open, DOB8=>open, 
            DOB9=>open, DOB10=>open, DOB11=>open, DOB12=>open, 
            DOB13=>open, DOB14=>open, DOB15=>open, DOB16=>open, 
            DOB17=>open);

end Structure;

-- synopsys translate_off
library MACHXO;
configuration Structure_CON of ebr_buffer is
    for Structure
        for all:VHI use entity MACHXO.VHI(V); end for;
        for all:VLO use entity MACHXO.VLO(V); end for;
        for all:DP8KB use entity MACHXO.DP8KB(V); end for;
    end for;
end Structure_CON;

-- synopsys translate_on