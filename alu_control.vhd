library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cpu_constant_library.all;

entity alu_control is
  port (
    alu_op            : in std_logic_vector(1 downto 0);
    instruction_5_0   : in std_logic_vector(5 downto 0);
    alu_out           : out std_logic_vector(3 downto 0)
    );
end alu_control;

architecture Behavioral of alu_control is
 
begin
	process(alu_op, instruction_5_0)
		begin
			case alu_op is
		
				when b"00" => --lw and sw
					alu_out <= ALU_LW;
				
				when b"01" => --beq
					alu_out <= ALU_BEQ;
				
				when b"10" => --R type
					if( instruction_5_0 = FUNCT_ADD ) then
						alu_out <= ALU_ADD;
							
					elsif( instruction_5_0 =  FUNCT_ADDU ) then
						alu_out <= ALU_ADD;
							
					elsif( instruction_5_0 = FUNCT_ADDI ) then
						alu_out <= ALU_ADD;
							
					elsif( instruction_5_0 = FUNCT_SUB ) then
						alu_out <= ALU_SUB;
						
					elsif( instruction_5_0 = FUNCT_SUBI ) then
						alu_out <= ALU_ADD;
							
					elsif( instruction_5_0 = FUNCT_AND ) then
						alu_out <= ALU_AND;
							
					elsif( instruction_5_0 = FUNCT_OR ) then
						alu_out <= ALU_OR;
							
					elsif( instruction_5_0 = FUNCT_NOR ) then
						alu_out <= ALU_NOR;
							
					elsif( instruction_5_0 = FUNCT_NOT ) then
						alu_out <= ALU_NOR;
							
					elsif( instruction_5_0 = FUNCT_SLT ) then
						alu_out <= ALU_SLT;
							
					else
						alu_out <= b"0000";
						
					end if;
							
				when OTHERS => --Default
					alu_out <= b"0000";
				
			end case;
	
		end process;

end Behavioral;
