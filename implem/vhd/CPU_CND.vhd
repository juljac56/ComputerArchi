library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        ina         : in w32;
        inb         : in w32;
        f           : in  std_logic;
        r           : in  std_logic;
        e           : in  std_logic;
        d           : in  std_logic;
        s           : out std_logic;
        j           : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
	
	signal ex_signe: std_logic;
	signal z : std_logic;
	signal s_a : std_logic_vector(31 downto 0);
	signal s_b : std_logic_vector(31 downto 0);


begin

	ex_signe <= ((not e) and (not d)) or (d and (not r));
	
	s_a <= std_logic_vector(ina) ;
	s_b <= std_logic_vector(inb) ;

	s <= '1' WHEN signed(s_b) > signed(s_a) AND ex_signe ='1'
			 ELSE '1' WHEN inb > ina AND ex_signe ='0' ELSE '0';
	j <= '0';
	
	
	
	
end architecture;
