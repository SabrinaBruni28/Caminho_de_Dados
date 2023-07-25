module PC (	
		input reset,
		input clock,
		input line,
		input [11:0] sum,
		input [31:0] instrucao,
		
		output reg [11:0] linha,
		output reg [4:0] rd,
		output reg [4:0] rs1,
		output reg [4:0] rs2,
		output reg [6:0] opcode
	);
	
	always @ (posedge reset) begin
		linha = 0;
	end

	always @ (negedge clock) begin
		if(line == 0) begin
			linha = sum;
		end
		else begin
			linha = linha + 1;
		end
	end
	
	always @ (instrucao)  begin
		opcode = instrucao[6:0];
		rd = instrucao[11:7];
		rs1 = instrucao[19:15];
		rs2 = instrucao[24:20];
	end
	
endmodule

module Control (
		input [31:0] instrucao,
		input [6:0] opcode,
		input clock,
		
		output reg Branch,
		output reg MemRead,
		output reg MemtoReg,
		output reg [1:0] ALUOp,
		output reg MemWrite,
		output reg ALUScr,
		output reg RegWrite,
		output reg [3:0] ALUcontrol,
		output reg signed [11:0] ImmGen,
		output reg control
	);
	
	reg [9:0] opcodefield;
	reg [2:0] funtc3;
	always @ (posedge clock) begin
	control = 0;
		// Load
		if(opcode == 7'b0000011) begin
			ALUOp = 2'b00;
			ALUcontrol = 4'b0010;
			ALUScr = 1;
			Branch = 0;
			MemRead = 1;
			MemtoReg = 1;
			MemWrite = 0;
			RegWrite = 1;
			ImmGen = instrucao[31:20];
		end
		// Store
		else if(opcode == 7'b0100011) begin
			ALUOp = 2'b00;
			ALUcontrol = 4'b0010;
			ALUScr = 1;
			Branch = 0;
			MemRead = 1;
			MemtoReg = 0;
			MemWrite = 1;
			RegWrite = 0;
			ImmGen = {instrucao[31:25], instrucao[11:7]};
		end
		// Beq
		else if(opcode == 7'b1100011) begin
			ALUOp = 2'b01;
			ALUcontrol = 4'b0110;
			ALUScr = 1;
			Branch = 1;
			MemRead = 0;
			MemtoReg = 0;
			MemWrite = 0;
			RegWrite = 0;
			ImmGen = {	instrucao[31], 
					instrucao[7], 
					instrucao[30:25], 
					instrucao[11:8]
				};
			ImmGen = ImmGen<<<1;
		end
		// Tipo R
		else if(opcode == 7'b0110011) begin
			opcodefield = 10'dx;
			opcodefield = {instrucao[31:25],instrucao[14:12]};
			ALUOp = 2'b10;
			ALUScr = 0;
			Branch = 0;
			MemRead = 0;
			MemtoReg = 0;
			MemWrite = 0;
			RegWrite = 1;
			ImmGen = 0;
			// soma
			if(opcodefield == 10'b0000000000)begin
				ALUcontrol = 4'b0010;
			end
			// subtracao
			else if(opcodefield == 10'b0100000000)begin
				ALUcontrol = 4'b0110;
			end
			// AND
			else if(opcodefield == 10'b0000000111)begin
				ALUcontrol = 4'b0000;
			end
			// OR
			else if(opcodefield == 10'b0000000110)begin
				ALUcontrol = 4'b0001;
			end
			// shift
			else if(opcodefield == 10'b0000000101)begin
				ALUcontrol = 4'b1000;
			end
		end
		// Tipo I
		else if(opcode == 7'b0010011) begin
			funtc3 = instrucao[14:12];
			ALUOp = 2'b10;
			ALUScr = 1;
			Branch = 0;
			MemRead = 0;
			MemtoReg = 0;
			MemWrite = 0;
			RegWrite = 1;
			ImmGen = instrucao[31:20];
			// AND
			if(funtc3 == 3'b111)begin
				ALUcontrol = 4'b0000;
			end
			// OR
			else if(funtc3 == 3'b110)begin
				ALUcontrol = 4'b0001;
			end
		end
	control = 1;
	end
	
endmodule

module Registradores(	
			input [4:0] rd,
			input [4:0] rs1,
			input [4:0] rs2,
			input RegWrite,
			input MemWrite,
			input MemRead,
			input Branch,
			input [11:0] Writedata,
			input ALUScr,
			input [11:0] ImmGen,
			input [11:0] ALUresult,
			input control,
			input mem,
			input wire [31:0][11:0]Registers_entrada,
			
			output reg [31:0][11:0] Registers_saida,
			output reg [11:0] data1,
			output reg [11:0] data2, 
			output reg REG,
			output reg [11:0] WriteMem
		);
	
	always @ (Registers_entrada) begin
		Registers_saida = Registers_entrada;
	end
	
	always @ (posedge mem) begin
		if(RegWrite==1) begin
			if(MemRead == 1) begin
				Registers_saida[rd] = Writedata;
			end
			else begin
				Registers_saida[rd] = ALUresult;
			end
		end
	end
	
	always @ (posedge control) begin
		REG = 0;
		data1 = Registers_entrada[rs1];
		if(ALUScr == 1) begin
			if(MemRead == 1) data2 = ImmGen/4;
			else if(Branch == 1) data2 = Registers_entrada[rs2];
			else data2 = ImmGen;
		end
		else begin
			data2 = Registers_entrada[rs2];
		end
		
		if(MemWrite == 1) begin
			WriteMem = Registers_entrada[rs2];
		end
		REG = 1;
	end
endmodule

module ALU (	
		input [11:0] data1,
		input [11:0] data2,
		input [3:0] ALUcontrol,
		input [11:0] ImmGen,
		input REG,
		input Branch,
		input [11:0] linha,
		
		output reg [11:0] ALUresult,
		output reg [11:0] sum,
		output reg line,
		output reg alu	
	);
	
	always @ (posedge REG) begin
		alu = 0;
		//and
		if(ALUcontrol == 4'b0000) begin
			ALUresult = data1 & data2;
		end
		//or
		else if(ALUcontrol == 4'b0001) begin
			ALUresult = data1 | data2;
		end
		// soma
		else if(ALUcontrol == 4'b0010) begin
			ALUresult = data1 + data2;
		end
		//subtração
		else if(ALUcontrol == 4'b0110) begin
			 ALUresult = data1 - data2;
		end
		// shift
		else if(ALUcontrol == 4'b1000) begin
			ALUresult = data1 >> data2;
		end
		alu = 1;
	end
	always @ (posedge alu) begin
		sum = linha + ImmGen;
		line = 1;
		if(Branch == 1 && ALUresult == 0) begin
			line = 0;
		end
	end
	
endmodule


module Memory(	
		input MemWrite,
		input MemRead,
		input MemtoReg,
		input alu,
		input [11:0] ALUresult,
		input [31:0][11:0] Memoria_entrada,
		input [11:0] WriteMem,
			
		output reg [31:0][11:0] Memoria_saida,
		output reg [11:0] Writedata,
		output reg mem
	);
	
	reg [11:0]novo_result;
	
	always @ (Memoria_entrada) begin
		Memoria_saida = Memoria_entrada;
	end
	
	always @ (posedge alu)  begin
		mem = 0;
		if(MemWrite == 1) begin
			novo_result = ALUresult;
			while(novo_result > 31) begin
				novo_result = novo_result - 32;
			end
			Memoria_saida[novo_result] = WriteMem;
		end
		if(MemtoReg == 1 && MemRead == 1) begin
			Writedata = Memoria_entrada[ALUresult];
 		end
 		mem = 1;
			
	end
endmodule
	
	
	
	
	
