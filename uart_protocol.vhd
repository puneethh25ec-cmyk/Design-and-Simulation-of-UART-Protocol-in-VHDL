library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_protocol is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        tx_start  : in  STD_LOGIC;
        tx_data   : in  STD_LOGIC_VECTOR(7 downto 0);
        rx        : in  STD_LOGIC;
        tx        : out STD_LOGIC;
        rx_data   : out STD_LOGIC_VECTOR(7 downto 0);
        tx_busy   : out STD_LOGIC;
        rx_ready  : out STD_LOGIC
    );
end uart_protocol;

architecture Behavioral of uart_protocol is

    constant CLK_FREQ  : integer := 50000000;
    constant BAUD_RATE : integer := 9600;
    constant BAUD_TICK : integer := CLK_FREQ / BAUD_RATE;

    signal baud_counter : integer range 0 to BAUD_TICK-1 := 0;

    signal tx_reg       : STD_LOGIC := '1';
    signal tx_busy_reg  : STD_LOGIC := '0';
    signal tx_shift     : STD_LOGIC_VECTOR(9 downto 0) := (others => '1');
    signal tx_count     : integer range 0 to 9 := 0;

    signal rx_sync      : STD_LOGIC := '1';
    signal rx_shift     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_count     : integer range 0 to 7 := 0;
    signal rx_active    : STD_LOGIC := '0';
    signal rx_ready_reg : STD_LOGIC := '0';

begin

    tx <= tx_reg;
    tx_busy <= tx_busy_reg;
    rx_data <= rx_shift;
    rx_ready <= rx_ready_reg;

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                baud_counter <= 0;
                tx_reg <= '1';
                tx_busy_reg <= '0';
                tx_shift <= (others => '1');
                tx_count <= 0;

                rx_sync <= '1';
                rx_shift <= (others => '0');
                rx_count <= 0;
                rx_active <= '0';
                rx_ready_reg <= '0';

            else

                rx_sync <= rx;

                if baud_counter = BAUD_TICK-1 then
                    baud_counter <= 0;

                    -- UART TRANSMITTER
                    if tx_busy_reg = '0' then
                        if tx_start = '1' then
                            tx_shift <= '1' & tx_data & '0';
                            tx_busy_reg <= '1';
                            tx_count <= 0;
                            tx_reg <= '0';
                        end if;

                    else
                        tx_reg <= tx_shift(tx_count);

                        if tx_count = 9 then
                            tx_busy_reg <= '0';
                            tx_reg <= '1';
                            tx_count <= 0;
                        else
                            tx_count <= tx_count + 1;
                        end if;
                    end if;

                    -- UART RECEIVER
                    if rx_active = '0' then
                        if rx_sync = '0' then
                            rx_active <= '1';
                            rx_count <= 0;
                            rx_ready_reg <= '0';
                        end if;

                    else
                        rx_shift(rx_count) <= rx_sync;

                        if rx_count = 7 then
                            rx_active <= '0';
                            rx_ready_reg <= '1';
                        else
                            rx_count <= rx_count + 1;
                        end if;
                    end if;

                else
                    baud_counter <= baud_counter + 1;
                    rx_ready_reg <= '0';
                end if;

            end if;
        end if;
    end process;

end Behavioral;
