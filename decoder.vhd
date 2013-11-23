library ieee;
use ieee.std_logic_1164.all ;
ENTITY decoder IS
PORT(
a19: IN STD_LOGIC ;
a18: IN STD_LOGIC ;
a17: IN STD_LOGIC ;
a16: IN STD_LOGIC ;
a7: IN STD_LOGIC ;
a6: IN STD_LOGIC ;
a5: IN STD_LOGIC ;
a4: IN STD_LOGIC ;
DR: IN STD_LOGIC ;
WR: IN STD_LOGIC ;
DT_R: IN STD_LOGIC ;
INV_DTR: OUT STD_LOGIC ;
m_io : IN STD_LOGIC ;
cs_eprom : OUT STD_LOGIC ;
cs_ram : OUT STD_LOGIC ;
cs_8254 : OUT STD_LOGIC ;
cs_8255 : OUT STD_LOGIC ;
cs_8259 : OUT STD_LOGIC ;
cs_lcd : OUT STD_LOGIC 
);
END decoder;
ARCHITECTURE add_equation OF decoder IS
attribute PLDPIN:string;
attribute PLDPIN of a19: signal is "1" ;
attribute PLDPIN of a18: signal is "2" ;
attribute PLDPIN of a17: signal is "3" ;
attribute PLDPIN of a16: signal is "4" ;
attribute PLDPIN of a7: signal is "8" ;
attribute PLDPIN of a6: signal is "9" ;
attribute PLDPIN of a5: signal is "10" ;
attribute PLDPIN of a4: signal is "11" ;
attribute PLDPIN of m_io: signal is "23";
attribute PLDPIN of cs_eprom: signal is "22";
attribute PLDPIN of cs_ram: signal is "21";
attribute PLDPIN of cs_8255: signal is "20";
attribute PLDPIN of cs_8254: signal is "19";
attribute PLDPIN of cs_8259: signal is "18";
attribute PLDPIN of cs_lcd: signal is "17";
attribute PLDPIN of DR: signal is "6";
attribute PLDPIN of WR: signal is "5";
attribute PLDPIN of DT_R: signal is "7";
attribute PLDPIN of INV_DTR: signal is "15";
-- assume that the address is
-- eprom = 0F0000H;
-- ram = 00000H;
-- 8255 = 090H;
--8254 = 0a0H;
-- 8259 = 0b0H;
-- lcd = 0c0H; 

BEGIN
cs_eprom <= not ( not m_io and a19 and a18 and a17 and a16 ) ;
cs_ram <= not ( not m_io and not a19 and not a18 and not a17 and not a16 ) ;
cs_8255 <= not ( m_io and a7 and not a6 and not a5 and a4 );
cs_8254 <= not ( m_io and a7 and not a6 and a5 and not a4 );
cs_8259 <= not ( m_io and a7 and not a6 and a5 and a4 );
cs_lcd <= m_io and ((a7 and a6 and not a5 and not a4 and not DR )or (a7 and a6 and not a5 and not a4 and not WR )) ;
INV_DTR <= not DT_R;
END add_equation;