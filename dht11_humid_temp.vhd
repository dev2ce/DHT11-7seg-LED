library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity dht11_humid_temp is
	port(
	clk : in std_logic;
	rst : in std_logic;
	dht11 : inout std_logic;	
	temp_out : out std_logic_vector(7 downto 0);
	humid_out : out std_logic_vector(7 downto 0);
	tick_done : out std_logic
	);
end dht11_humid_temp;

architecture behavior of dht11_humid_temp is
	
	constant delay_18_ms: positive:= 1000000;	-- các khoảng counter để giao tiếp vs DHT11
	constant delay_40_us: positive:= 2000;
	constant MAX_DELAY: positive:= 50000000; -- chu kì lấy mẫu 1s
	
	signal input_sync: std_logic_vector (2 downto 0);
	signal bit_rising_edge,bit_falling_edge: boolean;	-- biên boolean lưu trữ trạng thái sườn lên, sươn xuống chân data
	signal counter: natural range 0 to MAX_DELAY;
	signal number_bit: natural range 0 to 40 ;
	signal data_out: std_logic_vector (39 downto 0 );
	signal dht_ena: std_logic:= '0'; -- keep logic output
	
	signal state: integer range 0 to 7 :=0 ;
	signal start_convert: std_logic := '1';
	signal data_in : std_logic;
	signal temp_buf : std_LOGIC_vector(7 downto 0);
begin

	temp_out <= data_out(23 downto 16);
	humid_out <= data_out(39 downto 32);
	
	dht11 <= '0' when dht_ena ='1' else 'Z';
	
	-- bắt xung cạnh lên và xuống của dht11
	process(clk) begin
		if (rising_edge(clk)) then
			input_sync <=  input_sync(1 downto 0) & (dht11);	-- sử dụng phép nối để lưu trữ trạng thái của chân data
		end if;
	end process;
	bit_rising_edge <= input_sync(2 downto 1) = "01";
	bit_falling_edge <= input_sync(2 downto 1) = "10";

	FSM: process(clk) 
	begin
		if (rising_edge(clk)) then
			case (state) is
				when 0 =>
					if (counter = 0) then
						number_bit <= 40;	
						tick_done <= '0';	
						counter <= delay_18_ms;	
						dht_ena <= '1';				-- cổng 3 trạng thái chuyển sang chế độ output, kéo mức logic 1-wire xuống 0 ở trạng thái tiếp theo
						state <= 1;				-- chuyển trạng thái tiếp theo 
					else
						counter <= counter -1;
					end if;
					
				when 1 =>
					if (counter = 0) then			-- chuyển trạng thái sau sau 18ms
						dht_ena <= '0';	
						state <= 2;	
					else 
						counter <= counter-1;
					end if;
					
				when 2 =>
					if bit_falling_edge then	-- chờ DHT11 kéo chân 1-wire về 0 để chuyển trạng thái
						state <= 3;
					end if;
					
				when 3 =>
					if (bit_rising_edge) then	 -- khi bắt được xung cạnh lên chuyển sang trạng thái tiếp theo											
						state <= 4;
					end if;
					
				when 4 =>
					if (bit_falling_edge) then -- khi bắt được xung cạnh xuống chuyển sang trạng thái tiếp theo
						state <= 5;
					end if;
					
				when 5 => 		-- trạng thái DHT11 bắt đầu gửi 40 bit dữ liệu 
					if (bit_rising_edge) then	
						counter <= 0;
						state <= 6;
					elsif (number_bit = 0 ) then	-- đủ 40 bit dữ liệu chuyển trạng thái end_sl
						state <= 7;
						counter <= delay_40_us;
					end if;
					
				when 6 =>
					if (bit_falling_edge) then 
						number_bit <= number_bit - 1;
						if (counter < delay_40_us) then
							data_out <=  data_out(38 downto 0) & '0'; -- nối 39 bit thấp với bit vừa đọc được
						else
							data_out <=  data_out(38 downto 0) & '1';
						end if;
					counter <= 0;
					state <= 5;
					end if;
					counter <= counter + 1;
					
				when 7 =>
					if (counter = 0) then
						state <= 0;
						tick_done <= '1';
						counter <= MAX_DELAY;
					else
						counter <= counter-1;
					end if;
			end case;
		end if;
			
		if (rst = '0' ) then 
			number_bit <= 0;
			data_out <= (others => '0');
			counter <= MAX_DELAY; 
			state <= 0; 
		end if;
	end process;	
end behavior;