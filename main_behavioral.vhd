use ieee.numeric_std.all

entity project_reti_logiche is
    port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_start : in std_logic;
            i_add : in std_logic_vector(15 downto 0);
            i_k   : in std_logic_vector(9 downto 0);
            
            o_done : out std_logic;
            
            o_mem_addr : out std_logic_vector(15 downto 0);
            i_mem_data : in  std_logic_vector(7 downto 0);
            o_mem_data : out std_logic_vector(7 downto 0);
            o_mem_we   : out std_logic;
            o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture fsm of project_reti_logiche is
    type state_type is (SETUP, FIRSTREAD, IFZERO, IFNOTZERO, PRINTCREDIBILITY, SETUPINPUT, INPUT, END);
    signal next_state, current_state: state_type;
begin
    state_reg: process (i_clk, i_rst)
    begin
        if i_rst = '1' then --or rising-edge
            o_done <= '0';
            next_state <= START; --tochange
            current_state <= START;

        elsif rising_edge(i_clk) then
            current_state <= next_state;
        else
            current_state <= current_state; --??
    end process;
    main: process(current_state, i_start) --check if main is a keyword
        variable credibility : std_logic_vector(4 downto 0);
        variable counter : std_logic_vector(15 downto 0);
        variable in_number : std_logic_vector(8 downto 0);

    begin
        if (rising_edge(i_start) or i_start = '1') and i_rst = '0' then 
            case current_state is 
                when SETUP =>
                    if i_k /= '0000000000' then
                        o_mem_en <= '1';
                        o_mem_addr <= i_add;
                        o_mem_we <= '0';
                        next_state <= FIRSTREAD; 
                    else
                        next_state <= END;
                when FIRSTREAD =>
                    in_number := i_mem_data;
                    if in_number = '00000000' then
                        credibility := '00000';
                        next_state <= IFZERO;
                    else
                        next_state <= IFNOTZERO;
                    o_mem_we <= '1';       
                    counter := '0000000000000000'; --downto
                
                when IFZERO =>
                    o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                    o_mem_data <= in_number;
                    if credibility /= '00000' then
                        credibility := std_logic_vector(UNSIGNED(credibility) - 1);
                    next_state <= PRINTCREDIBILITY;
                
                when IFNOTZERO =>
                    o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                    o_mem_data <= in_number;
                    credibility <= '11111';
                    next_state <= PRINTCREDIBILITY;
                
                
                when PRINTCREDIBILITY =>
                    o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter)+1); --address of credibility
                    o_mem_data <= credibility;
                    counter := std_logic_vector(UNSIGNED(counter)+2);
                    next_state <= SETUPINPUT;

                when SETUPINPUT =>
                    o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                    o_mem_we <= '0';
                    next_state <= INPUT
                
                when INPUT =>

                    in_number := i_mem_data;
                    if in_number = '00000000' then 
                        next_state <= IFZERO;
                    else
                        next_state <= IFNOTZERO;
                    o_mem_we <= '1';    
                
                when ENDSTATE =>
                    o_done <= '1';

        else    --soft reset
            next_state <= SETUP;
            counter <= '0000000000000000';
            current_state <= SETUP;