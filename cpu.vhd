library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.cpu_component_library.all;

entity cs161_processor is
  port (
    clk            			: in std_logic;
    rst            			: in std_logic;
    
    -- Debug Signals
    current_instr		        : out std_logic_vector(31 downto 0);
    prog_count     			: out std_logic_vector(31 downto 0);
    instr_opcode   			: out std_logic_vector(5 downto 0);
    reg1_addr      			: out std_logic_vector(4 downto 0);
    reg1_data      			: out std_logic_vector(31 downto 0);
    reg2_addr      			: out std_logic_vector(4 downto 0);
    reg2_data      			: out std_logic_vector(31 downto 0);
    write_reg_addr 			: out std_logic_vector(4 downto 0);
    write_reg_data 			: out std_logic_vector(31 downto 0)
    );
end cs161_processor;

architecture Behavioral of cs161_processor is
	--memory component signals
	signal mem_in_rst 			: std_logic		        := '0';
	signal mem_in_instr_read_address 	: std_logic_vector(7 downto 0)	:= (others=>'0');
	signal mem_out_instr_instruction	: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mem_in_data_mem_write 		: std_logic		        := '0';
	signal mem_in_data_address 		: std_logic_vector(7 downto 0)	:= (others=>'0');
	signal mem_in_data_write_data 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mem_out_data_read_data 		: std_logic_vector(31 downto 0)	:= (others=>'0');
		
	--mux component signals
	signal mux_in_select_in 		: std_logic		        := '0';
	signal mux_in_data_0_in 		: std_logic_vector(4 downto 0)	:= (others=>'0');
	signal mux_in_data_1_in 		: std_logic_vector(4 downto 0)	:= (others=>'0');
	signal mux_out_data_out 		: std_logic_vector(4 downto 0)	:= (others=>'0');
		
	--mux2 component signals
	signal mux2_in_select_in 		: std_logic			:= '0';
	signal mux2_in_data_0_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux2_in_data_1_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux2_out_data_out 		: std_logic_vector(31 downto 0)	:= (others=>'0');
		
	--mux3 component signals
	signal mux3_in_select_in 		: std_logic			:= '0';
	signal mux3_in_data_0_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux3_in_data_1_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux3_out_data_out 		: std_logic_vector(31 downto 0)	:= (others=>'0');
		
	--mux4 component signals
	signal mux4_in_select_in 		: std_logic			:= '0';
	signal mux4_in_data_0_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux4_in_data_1_in 		: std_logic_vector(31 downto 0)	:= (others=>'0');
	signal mux4_out_data_out 		: std_logic_vector(31 downto 0)	:= (others=>'0');

	--control compoenent signals
	signal control_in_instr_op          : std_logic_vector(5 downto 0)                      := (others=>'0');
	signal control_out_reg_dst          : std_logic						:= '0';
	signal control_out_branch           : std_logic						:= '0';
	signal control_out_mem_read         : std_logic						:= '0';
	signal control_out_mem_to_reg       : std_logic						:= '0';
	signal control_out_alu_op           : std_logic_vector(1 downto 0)                      := (others=>'0');
	signal control_out_mem_write        : std_logic						:= '0';
	signal control_out_alu_src          : std_logic						:= '0';
	signal control_out_reg_write        : std_logic						:= '0';

	--cpu registers component signals
	signal cpureg_in_rst                : std_logic						:= '0';
	signal cpureg_in_reg_write          : std_logic						:= '0';
	signal cpureg_in_read_register_1    : std_logic_vector(4 downto 0)	:= (others=>'0');
	signal cpureg_in_read_register_2    : std_logic_vector(4 downto 0)	:= (others=>'0');
	signal cpureg_in_write_register     : std_logic_vector(4 downto 0)	:= (others=>'0');
	signal cpureg_in_write_data         : std_logic_vector(31 downto 0)	:= (others=>'0');
	signal cpureg_out_read_data_1       : std_logic_vector(31 downto 0)	:= (others=>'0');
	signal cpureg_out_read_data_2       : std_logic_vector(31 downto 0)	:= (others=>'0');

	--alu component signals
	signal alu_in_alu_control_in        : std_logic_vector(3 downto 0)	:= (others=>'0');
        signal alu_in_channel_a_in          : std_logic_vector(31 downto 0)	:= (others=>'0');
        signal alu_in_channel_b_in          : std_logic_vector(31 downto 0)	:= (others=>'0');
        signal alu_out_zero_out             : std_logic				:= '0';
        signal alu_out_alu_result_out       : std_logic_vector(31 downto 0)	:= (others=>'0');
		
	--alu_control component signals
	signal alucontrol_in_alu_op             : std_logic_vector(1 downto 0)	:= (others=>'0');
	signal alucontrol_in_instruction_5_0    : std_logic_vector(5 downto 0)	:= (others=>'0');
	signal alucontrol_out_alu_out           : std_logic_vector(3 downto 0)	:= (others=>'0');
      
begin

	--** Instantiate Components **--
	
		--ALU component
		ALU : alu port map (
				alu_in_alu_control_in,
				alu_in_channel_a_in,
				alu_in_channel_b_in,
				alu_out_zero_out,
				alu_out_alu_result_out
			);
			
		--CPU Registers component
		CPUREG : cpu_registers port map (
				cpureg_in_rst,
				cpureg_in_reg_write,
				cpureg_in_read_register_1,
				cpureg_in_read_register_2,
				cpureg_in_write_register,
				cpureg_in_write_data,
				cpureg_out_read_data_1,
				cpureg_out_read_data_2
			);
			
		--Instantiate memory component
		MEM : memory 
			generic map(COE_FILE_NAME => "init.coe")
			port map (
				mem_in_rst, 
				mem_in_instr_read_address, 
				mem_out_instr_instruction, 
				mem_in_data_mem_write,
				mem_in_data_address, 
				mem_in_data_write_data, 
				mem_out_data_read_data 
			);
		
		--Instantiate control unit component
		CONTROL : control_unit port map (
				control_in_instr_op,
				control_out_reg_dst,
				control_out_branch,
				control_out_mem_read,
				control_out_mem_to_reg,
				control_out_alu_op,
				control_out_mem_write,
				control_out_alu_src,
				control_out_reg_write
			);
		
		--Instantiate mux component
		MUX : mux_2_1 
			generic map(SIZE => 5)
			port map(
				mux_in_select_in,
				mux_in_data_0_in,
				mux_in_data_1_in,
				mux_out_data_out
			);
			
		--Another mux to right of cpureg
		MUX2 : mux_2_1 
			generic map(SIZE => 32)
			port map(
				mux2_in_select_in,
				mux2_in_data_0_in,
				mux2_in_data_1_in,
				mux2_out_data_out
			);
			
		--Another mux to right of cpureg
		MUX3 : mux_2_1 
			generic map(SIZE => 32)
			port map(
				mux3_in_select_in,
				mux3_in_data_0_in,
				mux3_in_data_1_in,
				mux3_out_data_out
			);
			
		--Right most mux for memory
		MUX4 : mux_2_1 
			generic map(SIZE => 32)
			port map(
				mux4_in_select_in,
				mux4_in_data_0_in,
				mux4_in_data_1_in,
				mux4_out_data_out
			);
			
		--Instantiate alucontrol component
		ALUCONTROL : alu_control port map(
				alucontrol_in_alu_op,
				alucontrol_in_instruction_5_0,
				alucontrol_out_alu_out
			);

	--** Done Instantiating Components **--
	
	--Main process
	process(clk, rst)
	
		variable tmp_instr_15_0         : std_logic_vector(31 downto 0) := (others=>'0');
		variable tmp_branch_pc_holder   : std_logic_vector(31 downto 0)	:= (others=>'0');
		variable tmp_instruction_holder : std_logic_vector(31 downto 0)	:= (others=>'0');
		variable tmp_pc                 : std_logic_vector(31 downto 0)	:= (others=>'0');
		
	begin
		--Check for reset and initialize memory
			if( rst = '1' ) then
				mem_in_rst <= '1';
				prog_count <= (others=>'0');
				tmp_pc := (others=>'0');
				
			elsif rising_edge(clk) then
				mem_in_instr_read_address <= tmp_pc(7 downto 0);
				current_instr <= mem_out_instr_instruction;
				tmp_instruction_holder := mem_out_instr_instruction;
			
			--Pass parts of instruction code to controlunit, mux, registers, alucontrol
				control_in_instr_op <= mem_out_instr_instruction(31 downto 26); --control unit
				cpureg_in_read_register_1 <= mem_out_instr_instruction(25 downto 21); --reg1 input
				cpureg_in_read_register_2 <= mem_out_instr_instruction(20 downto 16); --reg2 input
				mux_in_data_0_in <= mem_out_instr_instruction(20 downto 16); --mux1 input
				mux_in_data_1_in <= mem_out_instr_instruction(15 downto 11); --mux2 input
				alucontrol_in_instruction_5_0 <= mem_out_instr_instruction( 5 downto  0); --alucontrol input
			
			--Control tells mux what to pass through
				mux_in_select_in <= control_out_reg_dst;
			--Mux passes appropritate data to cpureg
				cpureg_in_write_register <= mux_out_data_out;
			
			--SignXend 15 downto 0
				tmp_instr_15_0(15 downto 0) := mem_out_instr_instruction(15 downto 0);
				--Signextend
				if( tmp_instr_15_0(15) = '0' ) then
					tmp_instr_15_0(31 downto 16) := (others=>'0');
				else
					tmp_instr_15_0(31 downto 16) := (others=>'1');
				end if;
			
			--set up branch mux
				mux3_in_data_0_in <= unsigned(tmp_pc) + 1;
				mux3_in_data_1_in <= ( unsigned(tmp_instr_15_0) + 8 ) + tmp_instr_15_0;
				
			--mux after reg before alu
				mux2_in_data_0_in <= cpureg_out_read_data_2;
				mux2_in_data_1_in <= tmp_instr_15_0;
				--Control sends alusrc signal
				mux2_in_select_in <= control_out_alu_src;
			
			--ALU
				alu_in_channel_a_in	 <= cpureg_out_read_data_1;
				alu_in_channel_b_in <= mux2_out_data_out;
				--send control signal
				alu_in_alu_control_in <= alucontrol_out_alu_out;
			
			--Handle branch with alu zero output
				--Mux for branch
				mux3_in_select_in <= alu_out_zero_out AND control_out_branch;
				--mux3 passes correct input to pc
				prog_count <= mux3_out_data_out;
			
			--Memory now gets alu input
				mem_in_data_address <= alu_out_alu_result_out(7 downto 0);
				mem_in_data_write_data <= cpureg_out_read_data_2;
				--send control signals for memory
				mem_in_data_mem_write <= control_out_mem_write;
				mem_in_data_mem_write <= control_out_mem_read;
			
			--Memory sends output to mux
				mux4_in_data_0_in <= mem_out_data_read_data;
				mux4_in_data_0_in <= alu_out_alu_result_out;
				--send control signal for mux
				mux4_in_select_in <= control_out_mem_to_reg;
			
			--cpu reg gets writing data
				cpureg_in_write_data <= mux4_out_data_out;
		
			--Debug signals for cpu processor, prog_count already set
				instr_opcode <= mem_out_instr_instruction(31 downto 26);
				reg1_addr <= mem_out_instr_instruction(25 downto 21);
				reg1_data <= cpureg_out_read_data_1;
				reg2_addr <= mem_out_instr_instruction(20 downto 16);
				reg2_data <= cpureg_out_read_data_2;
				write_reg_addr <= mux_out_data_out;
				write_reg_data <= mux4_out_data_out;
				
				tmp_pc := unsigned(tmp_pc) + 1;
		
		else
			--do nothing
		end if;
	
	end process;
	
end Behavioral;
