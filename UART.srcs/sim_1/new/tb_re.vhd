-- Testbench for UART receiver entity `re`
-- Created for behavioral simulation and debugging

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_re is
end tb_re;

architecture Behavioral of tb_re is
    -- DUT ports as signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal tick  : std_logic := '1';  -- always high to trigger sampling each clk
    signal rx    : std_logic := '1';  -- idle high
    signal dout  : std_logic_vector(7 downto 0);
    signal rx_d  : std_logic;
    signal tran  : std_logic_vector(1 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
begin
    -- Instantiate DUT
    dut: entity work.re
        port map (
            rst   => rst,
            clk   => clk,
            tick  => tick,
            rx    => rx,
            dout  => dout,
            rx_d  => rx_d,
            tran  => tran
        );

    -- Clock generation
    clk_process : process
    begin
        while True loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process clk_process;

    -- Stimulus process
    stim_proc: process
        -- Send one bit on rx for 16 clock cycles
        procedure send_bit(b : std_logic) is
        begin
            rx <= b;
            for i in 0 to 15 loop
                wait until rising_edge(clk);
            end loop;
        end procedure;

        -- Send a full byte: LSB first, with start/stop bits
        procedure send_byte(data : std_logic_vector(7 downto 0)) is
        begin
            -- Start bit (low)
            send_bit('0');
            -- Data bits
            for idx in 0 to 7 loop
                send_bit(data(idx));
            end loop;
            -- Stop bit (high)
            send_bit('1');
        end procedure;
    begin
        -- Reset pulse
        rst <= '1';
        wait for 2*CLK_PERIOD;
        rst <= '0';
        wait until rising_edge(clk);

        -- Send test byte 0x5A
        send_byte(x"5A");
        
        -- Allow time for the DUT to output
        wait for 100*CLK_PERIOD;

        -- Check result
        assert dout = x"5A"
            report "[TEST FAILED] Expected dout = 5A, got " & to_hstring(dout)
            severity error;

        report "[TEST PASSED] Received byte: " 
            severity note;

        wait;
    end process stim_proc;

end Behavioral;
