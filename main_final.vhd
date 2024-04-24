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
    type state_type is (SETUP, ENDSTATE, FIRSTREADWRITE, SETUPIDLE, PRINTCREDIBILITY, IDLEINPUT, INPUT, IDLE);
    signal current_state: state_type;
begin
    main: process(i_clk, i_rst)
        variable in_value: std_logic_vector(7 downto 0);
        variable credibility: std_logic_vector(7 downto 0);
        variable counter: std_logic_vector(9 downto 0);
    begin
        if (rising_edge(i_clk)) then
            if ((i_start = '1' or rising_edge(i_start)) and i_rst = '0') then
                case current_state is  
                    when SETUP => 
                        o_mem_en <= '1';
                        counter := "0000000000";
                        if(i_k = "0000000000") then
                            current_state <= ENDSTATE;
                        else
                            o_mem_we <= '0';
                            o_mem_addr <= i_add;
                            current_state <= SETUPIDLE;
                        end if;
                    
                    when SETUPIDLE =>
                        current_state <= FIRSTREADWRITE;
                        --in_value = i_mem_data
                        --o_mem_addr <= i_add + counter 


                    when FIRSTREADWRITE =>
                        in_value := i_mem_data;
                        o_mem_we <= '1';
                        if(in_value /= "00000000") then 
                            credibility := "00011111"; 
                        else
                            credibility := "00000000";
                        end if;
                        current_state <= PRINTCREDIBILITY;
                        o_mem_data <= in_value;

                    when PRINTCREDIBILITY =>
                        o_mem_addr <= std_logic_vector(UNSIGNED(counter)+UNSIGNED(i_add)+1);
                        o_mem_data <= credibility;
                        o_mem_we <= '0';
                        current_state <= IDLEINPUT;
                    
                    when IDLEINPUT =>
                        counter := std_logic_vector(UNSIGNED(counter)+2);
                        o_mem_addr <= std_logic_vector(UNSIGNED(counter)+UNSIGNED(i_add));
                        current_state <= IDLE;

                    when IDLE =>
                        current_state <= INPUT;
                    
                    when INPUT =>
                        if to_integer(UNSIGNED(counter)) > (2 * (to_integer(UNSIGNED(i_k)) - 1)) then 
                            current_state <= ENDSTATE; 
                        else
                            if(i_mem_data /= "00000000") then 
                                credibility := "00011111"; 
                                in_value := i_mem_data;
                            else
                                if(credibility /= "00000000") then
                                    credibility := std_logic_vector(UNSIGNED(credibility)-1);
                                end if;
                            end if;
                            o_mem_we <= '1';
                            o_mem_data <= in_value;
                            current_state <= PRINTCREDIBILITY;
                        end if;

                    when ENDSTATE =>
                        o_mem_en <= '0';
                        o_done <= '1';
                    
                    end case;
                
            else --(rising_edge(i_rst) or i_rst = '1' ) --(i_start = '0') then
                o_done <= '0';
                current_state <= SETUP;
            end if;
        else
            current_state <= current_state;
        end if;
    end process;
end architecture;