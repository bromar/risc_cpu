library IEEE;
use IEEE.STD_LOGIC_1164.all;

package cpu_constant_library is 

  -- opcodes
  constant OPCODE_R_TYPE       : std_logic_vector(5 downto 0)   := b"000000"; 
  constant OPCODE_LOAD_WORD    : std_logic_vector(5 downto 0)   := b"100011";
  constant OPCODE_STORE_WORD   : std_logic_vector(5 downto 0)   := b"101011"; 
  constant OPCODE_BRANCH_EQ    : std_logic_vector(5 downto 0)   := b"000100"; 
  
  -- funct
  constant FUNCT_LW           : std_logic_vector(5 downto 0)  := "------";
  constant FUNCT_SW           : std_logic_vector(5 downto 0)  := "------";
  constant FUNCT_BEQ          : std_logic_vector(5 downto 0)  := "------";
  constant FUNCT_ADD          : std_logic_vector(5 downto 0)  := b"100000";
  constant FUNCT_ADDU         : std_logic_vector(5 downto 0)  := b"100001";
  constant FUNCT_ADDI         : std_logic_vector(5 downto 0)  := "------";
  constant FUNCT_SUB          : std_logic_vector(5 downto 0)  := b"100010";
  constant FUNCT_SUBI         : std_logic_vector(5 downto 0)  := "------";
  constant FUNCT_AND          : std_logic_vector(5 downto 0)  := b"100100"; 
  constant FUNCT_OR           : std_logic_vector(5 downto 0)  := b"100101";
  constant FUNCT_NOR          : std_logic_vector(5 downto 0)  := b"100111";
  constant FUNCT_NOT          : std_logic_vector(5 downto 0)  := b"100111";
  constant FUNCT_SLT          : std_logic_vector(5 downto 0)  := b"101010";

  -- ALU signals
  constant ALU_LW             : std_logic_vector(3 downto 0)  := b"0010";
  constant ALU_SW             : std_logic_vector(3 downto 0)  := b"0010";
  constant ALU_BEQ            : std_logic_vector(3 downto 0)  := b"0110";
  constant ALU_ADD            : std_logic_vector(3 downto 0)  := b"0010";
  constant ALU_SUB            : std_logic_vector(3 downto 0)  := b"0110";
  constant ALU_AND            : std_logic_vector(3 downto 0)  := b"0000"; 
  constant ALU_OR             : std_logic_vector(3 downto 0)  := b"0001";
  constant ALU_NOR            : std_logic_vector(3 downto 0)  := b"1100";
  constant ALU_SLT            : std_logic_vector(3 downto 0)  := b"0111";  

end cpu_constant_library;


package body cpu_constant_library is 
end cpu_constant_library;
