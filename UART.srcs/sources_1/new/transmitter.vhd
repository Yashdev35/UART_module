-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2025 06:35:29 PM
-- Design Name: 
-- Module Name: tr - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tr is
port(
rst,clk,tick : in std_logic;
tx_st : in std_logic;
data : in std_logic_vector(7 downto 0);
tx,tx_done : out std_logic
);
end tr;

architecture Behavioral of tr is
type state is (idl,start,trans,stop);
signal ps,ns : state;

signal sample,next_sample : unsigned(4 downto 0):= (0 => '1',others => '0');
signal size,next_size : unsigned(3 downto 0) := (0 => '1',others => '0');

signal reg,next_reg : std_logic_vector(7 downto 0) := (others => '0');
signal out_tx : std_logic := '1';
signal next_out_tx : std_logic;
signal out_tx_done : std_logic := '0';
signal n_out_tx_done : std_logic;
signal sample15,sz8 : std_logic;

begin

sync :process(clk,rst,ns)
begin 
if(rst = '1') then 
     ps <= idl;
     sample <= (0 => '1',others => '0');
     size <= (0 => '1',others => '0');
     reg <= (others => '0');
     out_tx <= '1';
     out_tx_done <= '0';
elsif(rising_edge(clk)) then 
     ps <= ns;
     sample <= next_sample;
     size <= next_size;
     reg <= next_reg;
     out_tx <= next_out_tx;
     out_tx_done <= n_out_tx_done;
end if;
end process sync;

combi : process(ps,tx_st,tick,sample,size,reg,sample15,sz8)
begin 
     ns <= ps;
     next_sample <= sample;
     next_size <= size;
     next_reg <= reg;
     next_out_tx <= out_tx;
     n_out_tx_done <= out_tx_done;
     
     case ps is 
          when idl => 
                 next_out_tx<= '1';
                 n_out_tx_done <= '0';
                 if(tx_st = '1') then
                      n_out_tx_done <= '1';
                      ns <= start;
                      next_reg <= data;
                      next_sample <= (0 => '1' , others => '0');
                 end if;
          when start =>      
                 if(tick = '1') then 
                        next_out_tx <= '0';
                        if(sample15 = '1') then 
                                next_sample <= (0 => '1' , others => '0');
                                next_size <= (0 => '1' , others => '0');
                                ns <= trans;
                        else 
                                next_sample <= next_sample +1;
                        end if;
                 end if;
          when trans => 
                 if(tick = '1') then 
                        next_out_tx <= reg(0);
                        if(sample15 = '1') then   
                                next_sample <= (0 => '1' , others => '0');
                                next_reg <= '0' & reg(7 downto 1);
                                if(sz8 = '1') then 
                                        ns <= stop;
                                        next_size <= (0 => '1' , others => '0');
                                else 
                                        next_size <= next_size +1;
                                end if;
                        else 
                                next_sample <= next_sample+1;
                        end if;
                 end if;
          when stop =>
                 if(tick = '1') then  
                        next_out_tx <= '0';
                        if(sample15 = '1') then 
                                  ns<= idl;
                                  next_sample <= (0 => '1' , others => '0');
                                  next_size <= (0 => '1' , others => '0');
                        else 
                                  next_sample<= next_sample +1;
                        end if;
                 end if; 
          end case; 
end process combi;         

sample15 <= '1' when sample(4) = '1' else '0';
sz8      <= '1' when size(3) = '1' else '0'; 

tx <= out_tx;
tx_done <= out_tx_done;
end Behavioral;
