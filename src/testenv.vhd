----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.03.2023 10:07:03
-- Design Name: 
-- Module Name: test_env - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testenv is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end testenv;

architecture Behavioral of testenv is
signal Instruction, PCinc, RD1, RD2, WD, Ext_Imm:  STD_LOGIC_VECTOR(15 downto 0);
signal BranchAddress, JumpAddress, MemData, AluRes, AluRes1: STD_LOGIC_VECTOR(15 downto 0);
signal rt, rd, func, rWA: STD_LOGIC_VECTOR(2 downto 0);
signal sa, Zero: STD_LOGIC;
signal digits: STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc: STD_LOGIC;

--MAIN CONTROLS
signal ALUOp: STD_LOGIC_VECTOR(2 downto 0);
signal RegDest, ALUSrc, Jump, MemWrite, MemtoReg, RegWrite, Branch, ExtOp: STD_LOGIC;


--PIPEINE REGISTRE
--IF_ID
signal Instruction_IF_ID, PC_1_IF_ID: STD_LOGIC_VECTOR(15 downto 0);
--ID_EX
signal PC_1_ID_EX, Ext_imm_ID_EX, RD2_ID_EX, RD1_ID_EX: STD_LOGIC_VECTOR(15 downto 0);
signal rt_ID_EX, rd_ID_EX, func_ID_EX, ALUOp_ID_EX: STD_LOGIC_VECTOR(2 downto 0);
signal sa_ID_EX, RegWrite_ID_EX, MemtoReg_ID_EX, MemWrite_ID_EX, Branch_ID_EX, ALUSrc_ID_EX, RegDst_ID_EX: STD_LOGIC;
--EX_MEM
signal RD2_EX_MEM, ALURes_EX_MEM, BranchAddress_EX_MEM: STD_LOGIC_VECTOR(15 downto 0);
signal rd_EX_MEM: STD_LOGIC_VECTOR(2 downto 0);
signal Zero_EX_MEM, RegWrite_EX_MEM, MemtoReg_EX_MEM, MemWrite_EX_MEM, Branch_EX_MEM: STD_LOGIC;
--MEM_WB
signal  MemData_MEM_WB, ALURes_MEM_WB: STD_LOGIC_VECTOR(15 downto 0);
signal rd_MEM_WB: STD_LOGIC_VECTOR(2 downto 0);
signal RegWrite_MEM_WB, MemtoReg_MEM_WB: STD_LOGIC;

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
 Port ( clk: in STD_LOGIC;
          digits: in STD_LOGIC_VECTOR(15 downto 0);
          an: out STD_LOGIC_VECTOR(3 downto 0);
          cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component InstructionFetch is
  Port(J: in std_logic;
      JA: in std_logic_vector(15 downto 0);
      PCS: in std_logic;
      BA: in std_logic_vector(15 downto 0);
      en: in std_logic;
      rst: in std_logic;
      clk: in std_logic;
      PC: out std_logic_vector(15 downto 0);
      instr: out std_logic_vector(15 downto 0));
end component;

component ID is
     Port ( instr: in std_logic_vector(15 downto 0);
            clk: in std_logic;
            en: in std_logic;
            wd: in std_logic_vector(15 downto 0);
            rd1: out std_logic_vector(15 downto 0);
            rd2: out std_logic_vector(15 downto 0);
            ext_imm: out std_logic_vector(15 downto 0);
            func: out std_logic_vector(2 downto 0);
            sa: out std_logic;
            RegWrite: in std_logic;
            WA: in std_logic_vector(2 downto 0);
            ExtOp: in std_logic;
            rt, rd: out std_logic_vector(2 downto 0));
end component;

component MainControl is
    Port( Instr: in STD_LOGIC_VECTOR(15 downto 13);
          RegDest: out STD_LOGIC;
          ExtOp: out STD_LOGIC;
          ALUSrc: out STD_LOGIC;
          Branch: out STD_LOGIC;
          Jump: out STD_LOGIC;
          ALUOp: out STD_LOGIC_VECTOR(2 downto 0);
          MemWrite: out STD_LOGIC;
          MemtoReg: out STD_LOGIC;
          RegWrite: out STD_LOGIC);
end component;

component EX is
     Port( RD1: in STD_LOGIC_VECTOR(15 downto 0);
         ALUSrc: in STD_LOGIC;
         RD2: in STD_LOGIC_VECTOR(15 downto 0);
         Ext_Imm: in STD_LOGIC_VECTOR(15 downto 0);
         sa: in STD_LOGIC;
         func: in STD_LOGIC_VECTOR(2 downto 0);
         ALUOp: in STD_LOGIC_VECTOR(2 downto 0);
         PcInc: in STD_LOGIC_VECTOR(15 downto 0);
         rt: in STD_LOGIC_VECTOR(2 downto 0);
         rd: in STD_LOGIC_VECTOR(2 downto 0);
         RegDst: in STD_LOGIC;
         Zero: out STD_LOGIC;
         ALURes: out STD_LOGIC_VECTOR(15 downto 0);
         BranchAddress: out STD_LOGIC_VECTOR(15 downto 0);
         rWA: out STD_LOGIC_VECTOR(2 downto 0));              
end component;

component MEM is
    Port( MemWrite: in STD_LOGIC; 
          ALUResIn: in STD_LOGIC_VECTOR(15 downto 0); 
          RD2: in STD_LOGIC_VECTOR(15 downto 0);
          clk: in STD_LOGIC;
          en: in STD_LOGIC;
          MemData: out STD_LOGIC_VECTOR(15 downto 0);
          ALUResOut: out STD_LOGIC_VECTOR(15 downto 0));
end component;


begin

	monopulse1: MPG port map(en, btn(0), clk);
	monopulse2: MPG port map(rst, btn(1), clk);
	inst_IF: InstructionFetch port map(Jump, JumpAddress, PCSrc, BranchAddress_EX_MEM, en, rst, clk, PCinc, Instruction);
	inst_ID: ID port map(Instruction_IF_ID, clk, en, WD, RD1, RD2, Ext_Imm, func, sa, RegWrite_MEM_WB, rd_MEM_WB, ExtOp, rt, rd);
	inst_MC: MainControl port map(Instruction_IF_ID(15 downto 13), RegDest, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
	inst_EX: EX port map(RD1_ID_EX, ALUSrc_ID_EX, RD2_ID_EX, Ext_Imm_ID_EX, sa_ID_EX, func_ID_EX, ALUOp_ID_EX, PC_1_ID_EX, rt_ID_EX, rd_ID_EX, RegDst_ID_EX, Zero, AluRes, BranchAddress, rWA);
	inst_MEM: MEM port map(MemWrite_EX_MEM, AluRes_EX_MEM, RD2_EX_MEM, clk, en, MemData, AluRes1);
	display: SSD port map(clk, digits, an, cat);
	
	
	with MemtoReg_MEM_WB select
	  WD <= MemData_MEM_WB when '1',
	        ALURes_MEM_WB when '0',
	        (others => 'X') when others;
	
	PCSrc <= Zero_EX_MEM and Branch_EX_MEM;
	JumpAddress <= PC_1_IF_ID(15 downto 13) & Instruction_IF_ID(12 downto 0);
	
    process(clk)
    begin
        if rising_edge(clk) then 
            if en='1' then 
                --IF_ID
                PC_1_IF_ID <= PCinc;
                Instruction_IF_ID <= Instruction;
                --ID_EX
                PC_1_ID_EX <= PC_1_IF_ID;
                RD1_ID_EX <= RD1;
                RD2_ID_EX <= RD2;
                Ext_imm_ID_EX <= Ext_imm;
                sa_ID_EX <= sa;
                func_ID_EX <= func;
                rt_ID_EX <= rt;
                rd_ID_EX <= rd;
                MemtoReg_ID_EX <= MemtoReg;
                RegWrite_ID_EX <= RegWrite;
                MemWrite_ID_EX <= MemWrite;
                Branch_ID_EX <= Branch; 
                ALUSrc_ID_EX <= ALUSrc;
                ALUOp_ID_EX <= ALUOp;
                RegDst_ID_EX <= RegDest;
                --EX_MEM
                BranchAddress_EX_MEM <= BranchAddress;
                Zero_EX_MEM <= Zero;
                ALURes_EX_MEM <= ALURes;
                RD2_EX_MEM <= RD2_ID_EX;
                rd_EX_MEM <= rWA;
                MemtoReg_EX_MEM <= MemtoReg_ID_EX;
                RegWrite_EX_MEM <= RegWrite_ID_EX;
                MemWrite_EX_MEM <= MemWrite_ID_EX;
                Branch_EX_MEM <= Branch_ID_EX; 
                --MEM_WB
                MemData_MEM_WB <= MemData;
                ALURes_MEM_WB <= ALURes1;
                rd_MEM_WB <= rd_EX_MEM;
                MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
                RegWrite_MEM_WB <= RegWrite_EX_MEM;
             end if;
          end if;
      end process;
                
                
	with sw(7 downto 5) select
  	    digits <=  Instruction when "000",
  	               PCinc when "001",
  	               RD1_ID_EX when "010",
  	               RD2_ID_EX when "011",
  	               Ext_Imm_ID_EX when "100",
  	               ALURes when "101",
  	               MemData when "110",
  	               WD when "111",
		      (others => 'X') when others;

	
	led(10 downto 0) <= ALUOp & RegDest & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;