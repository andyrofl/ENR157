-- Clock Divider --
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

-- Entity Declaration --
entity microwave_state is
	port(
		start_switch : in STD_LOGIC;
		stop_switch : in STD_LOGIC;
		door_switch : in STD_LOGIC;
		done_condition : in STD_LOGIC;
		reject_condition : in STD_LOGIC;
		RUNNING_STATE :out bit:='0';
		READY_STATE : out bit:='0';
		RESET_STATE : out bit:='0'
		);
end microwave_state;


architecture state_machine of microwave_state is
shared variable paused, reset_clear, is_running, door_toggle :bit;
--shared variable paused:bit:='1';
begin
process(start_switch, stop_switch, door_switch, done_condition, reject_condition)
	begin
	
	if(door_switch='1') then
		RUNNING_STATE<='0'; door_toggle:='1';
	elsif(door_toggle='1') then
		if(is_running='1') then
			RUNNING_STATE<='1'; door_toggle:='0';
		end if;
	elsif(start_switch='0' and door_switch='0') then
		READY_STATE<='0'; RESET_STATE<='0'; RUNNING_STATE<='1'; is_running:='1'; paused:='0';
	elsif(stop_switch'event and stop_switch='0') then
		if(paused='1' or done_condition='1') then
			READY_STATE<='1'; RESET_STATE<='1'; RUNNING_STATE<='0'; is_running:='0'; paused:='0'; reset_clear:='1';
		elsif(is_running='1') then
			READY_STATE<='0'; RESET_STATE<='0'; RUNNING_STATE<='0'; paused:='1'; is_running:='0'; end if;
	--elsif(reject_condition='1') then
	--	READY_STATE<='1'; RESET_STATE<='0'; RUNNING_STATE<='0'; is_running:='0';
	end if;
	
	if(reset_clear='1') then
		RESET_STATE<='0';
		reset_clear:='0';
	end if;
	
end process;
end state_machine;