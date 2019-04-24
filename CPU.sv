
module CPU
(	input logic clock, reset,
	output logic [63:0] ULA_Out,
	output logic [31:0] merda,
	output logic [2:0]STT

);
//_________________________________Observacoes______________________________________________
// palavras iniciais das variaveis sao o nome do bloco em que ela e usada separada por '_'  |
// em segida o nome especifico da entrada, o seu objetivo de uso                             |
// exemplo: "bancoRegisters_Instuction" -> Bloco:"bancoRegisters" Uso: "Instuction"          |
// se a primeira letra de Uso estiver em maiusculo, siginifica que e um arrey de linhas     |
// se a primeira letra de Uso estiver em minusculo, siginifica que e um bit                 |
//__________________________________________________________________________________________ |

// saidas e controle regiter PC
wire PC_Write;
wire [63:0] PC_DadosOut;

// saidas e controle Memoria de instrucao
wire Memory_Instruction_write;
wire [31:0] Memory_Instruction_DataOut;

// Saidas e controle Memoria de dados
wire Data_Memory_write;
wire [63:0] Data_Memory_Out;

// saidas registrador de dados da memoria
wire [63:0]Reg_Memory_Data_Out;

// Saida corte_antes
wire [63:0]DadoIn_64;

// Saida corte depois
wire [63:0]Saida_Memory_Data;


// saida mux do banco de registrador 
wire [2:0]	Mux64_Banco_Reg_Seletor;
wire [63:0]	Mux64_Banco_Reg_Out;

// saidas e controle registrador de instrucao
wire Register_Intruction_load_ir;
wire [4:0] Register_Intruction_Instr19_15;
wire [4:0] Register_Intruction_Instr24_20;
wire [4:0] Register_Intruction_Instr11_7;
wire [6:0] Register_Intruction_Instr6_0;
wire [31:0] Register_Intruction_Instr31_0;

// Saida Extensor de Sinal
wire [63:0] Sinal_Extend_Out;

// saida Modulo de deslocamento
wire [63:0]Shift_Left_Out;

// saidas e controle banco de Registradores
wire bancoRegisters_write;
wire [63:0] bancoRegisters_DataOut_1;
wire [63:0] bancoRegisters_DataOut_2;

// saidas e controle registrador A
wire [63:0] Reg_A_Out;
wire reset_A;
wire Reg_A_Write;

// saidas e controle registrador B
wire [63:0] Reg_B_Out;
wire Reg_B_Write;


// saidas e controle Deslocamento Funcional
wire [1:0]Shift_Control;
wire [63:0]Shift_Funcional_Out;

// saidas e controle Mux A
wire [2:0] Mux64_Ula_A_Seletor;
wire [63:0] Mux64_Ula_A_Out;

// saidas e controle Mux B
wire [2:0] Mux64_Ula_B_Seletor;
wire [63:0] Mux64_Ula_B_Out;

// saidas e controle Da ULA
wire [63:0] A;
wire [63:0] B;
wire [63:0] S;
wire [2:0] Seletor;
wire overFlow;
wire negativo;
wire z;
wire igual;
wire maior;
wire menor;

// saidas registrador da saida da ula
wire [63:0]Reg_ULAOut_Out;

// Outros Fios usados
wire load_ir;

wire [63:0]mux64_A_C;
wire [63:0]mux64_A_D;

wire [63:0]mux64_B_C;
wire [63:0]mux64_B_D;

reg [63:0] Saida_da_Ula;

// Debugar codigo
wire [2:0]Situacao;

//_________________________________saidas da Unidade de Controle______________________________________
//					PC_Write							: grava em PC
//					Seletor_Ula 						: 3 Bits seleciona a operacao na ula
//					Mux64_Ula_A_Seletor					: 3 Bits
//					Mux64_Ula_B_Seletor					: 3 Bits
//					load_ir								: escrita no registrador de instrucao
//					Data_Memory_write					: leitura ou Escrita na Memoria
//					bancoRegisters_write				: escrita em regwriteaddress
//					Mux64_Banco_Reg_Seletor				: 3 Bits
//					reset_A								: zera registrador A
//_____________________________________________________________________________________________________


//_________________________________________Unidade de Controle_________________________________________
	UC UC_(								.clock(						clock							),
										.Register_Intruction_Instr31_0(	Register_Intruction_Instr31_0),
										.reset(						reset							),
										.PC_Write(					PC_Write						),
										.Seletor_Ula(				Seletor							),
										.mux_A_seletor(				Mux64_Ula_A_Seletor				),
    									.mux_B_seletor(				Mux64_Ula_B_Seletor				),
										.Data_Memory_wr(			Data_Memory_write				),
										.bancoRegisters_wr(			bancoRegisters_write			),
										.Mux_Banco_Reg_Seletor(		Mux64_Banco_Reg_Seletor			),
										.z(		                    z                				),
										.igual(		                igual                			),
										.maior(		                maior                			),
										.menor(		                menor                			),
										.reset_A( 					reset_A							),
										.Shift_Control(				Shift_Control					),
										.Reg_A_Write( 				Reg_A_Write						),
										.Reg_B_Write( 				Reg_B_Write						),
										.Situacao(					Situacao						)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Registrador PC [In 64 Bits ] [Out 32 Bits ]_________________
	register PC( 						.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					PC_Write						), 
										.DadoIn(					S								), 
										.DadoOut(					PC_DadosOut						)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Memoria De Instrucao 32 Bits________________________________
	Memoria32 Memory_Instruction( 			
										.raddress(					PC_DadosOut[31:0]				), 
										.waddress(					32'd0			     			), 
										.Clk(						clock							), 
										.Datain(					32'd0				     		), 
										.Dataout(					Memory_Instruction_DataOut		), 
										.Wr(						1'b0								)
																									);															
//_____________________________________________________________________________________________________
//_________________________________________Diminuição do rd antes______________________________________
	Battousai_Store corte_antes( 		
										.Reg_B_Out(					Reg_B_Out						), //INPUT
										.Register_Intruction_Instr31_0(Register_Intruction_Instr31_0), 
										.DadoIn_64(					DadoIn_64						)
																									);	
//_____________________________________________________________________________________________________
//_________________________________________Memoria de Dados 64 Bits____________________________________
	Memoria64 Data_Memory( 			
										.raddress(					Reg_ULAOut_Out					), 
										.waddress(													), 
										.Clk(						clock							), 
										.Datain(					DadoIn_64						), 
										.Dataout(					Data_Memory_Out					), 
										.Wr(						Data_Memory_write				)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Diminuição do rd depois_____________________________________
	Battousai_Load corte_depois( 		
										.Dataout(					Data_Memory_Out					), //INPUT
										.Register_Intruction_Instr31_0(Register_Intruction_Instr31_0), 
										.Saida_Memory_Data(			Saida_Memory_Data				)
																									);	
//_____________________________________________________________________________________________________
//_________________________________________Registrador de Memoria de Dados 64 Bits_____________________
	register Reg_Memory_Data( 			.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					clock							), 
										.DadoIn(					Saida_Memory_Data				), 
										.DadoOut(					Reg_Memory_Data_Out				)
																									);	
//_____________________________________________________________________________________________________
//_________________________________________Mux 64 Bits da Entrada do banco de registradores____________
	mux64 Mux64_Banco_Reg(				.Seletor(					Mux64_Banco_Reg_Seletor			),
										.A(							Reg_ULAOut_Out					),
										.B(							Reg_Memory_Data_Out				),
										.C(															),
										.D(															),
										.Saida(						Mux64_Ula_B_Out					)
																									);																								
//_____________________________________________________________________________________________________
//_________________________________________Registrador de Instruções 32 Bits___________________________
Instr_Reg_RISC_V Register_Intruction(	.Clk(						clock							), 
										.Reset(						reset							), 
										.Load_ir(					load_ir							), 
										.Entrada(					Memory_Instruction_DataOut		), 
										.Instr19_15(				Register_Intruction_Instr19_15  ), 
										.Instr24_20(				Register_Intruction_Instr24_20	),
										.Instr11_7(					Register_Intruction_Instr11_7	), 
										.Instr6_0(					Register_Intruction_Instr6_0	), 
										.Instr31_0(					Register_Intruction_Instr31_0	)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Extensao de sinal___________________________________________
	Sinal_Extend Sinal_Extend_(			.Sinal_In(					Register_Intruction_Instr31_0	),
										.Sinal_Out(					Sinal_Extend_Out				)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Delocamento de 1 Bit________________________________________
	Deslocamento Shift_Left(			.Shift(						2'd1							),
										.Entrada(					Sinal_Extend_Out				),
										.N(							6'd0							),
										.Saida(						Shift_Left_Out					)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Banco de registradores 64 Bits______________________________								
	bancoReg bancoRegisters( 			.write(						bancoRegisters_write			),
										.clock(						clock							),
										.reset(						reset							),
										.regreader1(				Register_Intruction_Instr19_15	),
									  	.regreader2(				Register_Intruction_Instr24_20	),
									   	.regwriteaddress(			Register_Intruction_Instr11_7	),
									  	.dataout1(					bancoRegisters_DataOut_1		),
									   	.dataout2(					bancoRegisters_DataOut_2		)			
									   																);
//_____________________________________________________________________________________________________
//_________________________________________Delocamento de N Bits_______________________________________
	Deslocamento deslocador_funcional(	.Shift(						Shift_Control							),
										.Entrada(					bancoRegisters_DataOut_1				),
										.N(							Register_Intruction_Instr31_0[25:20]	),
										.Saida(						Shift_Funcional_Out						)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Registrador A 64 Bits_______________________________________
	register Reg_A( 					.clk(						clock							), 
										.reset(						reset_A							), 
										.regWrite(					Reg_A_Write						), 
										.DadoIn(					Shift_Funcional_Out				), 
										.DadoOut(					Reg_A_Out						)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Registrador B 64 Bits_______________________________________
	register Reg_B( 					.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					Reg_B_Write						), 
										.DadoIn(					bancoRegisters_DataOut_2		), 
										.DadoOut(					Reg_B_Out						)
																									);
//_____________________________________________________________________________________________________									
//_________________________________________Mux Entrada A da Ula A 64 Bits _____________________________								
	mux64 Mux64_Ula_A(					.Seletor(					Mux64_Ula_A_Seletor				),
										.A(							PC_DadosOut						),
										.B(							Reg_A_Out						),
										.C(							64'd666							),
										.D(							64'd666							),
										.Saida(						Mux64_Ula_A_Out					)
																									);											  
//_____________________________________________________________________________________________________	
//_________________________________________Mux Entrada B da Ula A 64 Bits _____________________________
	mux64 Mux64_Ula_B(					.Seletor(					Mux64_Ula_B_Seletor				),
										.A(							Reg_B_Out						),
										.B(							64'd4							),
										.C(							Sinal_Extend_Out							),
										.D(							Shift_Left_Out							),
										.Saida(						Mux64_Ula_B_Out					)
																									);	
//_____________________________________________________________________________________________________	
//_________________________________________Ula_________________________________________________________	
	ula64 ULA( 							.A(							Mux64_Ula_A_Out					),
										.B( 						Mux64_Ula_B_Out					), 
										.Seletor(					Seletor							), 
										.S(							S								), 
										.overFlow(					overFlow						), 
										.negativo(					negativo						), 
										.z(							z								), 
										.igual(						igual							), 
										.maior(						maior							), 
										.menor(						menor							)
																									);
//_____________________________________________________________________________________________________
//_________________________________________Registrador Saida da Ula____________________________________
	register Reg_ULAOut( 				.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					1								), 
										.DadoIn(					S								), 
										.DadoOut(					ULA_Out							)
																									);
//_____________________________________________________________________________________________________

	always_ff @(posedge clock or posedge reset) // sincrono
    begin
	
	  	ULA_Out <= Memory_Instruction_DataOut;
	   	merda <= PC_DadosOut;
	   	STT = Situacao;
    end

endmodule

