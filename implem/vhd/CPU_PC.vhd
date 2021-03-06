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
	S_LUI,
	S_ADDI,
	S_ADD, 
	S_SUB,
	S_SLL,
	S_AUIPC,
	S_AND,
	S_ANDI,
	S_OR,
	S_XOR,
	S_SRL,
	S_SRLI,
	S_SLLI, 
	S_BEQ, 
	S_TOTO,
	S_SLT,
	S_BRANCH,
	S_SLTU,
	S_SLTI,
	S_SLTIU,
	S_BNE,
	S_BLT,
	S_BGE,
	S_BLTU,
	S_BGEU,
	S_ORI,
	S_XORI,
	S_SRA,
	S_SRAI,
	S_LW,
	S_LW2,
	S_LW3,
	S_SW,
	S_SW2,
	S_SW3
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

        -- Valeurs par d??faut de cmd ?? d??finir selon les pr??f??rences de chacun
        cmd.rst               <= '0';
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_XOR;
        cmd.ALU_Y_sel         <= ALU_Y_immI;

        cmd.SHIFTER_op        <= SHIFT_rl;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= DATA_from_alu;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_alu;

        cmd.PC_X_sel          <= PC_X_pc;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_immJ;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd_cs.CSR_we            <= UNDEFINED;

        cmd_cs.TO_CSR_sel        <= UNDEFINED;
        cmd_cs.CSR_sel           <= UNDEFINED;
        cmd_cs.MEPC_sel          <= UNDEFINED;

        cmd_cs.MSTATUS_mie_set   <= 'U';
        cmd_cs.MSTATUS_mie_reset <= 'U';

        cmd_cs.CSR_WRITE_mode    <= UNDEFINED;

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
			cmd.PC_we <= '1'; 
			state_d <= S_LUI;

		elsif status.IR(6 downto 0) = "0010011" then

			if status.IR(14 downto 12) = "111" then
					state_d <= S_ANDI;
			elsif status.IR(14 downto 12) = "000" then
					state_d <= S_ADDI;
			elsif status.IR(14 downto 12) = "001" then
					state_d <= S_SLLI;
			elsif status.IR(14 downto 12) = "101" then
				
				if status.IR(31 downto 25) = "0100000" then
					state_d <= S_SRAI;
				elsif status.IR(31 downto 25) = "0000000" then
					state_d <= S_SRLI;
				end if;

			elsif status.IR(14 downto 12) = "010" then
			           state_d <= S_SLTI;
			elsif status.IR(14 downto 12) = "110" then
			           state_d <= S_ORI;
			elsif status.IR(14 downto 12) = "100" then
			           state_d <= S_XORI;
			elsif status.IR(14 downto 12) = "011" then
			           state_d <= S_SLTIU;
			
			end if;
			
		elsif status.IR(6 downto 0) = "0010111" then
			state_d <= S_AUIPC;

		elsif status.IR(6 downto 0) = "1100011" then
			if status.IR(14 downto 12) = "000" then
					cmd.PC_we <= '0';
					state_d <= S_BEQ;
			elsif status.IR(14 downto 12) = "001" then
					cmd.PC_we <= '0';
					state_d <= S_BNE;
			elsif status.IR(14 downto 12) = "100" then
					cmd.PC_we <= '0';
					state_d <= S_BLT;
			elsif status.IR(14 downto 12) = "101" then
					cmd.PC_we <= '0';
					state_d <= S_BGE;
			elsif status.IR(14 downto 12) = "110" then
					cmd.PC_we <= '0';
					state_d <= S_BLTU;
			elsif status.IR(14 downto 12) = "111" then
					cmd.PC_we <= '0';
					state_d <= S_BGEU;

			end if;

		elsif status.IR(6 downto 0) = "0110011" then
			if status.IR(31 downto 25) = "0100000" then 
				if status.IR(14 downto 12) = "000" then
					state_d <= S_SUB;
				elsif status.IR(14 downto 12) = "101" then
					state_d <= S_SRA;
				end if;
			
			elsif status.IR(31 downto 25) = "0000000" then
				if status.IR(14 downto 12) = "001" then
					state_d <= S_SLL;
				elsif status.IR(14 downto 12) = "000" then
					state_d <= S_ADD;
				elsif status.IR(14 downto 12) = "111" then
					state_d <= S_AND;
				elsif status.IR(14 downto 12) = "110" then
					state_d <= S_OR;
				elsif status.IR(14 downto 12) = "100" then
					state_d <= S_XOR;
				elsif status.IR(14 downto 12) = "101" then
					state_d <= S_SRL;
				elsif status.IR(14 downto 12) = "010" then
			           state_d <= S_SLT;
				elsif status.IR(14 downto 12) = "011" then
			           state_d <= S_SLTU;
				end if;
			end if;

		elsif status.IR(6 downto 0) = "0000011" then
			if status.IR(14 downto 12) = "010" then
					state_d <= S_LW;
			end if;

		elsif status.IR(6 downto 0) = "0100011" then
			if status.IR(14 downto 12) = "010" then
					state_d <= S_SW;
			end if;
			

		else
                        state_d <= S_Error;
			 -- Pour d ??etecter les rates du d ??ecodage
		end if;
	   
	   when S_LUI =>
		-- rd <- ImmU + 0
		cmd.PC_X_sel <= PC_X_cst_x00;
		cmd.PC_Y_sel <= PC_Y_immU;
		cmd.RF_we <= '1';
		cmd.DATA_sel <= DATA_from_pc;
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	   when S_ADDI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.ALU_op <= ALU_plus;
		cmd.DATA_sel <= DATA_from_alu;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	   when S_ADD =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.ALU_op <= ALU_plus;
		cmd.DATA_sel <= DATA_from_alu;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	   when S_AND =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_OP <= LOGICAL_and;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_ANDI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_OP <= LOGICAL_and;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_OR =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_OP <= LOGICAL_or;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	
	when S_ORI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_OP <= LOGICAL_or;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	
	when S_XOR =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.LOGICAL_OP <= LOGICAL_xor;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_XORI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.LOGICAL_OP <= LOGICAL_xor;
		cmd.DATA_sel <= DATA_from_logical;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

           when S_SUB =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.ALU_op <= ALU_minus;
		cmd.DATA_sel <= DATA_from_alu;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
		
		
	  when S_SLL => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
		cmd.SHIFTER_op <= SHIFT_ll;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	
	when S_SRA => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
		cmd.SHIFTER_op <= SHIFT_ra;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_SRAI => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
		cmd.SHIFTER_op <= SHIFT_ra;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	  when S_SLLI => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
		cmd.SHIFTER_op <= SHIFT_ll;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	 when S_SRL => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_rs2;
		cmd.SHIFTER_op <= SHIFT_rl;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	 when S_SRLI => 
		cmd.SHIFTER_Y_SEL <= SHIFTER_Y_ir_sh;
		cmd.SHIFTER_op <= SHIFT_rl;
		cmd.DATA_sel <= DATA_from_shifter;
		cmd.RF_we <= '1';
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
		
	  when S_AUIPC => 
	-- rd <- ImmU + 0
		cmd.PC_X_sel <= PC_X_pc;
		cmd.PC_Y_sel <= PC_Y_immU;
		cmd.RF_we <= '1';
		cmd.DATA_sel <= DATA_from_pc;
		-- lecture mem[PC]
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_TOTO =>
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;
	
	when S_SLT =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_SLTI =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	when S_SLTU =>
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;

	
	when S_SLTIU =>
		cmd.ALU_Y_sel <= ALU_Y_immI;
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_Fetch;





	when S_LW =>

                cmd.AD_we <= '1';
		cmd.AD_Y_sel  <= AD_Y_immI;
		-- next state
		state_d <= S_LW2;

	when S_LW2 =>

		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		
		-- next state
		state_d <= S_LW3;
	when S_LW3 =>
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		cmd.RF_we <= '1';
		cmd.RF_SIZE_sel <= RF_SIZE_word;
		cmd.DATA_sel <= DATA_from_mem;
		-- next state
		state_d <= S_FETCH;
		
	when S_SW =>

                cmd.AD_we <= '1';
		cmd.AD_Y_sel  <= AD_Y_immI;
		-- next state
		state_d <= S_SW2;

	when S_SW2 =>

		cmd.ADDR_sel <= ADDR_from_ad;
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		
		-- next state
		state_d <= S_SW3;
	when S_SW3 =>
		cmd.mem_ce <= '1';
		cmd.mem_we <= '1';
		cmd.RF_we <= '1';
		cmd.RF_SIZE_sel <= RF_SIZE_word;
		cmd.DATA_sel <= DATA_from_mem;
		-- next state
		state_d <= S_FETCH;
		






	when S_BEQ =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;


	when S_BNE =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;

	when S_BLT =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;

	when S_BLTU =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;
                
	when S_BGEU =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;
	when S_BGE =>
	
		cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
		if status.JCOND then
			
			cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
		else 
			cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
			cmd.PC_sel <= PC_from_pc;
			cmd.PC_we <= '1';
			-- next state
			state_d <= S_BRANCH;	
	
		end if;
		
		

	when S_BRANCH =>
		cmd.ADDR_sel <= ADDR_from_pc;
		cmd.RF_we <= '1';
		cmd.mem_ce <= '1';
		cmd.mem_we <= '0';
		-- next state
		state_d <= S_FETCH;



				
				
		
	    

                -- D??codage effectif des instructions,
                -- ?? compl??ter par vos soins

---------- Instructions avec immediat de type U ----------

---------- Instructions arithm??tiques et logiques ----------

---------- Instructions de saut ----------

---------- Instructions de chargement ?? partir de la m??moire ----------

---------- Instructions de sauvegarde en m??moire ----------

---------- Instructions d'acc??s aux CSR ----------

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
