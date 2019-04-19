
module CPU
(	input logic clock, reset,
	output logic [63:0] ULA_Out
);
//_________________________________Observa��es______________________________________________
// palavras iniciais das variaveis s�o o nome do bloco em que ela � usada separada por '_'  |
// em segida o nome especifico da entrada, o seu objetivo de uso                             |
// exemplo: "bancoRegisters_Instuction" -> Bloco:"bancoRegisters" Uso: "Instuction"          |
// se a primeira letra de Uso estiver em maiusculo, siginifica que � um arrey de linhas     |
// se a primeira letra de Uso estiver em minusculo, siginifica que � um bit                 |
//__________________________________________________________________________________________ |
// saidas e controle regiter PC
wire [31:0] PC_DadosOut;

// saidas e controle Memoria de instrucao
wire [31:0] Memory_Instruction_DataOut;

// saidas e controle registrador de instrucao
wire Register_Intruction_load_ir;
wire [4:0] Register_Intruction_Instr19_15;
wire [4:0] Register_Intruction_Instr24_20;
wire [4:0] Register_Intruction_Instr11_7;
wire [6:0] Register_Intruction_Instr6_0;
wire [31:0] Register_Intruction_Instr31_0;


// saidas e controle banco de Registradores
wire bancoRegisters_write;
wire [63:0] bancoRegisters_DataOut_1;
wire [63:0] bancoRegisters_DataOut_2;

// saidas e controle registrador A
wire [63:0] A_Out;

// saidas e controle registrador B
wire [63:0] B_Out;

// saidas e controle Mux A
wire [2:0] Mux64_Ula_A_Seletor;
wire [63:0] Mux64_Ula_A_Out;

// saidas e controle Mux B

wire [63:0] Mux64_Ula_B_Out;

// saidas e controle Da ULA
wire [63:0] A;
wire [63:0] B;
wire [63:0] S;
wire [3:0] Seletor;
wire overFlow;
wire negativo;
wire z;
wire igual;
wire maior;
wire menor;

// saidas da UC
wire UC_pcWrite;
wire [2:0] UC_SeletorUla;
wire [2:0] Ula_Mux64_A_Seletor;
wire [2:0] Ula_Mux64_B_Seletor;


// entradas e saidas Memoria de Dados
wire [63:0] DataMemory_Raddress;
wire [63:0] DataMemory_Waddress;
wire [63:0] DataMemory_DataIn;
wire [63:0] DataMemory_DataOut;
wire DataMemory_wr;


// saidas e controle regiter De dados da memoria
wire Register_Memory_regwrite;
wire [63:0] Register_Memory_DadosIn;
wire [63:0] Register_Memory_DadosOut;


wire load_ir;

wire [63:0]mux64_A_C;
wire [63:0]mux64_A_D;

wire [63:0]mux64_B_C;
wire [63:0]mux64_B_D;

reg [63:0] Saida_da_Ula;
	
	UC UC_(								.clock(						clock							),
										.Op(						Register_Intruction_Instr6_0	),
										.reset(						reset							),
										.pc_regWrite(				UC_pcWrite						),
										.Ula_Seletor(				UC_SeletorUla					),
										.mux_A_seletor(				Ula_Mux64_A_Seletor				),
    									.mux_B_seletor(				Ula_Mux64_B_Seletor				)
																									);


	register PC( 						.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					UC_pcWrite						), 
										.DadoIn(					S								), 
										.DadoOut(					PC_DadosOut						)
																									);

	Memoria32 Register_Memory( 			
										.raddress(					PC_DadosOut						), 
										.waddress(													), 
										.Clk(						clock							), 
										.Datain(													), 
										.Dataout(					Memory_Instruction_DataOut		), 
										.Wr(						0								)
																									);															
																					
Instr_Reg_RISC_V Register_Intruction(	.Clk(						clock							), 
										.Reset(						reset							), 
										.Load_ir(					load_ir								), 
										.Entrada(					Memory_Instruction_DataOut		), 
										.Instr19_15(				Register_Intruction_Instr19_15  ), 
										.Instr24_20(				Register_Intruction_Instr24_20	),
										.Instr11_7(					Register_Intruction_Instr11_7	), 
										.Instr6_0(					Register_Intruction_Instr6_0	), 
										.Instr31_0(					Register_Intruction_Instr31_0	)
																									);

								
	bancoReg bancoRegisters( 			.write(						bancoRegisters_write			),
										.clock(						clock							),
										.reset(						reset							),
										.regreader1(				Register_Intruction_Instr19_15	),
									  	.regreader2(				Register_Intruction_Instr24_20	),
									   	.regwriteaddress(			Register_Intruction_Instr11_7	),
									  	.dataout1(					bancoRegisters_DataOut_1		),
									   	.dataout2(					bancoRegisters_DataOut_2		)			
									   																);
	
	register Reg_A( 					.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					clock							), 
										.DadoIn(					bancoRegisters_DataOut_1		), 
										.DadoOut(					A_Out							)
																									);


	register Reg_B( 					.clk(						clock							), 
										.reset(						reset							), 
										.regWrite(					clock							), 
										.DadoIn(					bancoRegisters_DataOut_2		), 
										.DadoOut(					B_Out							)
																									);
									
									
	mux64_PC Mux64_Ula_A(				.Seletor(					Ula_Mux64_A_Seletor				),
										.A(							PC_DadosOut						),
										.B(							A_Out							),
										.C(															),
										.D(							64'd10								),
										.Saida(						Mux64_Ula_A_Out					)
																									);											  
	
	
	mux64 Mux64_Ula_B(					.Seletor(					Ula_Mux64_B_Seletor				),
										.A(							B_Out							),
										.B(							64'd4							),
										.C(															),
										.D(							64'd10							),
										.Saida(						Mux64_Ula_B_Out					)
																									);	
	



	ula64 ULA( 							.A(							Mux64_Ula_A_Out					),
										.B( 						Mux64_Ula_B_Out					), 
										.Seletor(					UC_SeletorUla					), 
										.S(							S								), 
										.overFlow(					overFlow					), 
										.negativo(					negativo					), 
										.z(							z							), 
										.igual(						igual						), 
										.maior(						maior						), 
										.menor(						menor						)
																									);

	
	always_ff @(posedge clock or posedge reset) // sincrono
    begin
       Saida_da_Ula = S;
	   ULA_Out = Saida_da_Ula;
	   
    end


endmodule

