`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0] Ula_Out;
    logic [63:0] Pc_Out;
    logic [31:0] opcode;
    logic [4:0 ]Estado;
    logic [63:0] Registrador_A;
	logic [63:0] Registrador_B;
	logic [63:0] MUX_A_SAIDA;
	logic [63:0] MUX_B_SAIDA;
    logic [63:0] Mux64_Banco_Reg_Out;
    logic [63:0] Memoria64_Out;
    logic igual_Ula;
	logic menor_Ula;
    logic maior_Ula;
    logic [63:0] Instruction;
 
    
    CPU teste_CPU(      .clock(         clock                   ),
                        .reset(         reset                   ),
                        .ULA_Out(       Ula_Out                 ),
                        .Pc_Out(        Pc_Out                  ),
                        .opcode(        opcode                  ),
                        .Instruction(   Instruction             ),
                        .Estado(        Estado                  ),
                        .Registrador_A( Registrador_A           ),
                        .Registrador_B( Registrador_B           ),
                        .MUX_A_SAIDA(   MUX_A_SAIDA             ),
                        .MUX_B_SAIDA(   MUX_B_SAIDA             ),
                        .MUX_Banco_Reg_Out( Mux64_Banco_Reg_Out ),
                        .Memoria64_Out( Memoria64_Out           ),
                        .igual_Ula(     igual_Ula               ),
                        .menor_Ula(     menor_Ula               ),
                        .maior_Ula(     maior_Ula               )
                                                                );
    localparam CLKPERIODO = 10000;
    localparam CLKDELAY = CLKPERIODO/2;
    initial begin
        clock = 1'b0;
        reset = 1'b1;
        #(CLKPERIODO)
        #(CLKPERIODO)
        #(CLKPERIODO)
        reset = 1'b0;
    end

    always #(CLKDELAY) clock = ~clock;

    always_ff@(posedge clock or posedge reset)begin
        
        if($time < 300000 ) begin
            
            $monitor("Mem_Inst:%d OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d igual:%d Menor:%d Maior:%d Mem64:%d MuxReg:%d",Instruction[6:0],opcode[6:0],clock, reset,Pc_Out[31:0],Estado, Registrador_A[31:0], Registrador_B[31:0], MUX_A_SAIDA[31:0], MUX_B_SAIDA[31:0], Ula_Out[31:0],igual_Ula,menor_Ula,maior_Ula, Memoria64_Out, Mux64_Banco_Reg_Out[31:0]);
            
        end
        else begin
            $stop;
        end
    end
endmodule