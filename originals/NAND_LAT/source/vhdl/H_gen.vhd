---------------------------------------------------------------------------
--  >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
---------------------------------------------------------------------------
--  Copyright (c) 2010 by Lattice Semiconductor Corporation      
-- 
---------------------------------------------------------------------------
-- Permission:
--
--   Lattice Semiconductor grants permission to use this code for use
--   in synthesis for any Lattice programmable logic product.  Other
--   use of this code, including the selling or duplication of any
--   portion is strictly prohibited.
--
-- Disclaimer:
--
--   This VHDL or Verilog source code is intended as a design reference
--   which illustrates how these types of functions can be implemented.
--   It is the user's responsibility to verify their design for
--   consistency and functionality through the use of formal
--   verification methods.  Lattice Semiconductor provides no warranty
--   regarding the use or functionality of this code.
---------------------------------------------------------------------------
--
--    Lattice Semiconductor Corporation
--    5555 NE Moore Court
--    Hillsboro, OR 97124
--    U.S.A
--
--    TEL: 1-800-Lattice (USA and Canada)
--    503-268-8001 (other locations)
--
--    web: http://www.latticesemi.com/
--    email: techsupport@latticesemi.com
-- 
---------------------------------------------------------------------------
--
-- Revision History :
-- --------------------------------------------------------------------
--   Ver  :| Author       :| Mod. Date :| Changes Made:
--   V01.0:| Rainy Zhang  :| 01/14/10  :| Initial ver
-- --------------------------------------------------------------------
--
-- 
--Description of module:
----------------------------------------------------------------------------------
-- (7,4) hamming code
-- --------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
   
ENTITY H_gen IS 
       PORT (
       clk      : in std_logic;
       Res      : in std_logic;
       Din      : in std_logic_vector(3 downto 0);
       EN       : in std_logic;

       eccByte  : out std_logic_vector(7 downto 0)
       );
END ENTITY H_gen;


 ARCHITECTURE translated of H_gen IS
   signal rp1 : std_logic;
   signal rp2 : std_logic;
   signal rp3 : std_logic;
   signal ecc : std_logic_vector(7 downto 0);
    BEGIN
     
      rp1 <= '1' when ((Din(3) xor Din(2) xor Din(0)) = '1')  ELSE '0';
      rp2 <= '1' when ((Din(3) xor Din(1) xor Din(0)) = '1')  ELSE '0';
      rp3 <= '1' when ((Din(2) xor Din(1) xor Din(0)) = '1')  ELSE '0';

      ecc(7) <= '0';
      ecc(6) <= rp1;
      ecc(5) <= rp2;
      ecc(4) <= Din(3);
      ecc(3) <= rp3;
      ecc(2) <= Din(2);
      ecc(1) <= Din(1);
      ecc(0) <= Din(0);

   PROCESS (clk, Res)
    BEGIN
      IF (Res = '1') THEN
         eccByte <= "00000000";
      ELSIF (clk'event and clk = '1') THEN
        IF (EN = '1') THEN
           eccByte <= ecc;
        END IF;
      END IF;
    END PROCESS;

 END ARCHITECTURE translated;



