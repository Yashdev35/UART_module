-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2025 06:35:29 PM
-- Design Name: 
-- Module Name: line - Behavioral
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

entity lfifo is
port(
rst,clk : in std_logic;
in_d : in std_logic_vector(7 downto 0);
rx_d : in std_logic;
rd : in std_logic;
out_d : out std_logic_vector(7 downto 0);
flg : out std_logic
);
end lfifo;
architecture Behavioral of lfifo is
begin

tran : process(clk,rst)
begin 
    if(rst = '1') then 
          flg <= '0';
          out_d <=(others => '0');
    elsif(rising_edge(clk)) then 
          flg <= '0';
          if(rx_d = '1') then 
                out_d <= in_d;
                flg <= '1';
          elsif(rd = '1') then 
                flg <= '0';
          end if;
    end if;      
end process tran;
end Behavioral;
