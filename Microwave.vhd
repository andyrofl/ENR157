library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;					-- Arithmetic Package
use IEEE.STD_LOGIC_UNSIGNED.ALL;				-- Unsigned Values Package


-- KEYO START KEY1 STOP
-- SW0 ACTIVE HIGH -- OR ---EXTERNAL SWITCH with power from GPIO PIN 29, ground from GPIO PIN 30, and signal return GPIO PIN 25
-- countdown time is set as two binary digits SW4-SW9 where SW9 represents 40, SW8 20, SW7 10. SW6 8 sec, SW5 4, SW4 2 sec.
-- LEDRo is microwave oven light, comes on when running or when door open
-- Servo motor GPIO 35, also turns on LEDR2 for reference
-- DC motor simulating the microwave beam is GPIO 35
-- power set via SW3 80%, SW2 40%, SW1 20%. power level indicated on HEX02, HEX01, and HEX00
-- 2 second tone on GPIO26  signals timer reached zero, output also shown on LEDR1


entity microwave is
   Port (
     --start_switch : in STD_LOGIC:='0';
     --stop_switch : in STD_LOGIC:='0';
	  --door_switch : in STD_LOGIC:='0';
	  power_20 : in bit:='0';
	  power_40 : in bit:='0';
	  power_80 : in bit:='0';
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
	  POWER02_1 : out bit:='0';--HEX2 POWER100 BCD
	  POWER02_2 : out bit:='0';
	  POWER02_4 : out bit:='0';
	  POWER02_8 : out bit:='0';
	  POWER01_1 : out bit:='0';--HEX1 POWER10 BCD
	  POWER01_2 : out bit:='0';
	  POWER01_4 : out bit:='0';
	  POWER01_8 : out bit:='0';
	  POWER00_1 : out bit:='0';--HEX0 POWER1 BCD
	  POWER00_2 : out bit:='0';
	  POWER00_4 : out bit:='0';
	  POWER00_8 : out bit:='0';
	  TIMER05_1 : out bit:='0';--HEX6 TIMER10 BCD
	  TIMER05_2 : out bit:='0';
	  TIMER05_4 : out bit:='0';
	  TIMER05_8 : out bit:='0';
	  TIMER04_1 : out bit:='0';--HEX5 TIMER1 BCD
	  TIMER04_2 : out bit:='0';
	  TIMER04_4 : out bit:='0';
	  TIMER04_8 : out bit:='0';
	  TABLE_ON : out bit;
	  MICROWAVE_ON : out bit;
	  LED_DONE : out bit:='0';
	  STATE_REJECT: out bit:='0');
end entity microwave;

architecture simulator of microwave is
type state is (READY, START_TRIGGER, RUNNING, PAUSE, CLEAR, BEEP, DONE); --delet
shared variable current_state : state:=DONE; --delet
shared variable time_left: integer:=0;
shared variable count:integer:=0;
shared variable running_time:integer:=0;
shared variable input_time:integer:=0;
shared variable input_power:integer:=0;
shared variable time_passed: integer;
begin


process(clk)
variable add_2, add_4, add_8, add_10, add_20, add_40, time_total:integer:=0;
variable ones, tens, power_tens, power_hundo: integer;
variable add_20p, add_40p, add_80p, power_total:integer:=0;

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
	-----  POWER INPUT AND PROCESSING -----
	if(STATE_READY='1') then
		if(power_20='0') then
			add_20p :=0;
		elsif(power_20='1') then add_20p:=2; end if;
		if(power_40='0') then
			add_40p :=0;
		elsif(power_40='1') then add_40p:=4; end if;
		if(power_80='0') then
			add_80p :=0;
		elsif(power_80='1') then add_80p:=8; end if;
		
		power_total := (add_20p + add_40p + add_80p);
		if(power_total > 10) then
			power_total := 10;
		end if;
		input_power := power_total;
	elsif(STATE_RESET='1') then
		add_20p:=0; add_40p:=0; add_80p:=0; power_total:=0;
	end if;
	
	-------------------------------------------------------------------------

		
--	if(STATE_RUNNING='1' and input_time=0) then
--		STATE_REJECT<='1';
--	else STATE_REJECT<='0'; end if;
	
	if (clk'event and clk='1') then
		count := count+1; end if;
	
	if(STATE_RESET='1') then
		count:=0;
		time_passed:=0;
		MICROWAVE_ON<='0';
		TABLE_ON<='0';
		LED_DONE<='0';
	end if;
	
	--time_left:= input_time-running_time;
	if (count=6) then
		count:=0;
		if(STATE_RUNNING='1') then
			if(input_time>time_passed and input_time >0) then
				LED_DONE<='0';
				MICROWAVE_ON<='1';
				TABLE_ON<='1';
				input_time:= input_time- 1;
			else
				LED_DONE<='1';
				MICROWAVE_ON<='0';
				TABLE_ON<='0';
			end if;
		end if;
	end if;
	-----
		ones := (input_time-time_passed) mod 10;
	tens := ((input_time-time_passed) - ones)/10;
	power_tens := input_power mod 10;
	power_hundo := (input_power - power_tens)/10;
	
		if(ones >7) then TIMER04_8 <='1'; ones := ones-8; else TIMER04_8 <='0'; end if;
		if(ones >3) then TIMER04_4 <='1'; ones := ones-4; else TIMER04_4 <='0'; end if;
		if(ones >1) then TIMER04_2 <='1'; ones := ones-2; else TIMER04_2 <='0'; end if;
		if(ones >0) then TIMER04_1 <='1'; else TIMER04_1 <='0';end if;

		if(tens >7) then TIMER05_8 <='1'; tens := tens-8; else TIMER05_8 <='0'; end if;
		if(tens >3) then TIMER05_4 <='1'; tens := tens-4; else TIMER05_4 <='0'; end if;
		if(tens >1) then TIMER05_2 <='1'; tens := tens-2; else TIMER05_2 <='0'; end if;
		if(tens >0) then TIMER05_1 <='1'; else TIMER05_1 <='0'; end if;
		
		if(power_tens >7) then POWER01_8 <='1'; power_tens := power_tens-8; else POWER01_8 <='0'; end if;
		if(power_tens >3) then POWER01_4 <='1'; power_tens := power_tens-4; else POWER01_4 <='0'; end if;
		if(power_tens >1) then POWER01_2 <='1'; power_tens := power_tens-2; else POWER01_2 <='0'; end if;
		if(power_tens >0) then POWER01_1 <='1'; else POWER01_1 <='0';end if;

		if(power_hundo >7) then POWER02_8 <='1'; power_hundo := power_hundo-8; else POWER02_8 <='0'; end if;
		if(power_hundo >3) then POWER02_4 <='1'; power_hundo := power_hundo-4; else POWER02_4 <='0'; end if;
		if(power_hundo >1) then POWER02_2 <='1'; power_hundo := power_hundo-2; else POWER02_2 <='0'; end if;
		if(power_hundo >0) then POWER02_1 <='1'; else POWER02_1 <='0'; end if;
	
	
end process;
end simulator;