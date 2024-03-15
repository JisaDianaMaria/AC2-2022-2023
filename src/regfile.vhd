library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity reg_file is
port ( clk : in STD_LOGIC; 
       ra1 : in STD_LOGIC_VECTOR (2 downto 0);
       ra2 : in STD_LOGIC_VECTOR (2 downto 0);
       wa : in STD_LOGIC_VECTOR (2 downto 0);
       wd : in STD_LOGIC_VECTOR (15 downto 0);
       wen : in STD_LOGIC;
       en : in STD_LOGIC;
       rd1 : out STD_LOGIC_VECTOR (15 downto 0);
       rd2 : out STD_LOGIC_VECTOR (15 downto 0));
end reg_file;

architecture Behavioral of reg_file is

type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg_file : reg_array;
    
begin
    
process(clk)
begin
    if falling_edge(clk) then
       if wen = '1' and en='1' then
         reg_file(conv_integer(wa)) <= wd;
       end if;
    end if;
    end process;
    
rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));

end Behavioral;