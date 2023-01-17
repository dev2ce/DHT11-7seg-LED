library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PWM_Generator is
port (
	clk: in std_logic;
	tick_done : in std_logic;
	data: in std_logic_vector (7 downto 0);
	pwm_out: out std_logic
);
end PWM_Generator;

architecture Behavioral of PWM_Generator is
	signal temp_out: integer range 0 to 50;
	signal DUTY_CYCLE: integer range 0 to 1001 := 0;
	signal counter_pwm: integer range 0 to 1000;
	
	constant duty_0 : INTEGER := 0;
	constant duty_25 : INTEGER := 250;
	constant duty_40 : INTEGER := 400;
	constant duty_100 : INTEGER := 1000;
begin
	process(clk)
	begin
		--temp_out <= (to_integer(unsigned(data)));
		if(rising_edge(clk)) then
			counter_pwm <= counter_pwm + 1;
			
			if(counter_pwm > 1000) then
				counter_pwm <= 0;
			elsif(counter_pwm < DUTY_CYCLE) then
				PWM_out <= '1';
			elsif(counter_pwm >= DUTY_CYCLE) then
				PWM_out <= '0';
			end if;
			
			if(temp_out < 20) then
				DUTY_CYCLE <= duty_0;
			elsif(temp_out >= 20 and temp_out < 30) then
				DUTY_CYCLE <= duty_40;
			elsif(temp_out >= 30) then
				DUTY_CYCLE <= duty_100;
			end if;
		end if;
		
		if (tick_done = '1') then
			temp_out <= (to_integer(unsigned(data)));
		end if;
	end process;
end Behavioral;