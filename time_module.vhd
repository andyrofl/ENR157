library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;					-- Arithmetic Package
use IEEE.STD_LOGIC_UNSIGNED.ALL;				-- Unsigned Values Package


entity time_module is
   Port (
	  time_2 : in STD_LOGIC:='0';
	  time_4 : in STD_LOGIC:='0';
	  time_8 : in STD_LOGIC:='0';
	  time_10 : in bit:='0';
	  time_20 : in bit:='0';
	  time_40 : in bit:='0';
	  clk : in STD_LOGIC;					-- FPGA DE0 Main clock - 50 MHz
	  STATE_RUNNING : in STD_LOGIC:='0'; --do timer when running, when none it will be paused
	  STATE_READY : in STD_LOGIC:='0'; --allows input values to be changed
	  STATE_RESET : in STD_LOGIC:='0'; --clears input and timer values

	  TIMER05_1 : out bit:='0';--HEX6 TIMER10 BCD
	  TIMER05_2 : out bit:='0';
	  TIMER05_4 : out bit:='0';
	  TIMER05_8 : out bit:='0';
	  TIMER04_1 : out bit:='0';--HEX5 TIMER1 BCD
	  TIMER04_2 : out bit:='0';
	  TIMER04_4 : out bit:='0';
	  TIMER04_8 : out bit:='0';
	  TIMER_DONE : out bit:='0';
	  STATE_REJECT: out bit:='0');
end entity time_module;

architecture module of time_module is
shared variable time_left: integer:=0;
shared variable count:integer:=0;
shared variable running_time:integer:=0;
shared variable input_time:integer:=0;
shared variable time_passed: integer;
begin


process(clk)
variable add_2, add_4, add_8, add_10, add_20, add_40, time_total:integer:=0;
variable ones, tens: integer;

begin

	-----  TIME INPUT AND PROCESSING -----
	if(STATE_READY='1') then
		if(time_2='0') then
			add_2 := 0;
		elsif(time_2='1') then add_2:=2; end if;
		if(time_4='0') then
			add_4 := 0;
		elsif(time_4='1') then add_4:=4; end if;	
		if(time_8='0') then
			add_8 := 0;
		elsif(time_8='1') then add_8:=8; end if;
		if(time_10='0') then
			add_10 := 0;
		elsif(time_10='1') then add_10:=10; end if;
		if(time_20='0') then
			add_20 := 0;
		elsif(time_20='1') then add_20:=20; end if;
		if(time_40='0') then
			add_40 := 0;
		elsif(time_40='1') then add_40:=40; end if;
			
		time_total := (add_2 + add_4 + add_8 + add_10 + add_20 + add_40);
		if(time_total > 60) then
			time_total := 60;
		end if;
		input_time := time_total;
	elsif(STATE_RESET='1') then
		add_2:=0; add_4:=0; add_8:=0; add_10:=0; add_2:=0; add_40:=0; time_total:=0; input_time:=0;
	end if;
	
	-------------------------------------------------------------------------

	if (clk'event and clk='1') then
		count := count+1; end if;
	

	--time_left:= input_time-running_time;
	if (count=6) then
		count:=0;
		if(STATE_RUNNING='1') then
			if(input_time>time_passed and input_time >0) then
				input_time:= input_time- 1;
			else
				TIMER_DONE<='1';
			end if;
		end if;
	end if;
	-----
	ones := (input_time-time_passed) mod 10;
	tens := ((input_time-time_passed) - ones)/10;
	
		if(ones >7) then TIMER04_8 <='1'; ones := ones-8; else TIMER04_8 <='0'; end if;
		if(ones >3) then TIMER04_4 <='1'; ones := ones-4; else TIMER04_4 <='0'; end if;
		if(ones >1) then TIMER04_2 <='1'; ones := ones-2; else TIMER04_2 <='0'; end if;
		if(ones >0) then TIMER04_1 <='1'; else TIMER04_1 <='0';end if;

		if(tens >7) then TIMER05_8 <='1'; tens := tens-8; else TIMER05_8 <='0'; end if;
		if(tens >3) then TIMER05_4 <='1'; tens := tens-4; else TIMER05_4 <='0'; end if;
		if(tens >1) then TIMER05_2 <='1'; tens := tens-2; else TIMER05_2 <='0'; end if;
		if(tens >0) then TIMER05_1 <='1'; else TIMER05_1 <='0'; end if;	
	
end process;
end module;