library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_protocol_tb is
end uart_protocol_tb;

architecture Behavioral of uart_protocol_tb is

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '1';
    signal tx_start : STD_LOGIC := '0';
    signal tx_data  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx       : STD_LOGIC := '1';

    signal tx       : STD_LOGIC;
    signal rx_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal tx_busy  : STD_LOGIC;
    signal rx_ready : STD_LOGIC;

begin

    clk <= not clk after 10 ns;

    DUT: entity work.uart_protocol
        port map (
            clk       => clk,
            reset     => reset,
            tx_start  => tx_start,
            tx_data   => tx_data,
            rx        => rx,
            tx        => tx,
            tx_busy   => tx_busy,
            rx_data   => rx_data,
            rx_ready  => rx_ready
        );

    process
    begin
        reset <= '1';
        wait for 100 ns;

        reset <= '0';
        wait for 100 ns;

        tx_data <= "10101010";
        tx_start <= '1';
        wait for 20 ns;

        tx_start <= '0';

        wait for 2 ms;

        assert false
            report "UART simulation completed successfully"
            severity failure;
    end process;

end Behavioral;
