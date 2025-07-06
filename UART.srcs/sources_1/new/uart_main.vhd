----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/18/2025 06:35:29 PM
-- Design Name: 
-- Module Name: uart - Behavioral
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

entity uart is
port(
rst,clk :in std_logic;
rx : in std_logic;
tx : out std_logic;
r_data,fifo_data : out std_logic_vector(7 downto 0)
);
end uart;
architecture Behavioral of uart is
signal rx_data,l_data : std_logic_vector(7 downto 0);
signal rx_done : std_logic;
signal flag : std_logic;
signal tick : std_logic;
signal tx_done : std_logic;
signal not_flg,no_use : std_logic;

component fifo_generator_0 IS
  PORT (
    clk : IN STD_LOGIC;
    srst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );
end component;

begin
--signal assignment 
r_data <= rx_data;
fifo_data <= l_data;
flag <= not not_flg;

--port maps
uu1 : entity work.re(Behavioral)
port map (
rst => rst,
clk => clk,
tick => tick,
rx =>rx,
dout => rx_data,
rx_d =>rx_done
);

-- imported design 
uu2 : fifo_generator_0
port map(
clk => clk,
srst => rst,
din => rx_data,
wr_en => rx_done,
rd_en => tx_done,
dout => l_data,
full => no_use,
empty => not_flg
);

uu3 :entity work.tr(Behavioral) port map (
rst => rst,
clk => clk,
tick => tick,
tx_st => flag,
data => l_data,
tx => tx,
tx_done => tx_done
);

uu4 :entity  work.br_gen(Behavioral)
port map(
rst => rst,
clk => clk,
tick => tick
);

end Behavioral;
