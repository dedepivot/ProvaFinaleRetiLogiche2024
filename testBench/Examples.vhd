LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity esempio1 is
    port (
        in1, in2, in3 : in std_logic;
        out1 : out std_logic;
        out2 : out std_logic;
    );
end entity;

architecture dataflow of esempio1 is

begin
    out1 <= in1 and in2 and in3;
    out2 <= (in1 and in2) or in3: 
end architecture;
--Somma tra due ingressi a 32bit in cpl2
entity sommatore is
    port (
        in1, in2: in std_logic_vector(31 downto 0);
        out1: out std_logic_vector(31 downto 0);
        ovf: out std_logic;
    );
end entity;
--Non puoi fare la somma tra due vettori. Creo una signal "sum" che è 
--il cavetto su cui verrà eseguita la somma tra in1 e in2
architecture dataflow of sommatore is
    signal sum : SIGNED(31 downto 0);
    signal msb : std_logic;
begin
    sum <= SIGNED(in1) + SIGNED(in2);
    out1 <= std_logic_vector(sum);
    msb <= std_logic(sum(31));
    ovf <= (in1(31) and in2(31) and not msb) or
            (not in1(31) and not in2(31) and msb);
end architecture;
--NB SIGNED e STD_LOGIC non sono compatibili, devo fare un cast esplicito

--Esempio 4

entity es4 is
    port (
        in1 : in std_logic_vector(31 downto 0);
        out1 :  out std_logic_vector(31 downto 0);
    );
end entity;

architecture dataflow of es4 is
    signal cpl1, inv1 : std_logic_vector(31 downto 0);
begin
    cpl1 <= not ('0' & in1(30 downto 0)); --con la & concateno lo 0 a in1
    inv1 <= std_logic_vector(signed(cpl1) + 1); --con signed faccio cast di cpl1 cosi da poter fare la somma, poi ritrasformo in vector perchè è una possibile uscita che ho dichiarato come vecto nella parte di entity
    out1 <= in1 when in1(31) = '0' else
    inv1;
end architecture;

--definizione di un segnale constante
constant foo : std_logic_vector(31 downto 0) :=
(1 downto 0 => '1', 4 => '1', others => '0');
--ho creato un vettore con tutti zeri, tranne per il 4ultimo bit e gli ultimi 2

--Esempio 5 con lunghezza N parametrica. è UN MUTEX CON CTRL CHE FA SELZIONE E DUE INGRESSI DI LUNGHEZZA N
--FAI AND CON CTRL 0 E OR CON CTRL 1

entity es5 is
    generic (
        N: integer := 5 -- ":" assegnano l'etichetta N a un integer. Con := assegno il valore 5 a N
    );
    port (
      in1: in std_logic_vector(N-1 downto 0);
      in2: in std_logic_vector(N-1 downto 0); 
      ctrl: in std_logic;
      out1: out std_logic_vector(N-1 downto 0);
    );
end entity;

architecture dataflow of es5 is
-- metti when "others" per indicare il caso default nel caso di selezione con when else
begin
    out1 <= (in1 and in2) when ctrl = "0" else,
            (in1 or in2)  when others;
            --equivalente a scrivere all'ultima riga "(in1 or in2)" senza metttere when e others.
end architecture;

--Esempio 6 voglio un modulo che esegue AND/OR in base a un segnale di controllo
--RIUSA IL COMPONENTE 5

entity es6 is
    port (
        in1: in std_logic_vector(31 downto 0);
        in2: in std_logic_vector(31 downto 0); 
        in3: in std_logic_vector(31 downto 0);
        ctrl: in std_logic;
        out1: out std_logic_vector(31 downto 0);
    );
end entity;

architecture dataflow of es6 is
    signal tmp : std_logic_vector(31 downto 0);
    --importo il componente "component" non è altro che la ENTITY DEL MODULO 
    component es5 is
        generic (N : integer := 5);
        port(
            in1, in2 : in std_logic_vector(N-1 downto 0);
            ctrl : in std_logic;
            out1 : out std_logic_vector(N-1 downto 0)
        );
        end component;
begin
    --dichiaro blocco1 come una ISTANZA di es5
    blocco1 : es5
        generic map(32)  --assegno a N (generic) 32
        port map(in1, in2, ctrl, tmp) --mappo le porte del es5 alle porte che ho al blocco
    blocco2 : es5  
        generic map(32)
        port map(in1 => temp, in2=>in3, ctrl => ctrl, out1=>out1);
        --equivalente a: port map(temp, in3,ctrl, out1)
        --usa "open" permette di lasciare una porta non connessa
end architecture;

--DESCRIZIONE COMPORTAMENTALE--
--Permette la descrizione dei programmi in maniera più astratta e simile alla esecuzione di algoritmi--

entity es1Dataflow is
    port (
        in1, in2, in3: in std_logic;
        out1, out2: out std_logic;
    );
end entity es1Dataflow;

architecture dataflow of es1Dataflow is
    signal temp : std_logic;
begin
    out1<= in1 and in2 and in3;
    temp<= in1 and in2;
    out2 <= temp or in3;
end architecture;

entity es1Comporamentale is
    port (
        in1, in2, in3: in std_logic;
        out1, out2: out std_logic;
    );
end entity es1Comporamentale;

architecture behavioral of es1Comporamentale is

begin --inizio della architecture
    nomeprocesso: process(in1, in2, in3) --nomeprocesso è l'eticchetta facoltativa che identitica il processo
        variable tmp1, tmp2 : std_logic; --dichiaro le variabili
    begin --inizio del process
            --comunica tra esterno e interno con i segnali. Lavora all'interno con le variabili
        tmp1 := in3 and in2; --Assegnamento a VARIABILE, simbolo ":=" ISTANTANEO
        out1 <= tmp1 and in1; --Assegnamento a SEGNALE, simbolo "<=" DOPO LA FINE DEL PROCESSO
        tmp2 := in1 and in2;--Assegnamento a VARIABILE
        out2 <= tmp2 or in3;--Assegnamento a SEGNALE
    end nomeprocesso;
    --scrivi qui (fuori dal processo) per avere un comportamento Dataflow
    --hai un comportamento CONCORRENTE al processo. Le righe NEL processo hanno comportamento sequenziale
end architecture;

--Esercizio 8

entity Alu is
    generic (
     N: integer := 32;
    );
    port (
        in1, in2 : in std_logic_vector(N-1 downto 0);
        ctrl : in std_logic_vector(2 downto 0)
        out1 : out std_logic_vector(N-1 downto 0);
    );
end entity Alu;

architecture behavioural of Alu is
    process (in1, in2, ctrl)
    begin
    --se un SEGNALE è usato in un ramo, DEVE essere in TUTTI i rami
    if ctrl = "000" then
        out1 <= in1 and in2;
    elsif ctrl = "001" then
        out1 <= in1 or in2;
    elsif ctrl = "010" then
        out1 <= std_logic_vector(SIGNED(in1) + SIGNED(in2));
    elsif ctrl = "011" then
        out1 <= std_logic_vector(SIGNED(in1) - SIGNED(in2));
    elsif ctrl = "100" then
        if in1=in2 then
            out1 <= (0 => '1', (others => '0') ); --assegna al LSB 1 e agli altri 0
        else
            out1 <= ((others => '0'));
        end if;
    else
        out1 <= ((others => '0'));
    --alternativa con case
    case ctrl is
        when "000" =>
            out1 <= in1 and in2;
        when "001" =>
            out1 <= in1 or in2;
        when others =>
            out1 <= ((others => '0'));
        end case
    end process;
begin

end architecture;

--esempio 9: restituisci 1 se tutti i bit in ingresso sono 1
--fai end bit a bit di tutti gli elementi in ingresso

entity esempio9 is
    generic (
        N: integer := 5;
    );
    port (
        in1: in std_logic_vector(N-1 downto 0);
        out1: out std_logic
    );
end entity esempio9;

architecture behavioral of esempio9 is
    process (in1)
        variable tmp : std_logic;
    begin
        tmp := in1(N-1);
        for i in N-2 downto 0 loop --Itero tra il secondo bit più significativo e LSB
            tmp := tmp and in1(i);
        end loop;
        out1 <= tmp;
    end process;
begin

end architecture;

--flip flop con processasync (processo asincrono)
entity esempio11 is
    port (
        clk   : in std_logic;
        rst : in std_logic;
        in1 : in std_logic;
        out1: out std_logic;
    );
end entity esempio11;

architecture rtl of esempio11 is
    process (clk, rst, in1)
    begin
        if rst = '1' then
            out1 <= '0';
        elsif rising_edge(clk) then
            out1 <= in1;
        end if;
    end process;
begin

end architecture;

entity esempio12 is
    port (
        clk   : in std_logic;
        rst : in std_logic;
        in1 : in std_logic;
        out1: out std_logic;
    );
end entity esempio12;

architecture rtl of esempio12 is
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                out1 <= '0';
            else
                out1 <= in1;
            end if;
        end if;
    end process;
beginc

end architecture;

entity esempio14 is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        in1, in2: in std_logic;
        out1, out2: out std_logic;
    );
end entity esempio14;

architecture rtl of esempio14 is
    component esempio11 is
        port (
            clk   : in std_logic;
            rst : in std_logic;
            in1 : in std_logic;
            out1: out std_logic;
        );
    end component
begin
    --ricorda a sinistra trovi la porta di esempio11 a destra quello che gli assegno
    FFD1 : esempio11
        port map (
            clk   => clk,
            rst => reset,
            in1 => not in1,
            out1 => out1
        );
    FFD2: esempio11
        port map (
            clk   => clk,
            rst => reset,
            in1 => not in1 and in2,
            out1 => out2
        );
end architecture;

--DICHIARAZIONE DI UNA FSM--
--Scrivere una macchina di Moore che riconosce la seguenza 001

entity esempio15 is
    port (
        clk   : in std_logic;
        rst : in std_logic;
        i: in std_logic;
        o: out std_logic
    );
end entity esempio15;

architecture FSM of esempio15 is
    type state_type is (S0, S1, S2, S3); 
    --Definisco un enum "state_type" e definisco i valori che può assumere
    signal next_state, current_state: state_type;
begin
    state_reg: process (clk, reset) --Processo per gestire stato corrente, successivo e reset
    begin
        if reset = '1' then
            current_state <= S0; --se il reset è on, resetta la macchina a S0
        elsif rising_edge(clk) then
            current_state <= next_state; --ad ogni colpo di clock aggiorna lo stato corrente
        end if;
    end process;
    lamda: process(current_state, i) --processo che gestisce il salto a un nuovo stato
        begin
            case current_state is
                when S0 =>
                    if i='0' then
                        next_state <= S1;
                    else
                        next_state <= S0;
                    end if;
                when S1 =>
                    if i='0' then
                        next_state <= S2;
                    else
                        next_state <= S0;
                    end if;  
                when S2 =>
                    if i='0' then
                        next_state <= S2;
                    else
                        next_state <= S3;
                    end if;
                when S3 =>
                    if i='1' then
                        next_state <= S1;
                    else
                        next_state <= S0;
                    end if;   
            end case;
        end process;
    delta: process (current_state) --gestisce il valore dell'uscita in base a current_state
    begin
        case current_state is
            when S0 =>
                o <= '0';
            when S1 =>
                o <= '0';
            when S2 =>
                o <= '0';
            when S3 =>
                o <= '1';
        end case;
    end process;
end FSM;





