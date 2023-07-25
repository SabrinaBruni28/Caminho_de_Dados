module SevenSegmentConverter(
			  input [11:0] number,
			  output reg [6:0] segments1,
			  output reg [6:0] segments2
);

	always@(*) begin
		if(number>0 && number<10) begin
		    case(number/10)
			0: segments1 = 7'b1000000; // 0
			1: segments1 = 7'b1111001; // 1
			2: segments1 = 7'b0100100; // 2
			3: segments1 = 7'b0110000; // 3
			4: segments1 = 7'b0011001; // 4
			5: segments1 = 7'b0010010; // 5
			6: segments1 = 7'b0000010; // 6
			7: segments1 = 7'b1111000; // 7
			8: segments1 = 7'b0000000; // 8
			9: segments1 = 7'b0010000; // 9
			default:  segments1 = 7'b1111111; // Número inválido
		    endcase
		    case(number%10)
			0: segments2 = 7'b1000000; // 0
			1: segments2 = 7'b1111001; // 1
			2: segments2 = 7'b0100100; // 2
			3: segments2 = 7'b0110000; // 3
			4: segments2 = 7'b0011001; // 4
			5: segments2 = 7'b0010010; // 5
			6: segments2 = 7'b0000010; // 6
			7: segments2 = 7'b1111000; // 7
			8: segments2 = 7'b0000000; // 8
			9: segments2 = 7'b0010000; // 9
			default:  segments2 = 7'b1111111; // Número inválido
		    endcase
$display("\n\t---- Instrução: %0d ----", number);
$display("----------------------------------------------------------------------------------");
$display("|   %b   |   %b   |", segments1[0], segments2[0]);
$display("| %b   %b | %b   %b |", segments1[5], segments1[1], segments2[5], segments2[1]);
$display("|   %b   |   %b   |", segments1[6], segments2[6]);
$display("| %b   %b | %b   %b |", segments1[4], segments1[2], segments2[4], segments2[2]);
$display("|   %b   |   %b   |", segments1[3], segments2[3]);
$display("----------------------------------------------------------------------------------");
		end
		
		else begin
			segments1 = 7'b1111111;
			segments2 = 7'b1111111;
		end
	end

endmodule



module SevenSegmentConverter2(
			  input r,
			  input m,
			  input [31:0][11:0] number1,
			  input [31:0][11:0] number2,
			  output reg [6:0] segments1,
			  output reg [6:0] segments2,
			  output reg [6:0] display1,
			  output reg [6:0] display2,
			  output reg [6:0] display3,
			  output reg [6:0] display4,
			  output reg [1:0] led
);
	integer i;
	reg [31:0][11:0] valor;
	
	always@(posedge r, posedge m) begin
		if(i<31) i <= i+1;
		else i <=0;
		if(r==1) begin
			valor <= number1;
			led <= 2'b01;
			
		end
		else if(m == 1) begin
			valor <= number2;
			led <= 2'b10;
		end
		    case(i/10)
			0: segments1 = 7'b1000000; // 0
			1: segments1 = 7'b1111001; // 1
			2: segments1 = 7'b0100100; // 2
			3: segments1 = 7'b0110000; // 3
			4: segments1 = 7'b0011001; // 4
			5: segments1 = 7'b0010010; // 5
			6: segments1 = 7'b0000010; // 6
			7: segments1 = 7'b1111000; // 7
			8: segments1 = 7'b0000000; // 8
			9: segments1 = 7'b0010000; // 9
			default:  segments1 = 7'b1111111; // Número inválido
		    endcase
		    case(i%10)
			0: segments2 = 7'b1000000; // 0
			1: segments2 = 7'b1111001; // 1
			2: segments2 = 7'b0100100; // 2
			3: segments2 = 7'b0110000; // 3
			4: segments2 = 7'b0011001; // 4
			5: segments2 = 7'b0010010; // 5
			6: segments2 = 7'b0000010; // 6
			7: segments2 = 7'b1111000; // 7
			8: segments2 = 7'b0000000; // 8
			9: segments2 = 7'b0010000; // 9
			default:  segments2 = 7'b1111111; // Número inválido
		    endcase
		    
		    case(valor[i]/1000)
			0: display1 = 7'b1000000; // 0
			1: display1 = 7'b1111001; // 1
			2: display1 = 7'b0100100; // 2
			3: display1 = 7'b0110000; // 3
			4: display1 = 7'b0011001; // 4
			5: display1 = 7'b0010010; // 5
			6: display1 = 7'b0000010; // 6
			7: display1 = 7'b1111000; // 7
			8: display1 = 7'b0000000; // 8
			9: display1 = 7'b0010000; // 9
			default:  display1 = 7'b1111111; // Número inválido
		    endcase
		   
		    case(valor[i]%1000/100)
			0: display2 = 7'b1000000; // 0
			1: display2 = 7'b1111001; // 1
			2: display2 = 7'b0100100; // 2
			3: display2 = 7'b0110000; // 3
			4: display2 = 7'b0011001; // 4
			5: display2 = 7'b0010010; // 5
			6: display2 = 7'b0000010; // 6
			7: display2 = 7'b1111000; // 7
			8: display2 = 7'b0000000; // 8
			9: display2 = 7'b0010000; // 9
			default:  display2 = 7'b1111111; // Número inválido
		    endcase
		   
		    case(valor[i]%1000%100/10)
			0: display3 = 7'b1000000; // 0
			1: display3 = 7'b1111001; // 1
			2: display3 = 7'b0100100; // 2
			3: display3 = 7'b0110000; // 3
			4: display3 = 7'b0011001; // 4
			5: display3 = 7'b0010010; // 5
			6: display3 = 7'b0000010; // 6
			7: display3 = 7'b1111000; // 7
			8: display3 = 7'b0000000; // 8
			9: display3 = 7'b0010000; // 9
			default:  display3 = 7'b1111111; // Número inválido
		    endcase
		    
		    case(valor[i]%1000%100%10)
			0: display4 = 7'b1000000; // 0
			1: display4 = 7'b1111001; // 1
			2: display4 = 7'b0100100; // 2
			3: display4 = 7'b0110000; // 3
			4: display4 = 7'b0011001; // 4
			5: display4 = 7'b0010010; // 5
			6: display4 = 7'b0000010; // 6
			7: display4 = 7'b1111000; // 7
			8: display4 = 7'b0000000; // 8
			9: display4 = 7'b0010000; // 9
			default:  display4 = 7'b1111111; // Número inválido
		    endcase
$display("LED %d", led);
$display("| %0d | %0d |             | %0d | %0d | %0d | %0d |", i/10, i%10, valor[i]/1000, valor[i]%1000/100, valor[i]%1000%100/10, valor[i]%1000%100%10);
$display("----------------------------------------------------------------------------------");
$display("|   %b   |   %b   |     |   %b   |   %b   | |   %b   |   %b   |", segments1[0], segments2[0], display1[0], display2[0], display3[0], display4[0]);
$display("| %b   %b | %b   %b |     | %b   %b | %b   %b | | %b   %b | %b   %b |", segments1[5], segments1[1], segments2[5], segments2[1], display1[5], display1[1], display2[5], display2[1], display3[5], display3[1], display4[5], display4[1]);
$display("|   %b   |   %b   |     |   %b   |   %b   | |   %b   |   %b   |", segments1[6], segments2[6], display1[6], display2[6], display3[6], display4[6]);
$display("| %b   %b | %b   %b |     | %b   %b | %b   %b | | %b   %b | %b   %b |", segments1[4], segments1[2], segments2[4], segments2[2], display1[4], display1[2], display2[4], display2[2], display3[4], display3[2], display4[4], display4[2]);
$display("|   %b   |   %b   |     |   %b   |   %b   | |   %b   |   %b   |", segments1[3], segments2[3], display1[3], display2[3], display3[3], display4[3]);
$display("----------------------------------------------------------------------------------");

	end

endmodule
