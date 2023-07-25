`include "caminho_dados.v"

module caminho();

	integer i;
	integer EOF;
	integer code;
	integer arquivo;
	integer registrador;
	integer memoria;
	
	reg bite;
	reg [7:0] bits;
	reg [31:0] inst;
	reg [254:0] aux;
	
	reg clock;
	reg reset;
	reg [31:0] instrucao;
	reg [31:0][11:0] Memoria_entrada;
	reg [31:0][11:0]Registers_entrada;
	
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
	
	PC pc (	
		.reset(reset),
		.clock(clock),
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
		.ALUresult(ALUresult),
		.Memoria_entrada(Memoria_entrada),
		.WriteMem(WriteMem),
			
		.Memoria_saida(Memoria_saida),
		.Writedata(Writedata),
		.mem(mem)
		
	);	
	
	always @ (negedge clock) begin
		Registers_entrada = Registers_saida;
		Memoria_entrada = Memoria_saida;
		$display(" ----------------- Registers -----------------\n");
		for(i=0; i<32; i=i+1) begin
			$display("\tRegister [%d]: %d", i, Registers_entrada[i]);
		end
		$display("\n");
		$display(" ------------------ Memory -----------------\n");
		for(i=0; i<32; i=i+1) begin
			$display("\tMemoria [%d]: %d", i, Memoria_entrada[i]);
		end
		$display("\n");
	end
	always @ (linha) begin
		if(EOF == 1 && line == 0) begin
			$fclose(arquivo);
			arquivo = $fopen("binario.asm", "r");
			if( arquivo == 0 ) begin
				EOF = 0;
				$fclose(arquivo);
			end
			else begin
				EOF = 1;
			end
			repeat(linha-1) begin
				code = $fgets(aux, arquivo);
				code = $fgets(aux, arquivo);
			end
			if(!$feof(arquivo)) EOF = 1;
			else EOF = 0;
		end
		if(EOF == 1) begin
			inst = 32'dx;
			repeat (32)begin
				bits = $fgetc(arquivo);
				if(bits == 8'b00110000) bite = 0;
				else if (bits == 8'b00110001) bite = 1;
				inst = {inst, bite};
			end
			if(!$feof(arquivo))begin
				bits = $fgetc(arquivo);
				instrucao = inst;
				$display("Instrução %d", linha);
			end
			else  begin
				EOF = 0;
				$fclose(arquivo);
			end
		end
	end
	
	always @ (posedge reset) begin
		registrador = $fopen("registers.txt", "w");
		memoria = $fopen("memory.txt", "w");
		for (i = 0; i < 32; i = i + 1) begin
			Registers_entrada[i] = i;
			$fdisplay(registrador, "Register [ %d]: %d", i, Registers_entrada[i]);
			Memoria_entrada[i] = i;
			$fdisplay(memoria, "Memoria [%d]: %d", i, Memoria_entrada[i]);
		end
	end
	
	always @(negedge reset) begin
		arquivo = $fopen("binario.asm", "r");
		if( arquivo == 0 ) begin
			$display("Erro ao abrir arquivo");
			EOF = 0;
			$fclose(arquivo);
		end
		else begin
			$display("Arquivo aberto com sucesso");
			EOF = 1;
		end
	end
	
	initial begin
		#0 reset = 1;
		#2 reset = 0;
		#20 clock = 1'b0;
		while(EOF) begin
			#40 clock = ~clock;
		end
		#5 $finish;
	end
endmodule

