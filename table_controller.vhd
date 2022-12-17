library IEEE;
use IEEE.STD_LOGIC_1164.All;

entity servo_pwm is
	Port(clk					:in STD_LOGIC;				-- 50 Mhz Clock (Pin_P11 on DE10Lite MAX10_CLK1_50)
		  reset				:in STD_LOGIC;				-- Slider switch SW0 (Pin_C10 on DE10Lite)
		  clockwise			:in STD_LOGIC;				-- SW0 (SW0 on digital trainer or GPIO_31 on DE10Lite)
		  midpoint			:in std_LOGIC;				-- SW1 (SW1 on digital trainer or GPIO_30 on DE10Lite)
		  counterclockwise:in STD_LOGIC;				-- SW2 (SW2 on digital trainer or GPIO_32 on DE10Lite)
		  pwm					:out STD_LOGIC;			-- GPIO_035 (Pin_AA2 on DE10Lite)
		  LEDCW				:out STD_LOGIC;        	-- LEDR0 status LED for Clockwise (Pin_A8 on DE10Lite)
		  LEDMid				:out STD_LOGIC;			-- LEDR1 status LED for mid (Pin_A9 on DE10lite)
		  LEDCCW				:out STD_LOGIC;			-- LEDR2 status LED for CCW (Pin_A10 on DE10lite)
		  LEDStatus			:out STD_LOGIC);			-- LEDR7 status LED for PWM (pin_D14 on DELite) Brightness will tie to the duty cycle of the pwm signal 
	end servo_pwm;
	
	architecture Behavioral of servo_pwm is
		constant period:integer:=1000000;
		signal counter,counter_next:integer:=0;
		signal pwm_reg,pwm_next:STD_LOGIC;
		signal duty_cycle,duty_cycle_next:integer:=0;
		signal tick:std_logic;
	begin
	--register
	   process(clk,reset)
		   begin
			   if reset='1' then
				   pwm_reg<='0';
					counter<=0;
					duty_cycle<=0;
					elsif clk='1' and clk'event then
				   pwm_reg<=pwm_next;
					counter<=counter_next;
				   duty_cycle<=duty_cycle_next;
				end if;
		end process;
		
		counter_next<=0 when counter=period else
		                counter+1;
		tick<='1' when counter=0 else
		      '0';
				
	--Changing Duty Cycle
	  process(clockwise, midpoint, counterclockwise,tick,duty_cycle)
	     begin
		     -- duty_cycle<=75000;
			  if tick='1' then
			     if clockwise='1' then --CHANGE TO LOW STEP 15
				     duty_cycle_next<=50000;
				  elsif midpoint='1' then -- CHANGE TO LOW
				     duty_cycle_next<=75000;
				  elsif counterclockwise='1' then --CHANGE TO LOW
				  duty_cycle_next<=100000;
		   		end if;
			end if;
		end process;
	--Buffer
	   pwm<=pwm_reg;
		LEDStatus<=tick;
		pwm_next<='1' when counter<duty_cycle else
		          '0';
end Behavioral;
					