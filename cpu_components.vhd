library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
  generic (
    SIZE        : natural   := 4
  );
  port (
    clk         : in std_logic;
    rst         : in std_logic;
    write_en    : in std_logic;
    data_in     : in std_logic_vector(SIZE-1 downto 0);
    data_out    : out std_logic_vector(SIZE-1 downto 0)
  );
end generic_register;

architecture Behavioral of generic_register is

begin

  process (clk, rst)
  begin
    if rst = '1' then
      data_out <= (others => '0');
      
    elsif rising_edge(clk) then
      if write_en = '1' then
        data_out <= data_in;
      end if;
      
    end if;
  end process;
  
end Behavioral;

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_1 is
  generic(
    SIZE           : natural   := 4
  );
  port (
    select_in      : in std_logic;
    data_0_in      : in std_logic_vector(SIZE-1 downto 0);
    data_1_in      : in std_logic_vector(SIZE-1 downto 0);
    data_out       : out std_logic_vector(SIZE-1 downto 0)
  );
end mux_2_1;

architecture Behavioral of mux_2_1 is

begin

  process (select_in, data_0_in, data_1_in)
  begin
    case select_in is
      when '0'    =>    data_out <= data_0_in;
      when '1'    =>    data_out <= data_1_in;
      when others =>    data_out <= (others => '0');
    end case;
  end process;

end Behavioral;

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity cpu_registers is
  port (
    rst               : in std_logic;
    reg_write         : in std_logic;
    read_register_1   : in std_logic_vector(4 downto 0);
    read_register_2   : in std_logic_vector(4 downto 0);
    write_register    : in std_logic_vector(4 downto 0);
    write_data        : in std_logic_vector(31 downto 0);
    read_data_1       : out std_logic_vector(31 downto 0);
    read_data_2       : out std_logic_vector(31 downto 0)
    );
end cpu_registers;

architecture Behavioral of cpu_registers is
  type REG_BUFF is array(0 to 31) of std_logic_vector(31 downto 0);
  signal registers   : REG_BUFF;

begin

  process (rst, read_register_1, read_register_2)
  begin
    if rst = '1' then
      read_data_1 <= (others => '0');
      read_data_2 <= (others => '0');
    else
      read_data_1 <= registers(conv_integer(read_register_1));
      read_data_2 <= registers(conv_integer(read_register_2));
    end if;
    
  end process;
  
  process (rst, reg_write, write_data)
  begin
    if rst = '1' then
      for i in 31 downto 0 loop
        registers(i) <= (others => '0');
      end loop;
    else
      if reg_write = '1' then
        registers(conv_integer(write_register)) <= write_data;
      end if;
    end if;
    
  end process;

end Behavioral;

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.cpu_constant_library.all;
use work.cpu_component_library.all;

entity alu is
  port (
    alu_control_in : in std_logic_vector(3 downto 0);
    channel_a_in   : in std_logic_vector(31 downto 0);
    channel_b_in   : in std_logic_vector(31 downto 0);
    zero_out       : out std_logic;
    alu_result_out : out std_logic_vector(31 downto 0)
    );
end alu;

architecture Behavioral of alu is
  signal result_s   : std_logic_vector(31 downto 0);

begin
 
  process (alu_control_in, channel_a_in, channel_b_in)
  begin
    case alu_control_in is
      when ALU_AND         => result_s <= channel_a_in and channel_b_in;
      when ALU_OR          => result_s <= channel_a_in or channel_b_in;
      when ALU_ADD         => result_s <= channel_a_in + channel_b_in;
      when ALU_SUB    => result_s <= channel_a_in - channel_b_in;
      when ALU_SLT   => if channel_a_in < channel_b_in then
                                 result_s <= (others => '0');
                              else
                                 result_s <= (others => '1');
                              end if;
      when ALU_NOR         => result_s <= channel_a_in nor channel_b_in;
      when others          => result_s <= (others => '0');
    end case;
  end process;

  alu_result_out <= result_s;
  zero_out <= '1' when result_s = 0 else '0';

end Behavioral;

-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
-- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity memory is
  generic (
    COE_FILE_NAME        : string   := "init.coe"
    );
  port (
    rst                  : in std_logic;
    instr_read_address   : in std_logic_vector(7 downto 0);
    instr_instruction    : out std_logic_vector(31 downto 0);
    data_mem_write       : in std_logic;
    data_address         : in std_logic_vector(7 downto 0);
    data_write_data      : in std_logic_vector(31 downto 0);
    data_read_data       : out std_logic_vector(31 downto 0)
    );
end memory;

architecture Behavioral of memory is
  type MEMORY_BUFFER is array(255 downto 0) of std_logic_vector(31 downto 0);
  signal buff      : MEMORY_BUFFER;
  file     coe_file  :   text;
begin

  process (rst, instr_read_address, data_mem_write, data_address, data_write_data)
	 
    variable coe_line  :   line;
    variable coe_str   :   bit_vector(31 downto 0);
    variable coe_status:   file_open_status;
  begin
    if rst = '1' then
	 
     file_open(coe_status, coe_file, COE_FILE_NAME, READ_MODE);
		 
      if coe_status = OPEN_OK then
        for i in 0 to 255 loop
          if not endfile(coe_file) then
            readline(coe_file, coe_line);
            read(coe_line, coe_str);
            buff(i) <= to_StdLogicVector(coe_str);
          else
            buff(i) <= (others => '0');
          end if;
        end loop;
        file_close(coe_file);
      else
        report "Could not open COE file" severity warning;
        for i in 0 to 255 loop
          buff(i) <= (others => '0');
        end loop;
        
      end if;
      
      instr_instruction <= (others => '0');
		data_read_data      <= (others => '0');
    else
      instr_instruction <= buff(conv_integer(instr_read_address));
      
      if data_mem_write = '1' then
        buff(conv_integer(data_address)) <= data_write_data;
        data_read_data <= data_write_data;
      else
        data_read_data <= buff(conv_integer(data_address));
      end if;
      
    end if;
  end process;

end Behavioral;
