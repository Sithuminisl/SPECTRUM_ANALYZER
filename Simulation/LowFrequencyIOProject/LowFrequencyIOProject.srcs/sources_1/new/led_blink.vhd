-- FILEPATH: /D:/Projects/Spectrum Analyzer/High-Frequency-Spectrum-Analyzer/LowFrequencyIOProject/LowFrequencyIOProject.srcs/sources_1/new/led_blink.vhd
-- BEGIN: abpxx6d04wxr
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2024 03:40:32 PM
-- Design Name: 
-- Module Name: led_blink - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
-- END: abpxx6d04wxr

-- FILEPATH: /D:/Projects/Spectrum Analyzer/High-Frequency-Spectrum-Analyzer/LowFrequencyIOProject/LowFrequencyIOProject.srcs/sources_1/new/led_blink.vhd

entity led_blink is
    Port (
        clk : in std_logic;
        led : out std_logic
    );
end led_blink;

architecture Behavioral of led_blink is
    constant CLK_FREQUENCY : integer := 100000000; -- Clock frequency in Hz
    constant BLINK_FREQUENCY : integer := 1; -- Blink frequency in Hz
    constant BLINK_PERIOD : integer := CLK_FREQUENCY / BLINK_FREQUENCY;
    
    signal counter : integer range 0 to BLINK_PERIOD - 1 := 0;
    signal blink : std_logic := '0';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = BLINK_PERIOD - 1 then
                counter <= 0;
                blink <= not blink;
            end if;
        end if;
    end process;

    led <= blink;
end Behavioral;

