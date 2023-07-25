`include "caminho_dados.sv"
`include "Display.sv"

module caminho();

	reg clock;
	reg reset;
	reg ok1;
	reg ok2;
	wire [31:0] instrucao;
	wire [31:0][11:0] Memoria_entrada;
	wire [31:0][11:0]Registers_entrada;
	
	wire alu;
	wire mem;
	wire REG;
	wire control;
	wire line;
	wire [11:0] WriteMem;
	
	wire ALUScr;
	wire Branch;
	wire MemRead;
	wire MemtoReg;
	wire MemWrite;
	wire RegWrite;
	
	wire [4:0] rd;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [11:0] sum;
	wire [1:0] ALUOp;
	wire [11:0] data1;
	wire [11:0] data2;
	wire [6:0] opcode;
	wire [11:0] linha;
	wire [3:0] ALUcontrol;
	wire [11:0] ALUresult;
	wire [11:0] Writedata;
	wire signed [11:0] ImmGen;
	wire [31:0][11:0] Memoria_saida;
	wire [31:0][11:0] Registers_saida;
	wire [7:0] max;
	
	instructions instru(
		.clock(clock),
		.reset(reset),
		.linha(linha),
		.max(max),
		.Registers(Registers_saida),
		.Memoria(Memoria_saida),

		.instrucao(instrucao)
	);
	
	PC comp (	
		.clock(clock),
		.reset(reset),
		.line(line),
		.sum(sum),
		.instrucao(instrucao), 
		
		.linha(linha),
		.rd(rd), 
		.rs1(rs1), 
		.rs2(rs2), 
		.opcode(opcode)
	);
	
	Control controle (
		.instrucao(instrucao),
		.opcode(opcode),
		.clock(clock),

		.Branch(Branch),
		.MemRead(MemRead),
		.MemtoReg(MemtoReg),
		.ALUOp(ALUOp),
		.MemWrite(MemWrite),
		.ALUScr(ALUScr),
		.RegWrite(RegWrite),
		.ALUcontrol(ALUcontrol),
		.ImmGen(ImmGen),
		.control(control)	
	);
		
	Registradores registers(	
		.rd(rd),
		.rs1(rs1),
		.rs2(rs2),
		.reset(reset),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.Branch(Branch),
		.Writedata(Writedata),
		.ALUScr(ALUScr),
		.ImmGen(ImmGen),
		.ALUresult(ALUresult),
		.control(control),
		.mem(mem),
		.Registers_entrada(Registers_entrada),
		
		.Registers_saida(Registers_saida),
		.data1(data1),
		.data2(data2),
		.REG(REG),
		.WriteMem(WriteMem)
	);
	
		
	ALU  operacao(	
		.data1(data1),
		.data2(data2),
		.ALUcontrol(ALUcontrol),
		.ImmGen(ImmGen),
		.REG(REG),
		.Branch(Branch),
		.linha(linha),
		
		.ALUresult(ALUresult),
		.sum(sum),
		.line(line),
		.alu(alu)	
	);
	
	Memory m(	
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.MemtoReg(MemtoReg),
		.alu(alu),
		.reset(reset),
		.ALUresult(ALUresult),
		.Memoria_entrada(Memoria_entrada),
		.WriteMem(WriteMem),
			
		.Memoria_saida(Memoria_saida),
		.Writedata(Writedata),
		.mem(mem)
		
	);	
	
	SevenSegmentConverter ssc(
			  .number(linha),
			  .segments1(),
			  .segments2()
	);

	SevenSegmentConverter2 ssc1(
			  .r(ok1),
			  .m(ok2),
			  .number1(Registers_saida),
			  .number2(Memoria_saida),
			  .segments1(),
			  .segments2(),
			  .display1(),
			  .display2(),
			  .display3(),
			  .display4(),
			  .led()
	);

	initial begin
		#0 reset = 1;
		#2 reset = 0;
		#20 clock = 1'b0;
		repeat(18) #20 clock = ~clock;
		#20 $display("\n\t--------------------- REGISTRADORES ---------------------------"); 
		#20 ok1 = 1;
		repeat(63) #20 ok1 = ~ok1;
		#20 ok2 = 1;
		#20 $display("\n\t--------------------- MEMÓRIA ------------------------"); 
		repeat(64) #20 ok2 = ~ok2;
		#5 $finish;
	end
endmodule

