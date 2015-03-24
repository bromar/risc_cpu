library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity my_alu is
	generic( NUMBITS : integer := 8 );
	
	Port( A : in std_logic_vector(NUMBITS-1 downto 0);
	    B : in std_logic_vector(NUMBITS-1 downto 0);
	    opcode : in std_logic_vector(2 downto 0);

            result : out std_logic_vector(NUMBITS-1 downto 0);
            carryout : out std_logic;
            overflow : out std_logic;
            zero : out std_logic

        );
end my_alu;

architecture Behavioral of my_alu is

begin
    process(opcode, A, B)
        variable tmp    : std_logic_vector(NUMBITS downto 0)    := "000000000";
        variable tmpA   : std_logic_vector(NUMBITS-1 downto 0)  := "00000000";
        variable tmpB   : std_logic_vector(NUMBITS-1 downto 0)  := "00000000";
		
		begin
		    case opcode is
		        when "000" => --unsigned add
		            tmp := ('0' & A)+('0' & B);
		            result <= tmp(NUMBITS-1 downto 0);
		            carryout <= tmp(NUMBITS); 
		            --check overflow
		            if tmp(NUMBITS) = '1' then
		                overflow <= '1';
		            else
		                overflow <= '0';
		            end if;
		            --check if zero
		            if tmp(NUMBITS-1 downto 0) = "00000000" then
		                zero <= '1';
		            else
		                zero <= '0';
		            end if;
		
		        when "001" => --signed add
		            --Pad A and B with MSB
		            if A(NUMBITS-1) = '1' then
		                tmpA = ('1' & A);
		            else
		                tmpA <= ('0' & A);
		            end if;
		            if B(NUMBITS-1) = '1' then
		                tmpB <= ('1' & B);
		            else
		                tmpB <= ('0' & B);
		            end if;
		            --get result and carryout bit
		            tmp <= tmpA + tmpB;
		            result <= tmp(NUMBITS-1 downto 0);
		            carryout <= tmp(NUMBITS);
		            --check for overflow
		            if tmp < "0" AND tmpA >= "0" AND tmpB >= "0" then
		                overflow <= '1';
		            elsif tmp >= "0" AND tmpA < "0" and tmpB < "0" then
		                overflow <= '1';
		            else 
		                overflow <= '0';
		            end if;
		            --check if zero
		            if A = "00000000" then
		                zero <= '0';
		            end if;

                when "010" => --unsigned sub
                    tmp <= ('0' & A)-('0' & B);
                    result <= tmp(NUMBITS-1 downto 0);
                    carryout <= tmp(NUMBITS);
                    --check for overflow
                    if tmp(NUMBITS) = '0' then
                        carryout <= '1';
                    else
                        carryout <= '0';
                    end if;
                    --check if zero
                    if A = "00000000" then
                        zero <= '0';
                    end if;
					
				when "011" => --signed sub
				    if A(NUMBITS-1) = '1' then
				        tmpA <= ('1' & A);
				    else
				        tmpA <= ('0' & A);
				    end if;
				    if B(NUMBITS-1) = '1' then
				        tmpB <= ('1' & B);
				    else
				        tmpB <= ('0' & B);
				    end if;
				    tmp <= tmpA - tmpB;
				    result <= tmp(NUMBITS-1 downto 0);
				    carryout <= tmp(NUMBITS);
				    if tmp < "0" and tmpA >= "0" and tmpB < "0" then
				        overflow <= '1';
				    elsif tmp >= "0" and tmpA < "1" and tmpB >= "0" then
				        overflow <= '1';
				    else 
				        overflow <= '0';
				    end if;
				    --check if zero
				    if A = "00000000" then
				        zero <= '0';
				    end if;

                when "100" => --bit-wise AND
                    result <= A AND B;
                    --check if zero
                    if A = "00000000" then
                        zero <= '0';
                    end if;
		
		        when "101" => --bit-wise OR
		            result <= A OR B;
		            --check if zero
		            if A = "00000000" then
		                zero <= '0';
		            end if;
		
				when "110" => --bit-wise XOR
				    result <= A XOR B;
				    --check if zero
				    if A = "00000000" then
				        zero <= '0';
				    end if;

                when "111" => --divide A by 2
                    tmp <= ('0' & A);
                    result <= tmp(NUMBITS downto 1);
                    --check if zero
                    if A = "00000000" then
                        zero <= '0';
                    end if;
					
				when OTHERS => --Default
				    result <= "00000000";
			end case;
	end process;
end Behavioral;
