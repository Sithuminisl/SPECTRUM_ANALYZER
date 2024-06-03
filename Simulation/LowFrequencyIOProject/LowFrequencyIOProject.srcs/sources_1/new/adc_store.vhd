-- BEGIN: abpxx6d04wxr
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/09/2024 04:20:04 PM
-- Design Name: 
-- Module Name: adc_store - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- FILEPATH: /d:/Projects/Spectrum Analyzer/High-Frequency-Spectrum-Analyzer/LowFrequencyIOProject/LowFrequencyIOProject.srcs/sources_1/new/adc_store.vhd
-- BEGIN: ed8c6549bwf9
entity adc_store is
    Port (
        clk : in std_logic;
        analog_input : in std_logic_vector(7 downto 0);
        op : out std_logic_vector(7 downto 0) -- Modify to 8-pin output
    );
end adc_store;
-- END: ed8c6549bwf9

-- BEGIN: be15d9bcejpp
architecture Behavioral of adc_store is

    signal analog_value : std_logic_vector(7 downto 0);
    signal output_value : std_logic_vector(7 downto 0);
    signal or_value : std_logic := '0';

begin

    -- Main loop
    process (clk)
    begin
            analog_value <= analog_input;
            or_value <= output_value(7) or analog_value(7);
            output_value <= (analog_value+ output_value + or_value)(8 downto 1);
            op <= output_value;
    end process;

end Behavioral;