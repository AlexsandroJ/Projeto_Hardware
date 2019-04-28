`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0] Ula_Out;
    logic [63:0] Pc_Out;
    logic [31:0] opcode;
    logic [2:0 ]STT;
    logic [63:0] Registrador_A;
	logic [63:0] Registrador_B;
	logic [63:0] MUX_A_SAIDA;
	logic [63:0] MUX_B_SAIDA;
    logic [63:0] Mux64_Banco_Reg_Out;
    logic [63:0] Memoria64_Out;
 
    
    CPU teste_CPU(      .clock(         clock                   ),
                        .reset(         reset                   ),
                        .ULA_Out(       Ula_Out                 ),
                        .Pc_Out(        Pc_Out                  ),
                        .opcode(        opcode                  ),
                        .STT(           STT                     ),
                        .Registrador_A( Registrador_A           ),
                        .Registrador_B( Registrador_B           ),
                        .MUX_A_SAIDA(   MUX_A_SAIDA             ),
                        .MUX_B_SAIDA(   MUX_B_SAIDA             ),
                        .MUX_Banco_Reg_Out( Mux64_Banco_Reg_Out ),
                        .Memoria64_Out(         Memoria64_Out   )
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
            
            $monitor("OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d Mem64:%d MuxReg:%d",opcode[6:0],clock, reset,Pc_Out,STT, Registrador_A, Registrador_B, MUX_A_SAIDA, MUX_B_SAIDA , Ula_Out, Memoria64_Out, Mux64_Banco_Reg_Out);
            
        end
        else begin
            $stop;
        end
    end
endmodule