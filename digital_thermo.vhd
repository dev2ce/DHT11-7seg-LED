library ieee;
use ieee.std_logic_1164.all;

entity digital_thermo is
    port(
        clk	: in std_logic ;
		  rst : in std_logic ;
        dht11: inout std_logic; 
        temp_tens_digit: out std_logic_vector(6 downto 0);
        temp_units_digit: out std_logic_vector(6 downto 0);
		  humid_tens_digit: out std_logic_vector(6 downto 0);
		  humid_units_digit: out std_logic_vector(6 downto 0);
		  pwm : out std_logic
    ); 
end entity;

architecture behavior of digital_thermo is

	component seven_segments_driver port (
		clk:	in std_logic;
		tick_done:	in std_logic;
		rst:	in std_logic;
		data_in: in STD_LOGIC_vector(7 downto 0);
		led1: out STD_LOGIC_vector(6 downto 0);
		led2: out STD_LOGIC_vector(6 downto 0)
	);
	end component;
	
	component dht11_humid_temp port (
       clk	: in std_logic ;
		 rst : in std_logic ;
       dht11: inout std_logic; 
       temp_out : out std_logic_vector(7 downto 0);
		 humid_out : out std_logic_vector(7 downto 0);
       tick_done: out std_logic 
	);
	end component;
	
	component PWM_Generator port (
       clk	: in std_logic ;
		 tick_done : in std_logic;
		 data : in std_logic_vector(7 downto 0) ;
       pwm_out : out std_logic
	);
	end component;
	
	signal data_buffer : std_logic_vector (39 downto 0);
	signal temp_buf : std_logic_vector(7 downto 0);
	signal humid_buf : std_logic_vector(7 downto 0);
	signal start_convert : std_logic := '0';
	
begin
	
	u1: dht11_humid_temp port map (clk, rst, dht11, temp_buf, humid_buf, start_convert);
	u4: PWM_Generator port map (clk, start_convert, temp_buf, pwm);
	u2: seven_segments_driver port map (clk, start_convert, rst, temp_buf, temp_tens_digit, temp_units_digit);
	u3: seven_segments_driver port map (clk, start_convert, rst, humid_buf, humid_tens_digit, humid_units_digit);

end behavior;