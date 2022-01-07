library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
	S_LUI
    );

    signal state_d, state_q : State_type;
    signal cmd_cs : PO_cs_cmd;


    function arith_sel (IR : unsigned( 31 downto 0 ))
        return ALU_op_type is
        variable res : ALU_op_type;
    begin
        if IR(30) = '0' or IR(5) = '0' then
            res := ALU_plus;
        else
            res := ALU_minus;
        end if;
        return res;
    end arith_sel;

    function logical_sel (IR : unsigned( 31 downto 0 ))
        return LOGICAL_op_type is
        variable res : LOGICAL_op_type;
    begin
        if IR(12) = '1' then
            res := LOGICAL_and;
        else
            if IR(13) = '1' then
                res := LOGICAL_or;
            else
                res := LOGICAL_xor;
            end if;
        end if;
        return res;
    end logical_sel;

    function shifter_sel (IR : unsigned( 31 downto 0 ))
        return SHIFTER_op_type is
        variable res : SHIFTER_op_type;
    begin
        res := SHIFT_ll;
        if IR(14) = '1' then
            if IR(30) = '1' then
                res := SHIFT_ra;
            else
                res := SHIFT_rl;
            end if;
        end if;
        return res;
    end shifter_sel;

begin

    cmd.cs <= cmd_cs;

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.rst               <= ’0’;
        cmd.ALU_op            <= ’0’;
        cmd.LOGICAL_op        <= ’0’;
        cmd.ALU_Y_sel         <= ’0’;

        cmd.SHIFTER_op        <= ’0’;
        cmd.SHIFTER_Y_sel     <= ’0’;

        cmd.RF_we             <= ’0’;
        cmd.RF_SIZE_sel       <= ’0’;
        cmd.RF_SIGN_enable    <= ’0’;
        cmd.DATA_sel          <= ’0’;

        cmd.PC_we             <= ’0’;
        cmd.PC_sel            <= ’0’;

        cmd.PC_X_sel          <= ’0’;
        cmd.PC_Y_sel          <= ’0’;

        cmd.TO_PC_Y_sel       <= ’0’;

        cmd.AD_we             <= ’0’;
        cmd.AD_Y_sel          <= ’0’;

        cmd.IR_we             <= ’0’;

        cmd.ADDR_sel          <= ’0’;
        cmd.mem_we            <= ’0’;
        cmd.mem_ce            <= ’0’;

        cmd_cs.CSR_we            <= ’0’;

        cmd_cs.TO_CSR_sel        <= ’0’;
        cmd_cs.CSR_sel           <= ’0’;
        cmd_cs.MEPC_sel          <= ’0’;

        cmd_cs.MSTATUS_mie_set   <= ’0’;
        cmd_cs.MSTATUS_mie_reset <= ’0’;

        cmd_cs.CSR_WRITE_mode    <= ’0’;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                state_d <= S_Error;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_ce <= '1';
                state_d <= S_Fetch;

            when S_Fetch =>
                -- IR <- mem_datain
                cmd.IR_we <= '1';
                state_d <= S_Decode;

            when S_Decode =>
                -- PC <- PC + 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

                state_d <= S_Init;
		if status.IR(6 downto 0) = "0110111" then
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= ’1’; 
			state_d <= S_LUI;
			elsestate_d <= S_Error;
			 -- Pour d ́etecter les rates du d ́ecodage
		end if;
	   
	   when S_LUI =>
		-- rd <- ImmU + 0
		cmd.PC_X_sel <= PC_X_cst_x00;
		cmd.PC_Y_sel <= PC_Y_immU;
		cmd.RF_we <= ’1’;
		cmd.DATA_sel <= DATA_from_pc;
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= ’1’;
		cmd.mem_we <= ’0’;
		-- next state
		state_d <= S_Fetch;
	    

                -- Décodage effectif des instructions,
                -- à compléter par vos soins

---------- Instructions avec immediat de type U ----------

---------- Instructions arithmétiques et logiques ----------

---------- Instructions de saut ----------

---------- Instructions de chargement à partir de la mémoire ----------

---------- Instructions de sauvegarde en mémoire ----------

---------- Instructions d'accès aux CSR ----------

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
