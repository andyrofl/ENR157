library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;					-- Arithmetic Package
use IEEE.STD_LOGIC_UNSIGNED.ALL;				-- Unsigned Values Package



entity power_module is
   Port (
	  power_20 : in bit:='0';
	  power_40 : in bit:='0';
	  power_80 : in bit:='0';
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
	  POWER00_8 : out bit:='0');
end entity power_module;

architecture module of power_module is
shared variable input_power:integer:=0;
begin


process(clk)
variable power_tens, power_hundo: integer;
variable add_20p, add_40p, add_80p, power_total:integer:=0;

begin


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
	
		
		if(power_tens >7) then POWER01_8 <='1'; power_tens := power_tens-8; else POWER01_8 <='0'; end if;
		if(power_tens >3) then POWER01_4 <='1'; power_tens := power_tens-4; else POWER01_4 <='0'; end if;
		if(power_tens >1) then POWER01_2 <='1'; power_tens := power_tens-2; else POWER01_2 <='0'; end if;
		if(power_tens >0) then POWER01_1 <='1'; else POWER01_1 <='0';end if;

		if(power_hundo >7) then POWER02_8 <='1'; power_hundo := power_hundo-8; else POWER02_8 <='0'; end if;
		if(power_hundo >3) then POWER02_4 <='1'; power_hundo := power_hundo-4; else POWER02_4 <='0'; end if;
		if(power_hundo >1) then POWER02_2 <='1'; power_hundo := power_hundo-2; else POWER02_2 <='0'; end if;
		if(power_hundo >0) then POWER02_1 <='1'; else POWER02_1 <='0'; end if;
	
	
end process;
end module;