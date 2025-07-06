----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2025 06:51:26 PM
-- Design Name: 
-- Module Name: tb_uart - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for uart: drives clk, rst, and simulates serial rx input.
-- 
-- Dependencies: uart.vhd
-- 
-- Revision:
-- Revision 0.02 - Testbench corrected for proper timing and loop
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart is
end tb_uart;

architecture Behavioral of tb_uart is

  -- component under test
  component uart is
    port (
      rst : in  std_logic;
      clk : in  std_logic;
      rx  : in  std_logic;
      tx  : out std_logic;
      r_data,fifo_data : out std_logic_vector(7 downto 0)
    );
  end component;

  -- signals
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';
  signal rx     : std_logic := '1';  -- idle high
  signal tx     : std_logic;
  
  -- 100 MHz clock period
  constant clk_period : time := 10 ns;
  
  -- serial bit-time (adjust to match your UART's baud rate)
  constant bit_time   : time := 8680 ns;

  -- test data: 10 bits (you can treat this as [start, d0…d7, stop] or any custom frame)
  signal data : std_logic_vector(8 downto 0) := "001101001";

begin

  -- instantiate the UART
  uut: uart
    port map (
      rst => rst,
      clk => clk,
      rx  => rx,
      tx  => tx
    );

  -- clock generator
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end loop;
  end process;

  -- stimulus process
  stim_proc: process
  begin
    -- initial reset
    rst <= '1';
    wait for 20 * clk_period;   -- hold reset for 200 ns
    rst <= '0';
    wait for bit_time;          -- wait one bit interval before sending
    
    -- send each bit in data, LSB first if needed
    for i in data'high downto data'low loop
      rx <= data(i);
      wait for bit_time;
    end loop;
    
    -- return to idle
    rx <= '1';
    
    -- keep simulation running a bit longer so you can observe tx
    wait for 2*bit_time;
    for i in data'high downto data'low loop
      rx <= data(i);
      wait for bit_time;
    end loop;    
    -- finish simulation
    rx <= '1';
    wait;
  end process;

end Behavioral;
