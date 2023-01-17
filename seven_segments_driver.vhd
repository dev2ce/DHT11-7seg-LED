library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity seven_segments_driver is

port(
	clk:	in std_logic;
	tick_done : in std_logic;
	rst:	in std_logic;
	data_in: in STD_LOGIC_vector(7 downto 0);
   led1: out STD_LOGIC_vector(6 downto 0);
	led2: out STD_LOGIC_vector(6 downto 0)
);
  
end seven_segments_driver;

architecture behavior of seven_segments_driver is
	signal 	data_to_int: 	integer range 0 to 99 := 0;
	signal	num1: 	integer range 0 to 9;
	signal	num2: 	integer range 0 to 9;
begin
	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(tick_done = '1') then 
				data_to_int <= (to_integer(unsigned(data_in)));
				num1 <= data_to_int mod 10;
				num2 <= data_to_int / 10;
				case num1 is
					when 0 => led1 <= "1000000";
					when 1 => led1 <= "1111001";
					when 2 => led1 <= "0100100";
					when 3 => led1 <= "0110000";
					when 4 => led1 <= "0011001";
					when 5 => led1 <= "0010010";
					when 6 => led1 <= "0000010";
					when 7 => led1 <= "1111000";
					when 8 => led1 <= "0000000";
					when 9 => led1 <= "0010000";
				end case;
				
				case num2 is
					when 0 => led2 <= "1000000";
					when 1 => led2 <= "1111001";
					when 2 => led2 <= "0100100";
					when 3 => led2 <= "0110000";
					when 4 => led2 <= "0011001";
					when 5 => led2 <= "0010010";
					when 6 => led2 <= "0000010";
					when 7 => led2 <= "1111000";
					when 8 => led2 <= "0000000";
					when 9 => led2 <= "0010000";
				end case;
			end if;
		end if;
		
		if(rst = '0') then
			data_to_int <= 0;
		end if;
	end process;
end behavior;