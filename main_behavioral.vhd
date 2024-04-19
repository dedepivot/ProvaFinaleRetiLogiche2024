LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    type state_type is (SETUP, FIRSTREAD, IFZERO, IFNOTZERO, PRINTCREDIBILITY, SETUPINPUT, INPUT, ENDSTATE, PREREAD);
    signal next_state, current_state: state_type;
begin
    main: process(i_clk, i_rst) --check if main is a keyword
        variable credibility : std_logic_vector(4 downto 0);
        variable counter : std_logic_vector(9 downto 0);
        variable in_number : std_logic_vector(7 downto 0);

    begin
        if rising_edge(i_clk) then
            if (rising_edge(i_start) or i_start = '1') and i_rst = '0' then 
                case current_state is 
                    when SETUP =>
                        if i_k /= "0000000000" then
                            o_mem_en <= '1';
                            o_mem_addr <= i_add;
                            o_mem_we <= '0';
                            current_state <= PREREAD; 
                        else
                            current_state <= ENDSTATE;
                        end if;

                    when PREREAD =>
                        current_state <= FIRSTREAD;
                        
                    when FIRSTREAD =>
                        in_number := i_mem_data;
                        if in_number = "00000000" then
                            credibility := "00000";
                            current_state <= IFZERO;
                        else
                            current_state <= IFNOTZERO;
                        end if;
                        o_mem_we <= '1';       
                        counter := "0000000000"; --downto
                        
                        
                    when IFZERO =>
                        o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                        o_mem_data <= in_number;
                        if credibility /= "00000" then
                            credibility := std_logic_vector(UNSIGNED(credibility) - 1);
                        end if;
                        current_state <= PRINTCREDIBILITY;

                    when IFNOTZERO =>
                        o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                        o_mem_data <= in_number;
                        credibility := "11111";
                        current_state <= PRINTCREDIBILITY;
                        
                    when PRINTCREDIBILITY =>
                        o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter)+1); --address of credibility
                        o_mem_data <= "000" & credibility;
                        counter := std_logic_vector(UNSIGNED(counter)+2);
                        o_mem_we <= '0';
                        current_state <= SETUPINPUT;
                        

                    when SETUPINPUT =>
                        o_mem_addr <= std_logic_vector(UNSIGNED(i_add)+UNSIGNED(counter));
                        --o_mem_we <= '0';
                        current_state <= INPUT;
                    
                    when INPUT =>
                        if to_integer(UNSIGNED(counter)) > (2 * (to_integer(UNSIGNED(i_k)) - 1)) then 
                            current_state <= ENDSTATE; 
                        else
                            in_number := i_mem_data;
                            if in_number = "00000000" then 
                                current_state <= IFZERO;
                            else
                                current_state <= IFNOTZERO;
                            end if;
                            o_mem_we <= '1';    
                        end if;   
                        
                    when ENDSTATE =>
                        o_done <= '1';
                end case;
            elsif i_rst = '1' then --or rising-edge
                o_done <= '0';
                current_state <= SETUP;
            else    --soft reset cycle
                current_state <= SETUP;
                counter := "0000000000";
            end if;
        end if;
   end process;
end architecture;