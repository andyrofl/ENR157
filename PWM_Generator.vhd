-- PWM Generator --
Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

-- Entity Decalaration --
entity PWM_Generator is
	generic( N: integer := 8);
	port(
			clr : in STD_LOGIC;
			clk_in : in STD_LOGIC;
			pwm : out STD_LOGIC;
			B0 : in STD_LOGIC;
			B1 : in STD_LOGIC;
			B2 : in STD_LOGIC;
			B3 : in STD_LOGIC
		);
	end PWM_Generator;
-- End of Declarations --

-- Architecture Definitions --
architecture PWM_Generator of PWM_Generator is
signal count: STD_LOGIC_VECTOR(N-1 downto 0);
signal period: STD_LOGIC_VECTOR(N-1 downto 0);
signal duty: STD_LOGIC_VECTOR(N-1 downto 0);
signal level: STD_LOGIC_VECTOR(3 downto 0);

	begin
		cntN: process(clk_in, clr, level) -- N bit Counter
		begin
		level<=B3&B2&B1&B0;
		duty <= X"00";             -- Default to 0% DC --
		period <= X"F3";           -- Period Setting   --

-- Period and Duty Cycle Calculations for N counter --

-- Period_code = (T/Tclk)*(2^N-1) -> change to Hex  -- 
-- Get Tclk from clkdiv table                       --

-- DC_code = DC*Period_code       -> change to Hex  --

------------------------------------------------------
-- example:                                         --
--          Desired T = 20 ms                       --
--          Therefore q(19) is required, a 20 bit   --
--          counter divide from 50 MHz FPGA clock   --
--          Use an 8 bit counter, therefore specify --
--          q(19 - 8) - q(11) for clkdiv.           --
--                                                  --
--          period = (20ms/20.97ms)(2^8 - 1) = 243  --
--                    243 = F3 hex                  --
--                                                  --
--          for 40% duty cycle                      --
--              0.40*243 = 97.2 = 61 hex            --
------------------------------------------------------



		
-- setting duty cycle from switches --
		if level="0000" then
		duty <= X"00";         -- 0%
		end if;

if level="0001" then
		duty <= X"18";         -- 10%
		end if;

if level="0010" then
		duty <= X"31";         -- 20%
		end if;

if level="0011" then
		duty <= X"49";         -- 30%
		end if;

if level="0100" then
		duty <= X"61";         -- 40%
		end if;

if level="0101" then
		duty <= X"7A";         -- 50%
		end if;

if level="0110" then
		duty <= X"92";         -- 60%
		end if;

if level="0111" then
		duty <= X"AA";         -- 70%
		end if;

if level="1000" then
		duty <= X"C2";         -- 80%
		end if;

if level="1001" then
		duty <= X"DB";         -- 90%
		end if;

if level="1010" then
		duty <= X"F3";         -- 100%
		end if;

			if clr = '1' then
				count <= (others => '0');
				duty <= X"00";
			elsif clk_in'event and clk_in = '1' then
				if count = period - 1 then
					count <= (others => '0');
				else
					count <= count + 1;
				end if;
			end if;
		end process cntN;
		
		pwmout: process(count)
		begin
			if count < duty then
				pwm <= '0';      -- due to 74LS06 Inversion --
			else
				pwm <='1';       -- due to 74LS06 Inversion --
			end if;
		end process pwmout;
	end PWM_Generator;
