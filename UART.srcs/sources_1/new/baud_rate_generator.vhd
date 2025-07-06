----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2025 06:35:29 PM
-- Design Name: 
-- Module Name: br_gen - Behavioral
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

entity br_gen is
port(
rst,clk : in std_logic;
tick : out std_logic
);
end br_gen;
architecture Behavioral of br_gen is
signal s : integer;
constant n : integer := 54;
begin
sig_gen: process(clk,rst)
begin 
  if(rst = '1') then 
    s <= 0;
    tick <= '0';
  else 
   if rising_edge(clk) then
     if(s = n) then 
       s <= 0;
       tick <= '1';
    else
       s <= s +1;
       tick <= '0';
    end if; 
  end if;
  end if;
end process sig_gen;
end Behavioral;
