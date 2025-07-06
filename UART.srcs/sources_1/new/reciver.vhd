library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity re is
  port(
    rst    : in  std_logic;
    clk    : in  std_logic;
    tick   : in  std_logic;  -- baud tick
    rx     : in  std_logic;
    dout   : out std_logic_vector(7 downto 0);
    rx_d   : out std_logic;
    tran   : out std_logic_vector(1 downto 0)
  );
end re;

architecture Behavioral of re is
  type state_t is (idl, start, data, stop);
  signal ps, ns : state_t;

  signal sample, next_sample : unsigned(4 downto 0) := (0 => '1' ,others => '0');
  signal size_cnt, next_size : unsigned(3 downto 0) := (0 => '1',others => '0');

  signal shift_reg, next_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal dout_reg, next_dout   : std_logic_vector(7 downto 0) := (others => '0');
  signal rx_done, next_rx_done : std_logic := '0';

  -- mid-sample flags
  signal sample7   : std_logic;
  signal sample15  : std_logic;
  signal sz8       : std_logic;
  
begin
sync_proc: process(clk, rst)
  begin
    if rst = '1' then
      ps         <= idl;
      sample     <= (0 => '1',others => '0');
      size_cnt   <= (0 => '1',others => '0');
      shift_reg  <= (others => '0');
      dout_reg   <= (others => '0');
      rx_done    <= '0';
    elsif rising_edge(clk) then
      ps         <= ns;
      sample     <= next_sample;
      size_cnt   <= next_size;
      shift_reg  <= next_reg;
      dout_reg   <= next_dout;
      rx_done    <= next_rx_done;
    end if;
end process;

combi_proc: process(ps, rx, tick, sample, size_cnt, shift_reg, rx_done)
begin
    ns           <= ps;
    next_sample  <= sample;
    next_size    <= size_cnt;
    next_reg     <= shift_reg;
    next_dout    <= dout_reg;
    next_rx_done <= '0';
    tran         <= "00";

    case ps is
      when idl =>
        tran <= "01";
        if rx = '0' then  -- start bit detected
          next_sample <= (0 => '1',others => '0');
          ns <= start;
        end if;

      when start =>
        tran <= "10";
        if tick = '1' then
          if sample7 = '1' then  -- mid of start bit
            next_sample <= (0 => '1',others => '0');
            next_size   <= (0 => '1',others => '0');
            ns <= data;
          else
            next_sample <= sample + 1;
          end if;
        end if;

      when data =>
        tran <= "11";
        if tick = '1' then
          if sample15 = '1' then 
            next_sample <= (0 => '1',others => '0');
            next_reg <= rx & shift_reg(7 downto 1);
            if sz8 = '1' then 
              ns <= stop;
            else
              next_size <= size_cnt + 1;
            end if;
          else
            next_sample <= sample + 1;
          end if;
        end if;

      when stop =>
        tran <= "00";
        if tick = '1' then
          if sample15 = '1' then  
            next_dout    <= shift_reg;
            next_rx_done <= '1';
            ns <= idl;
          else
            next_sample <= sample + 1;
          end if;
        end if;

      when others =>
        ns <= idl;
    end case;
end process;

dout <= dout_reg;
rx_d <= rx_done;

sample7  <= '1' when sample(3) = '1' and sample(4) = '0' else '0';
sample15 <= '1' when sample(4) = '1' else '0';
sz8      <= '1' when size_cnt(3) = '1' else '0'; 

end Behavioral;
