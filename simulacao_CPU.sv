`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0] Ula_Out;
    logic [63:0] Pc_Out;
    logic [31:0] opcode;
    logic [4:0]Estado;
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
    logic overFlow_Ula;
    logic [63:0] Reg_EPC;
    logic [63:0] Reg_Caua;
    logic [63:0] Reg_ULAOut;
    logic memoria_wr;
    logic [63:0]Reg_Memory_Data;
    logic reg_wr;
    logic Ld_ir;

    
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
                        .maior_Ula(     maior_Ula               ),
                        .overFlow_Ula(  overFlow_Ula            ),
                        .Reg_EPC(       Reg_EPC                 ),
                        .Reg_Caua(      Reg_Caua                ),
                        .Reg_ULAOut_(    Reg_ULAOut              ),
                        .memoria_wr(    memoria_wr              ),
                        .Reg_Memory_Data_(   Reg_Memory_Data     ),
                        .reg_wr(            reg_wr              ),
                        .Ld_ir(             Ld_ir               )
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
        
        if($time < 3000000 ) begin
            
            //$monitor("Mem_Inst:%d OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d igual:%d Menor:%d Maior:%d OvFlo:%d Mem64:%d MuxReg:%d EPC:%d Causa:%d",Instruction[6:0],opcode[6:0],clock, reset,Pc_Out[31:0],Estado, Registrador_A[31:0], Registrador_B[31:0], MUX_A_SAIDA[31:0], MUX_B_SAIDA[31:0], Ula_Out[63:0],igual_Ula,menor_Ula,maior_Ula,overFlow_Ula, Memoria64_Out, Mux64_Banco_Reg_Out[31:0],Reg_EPC[31:0],Reg_Caua[2:0]);
            $monitor("RD:%d OpCode:%d Clock:%b Reset:%b PC:%d Estado:%d A:%d B:%d MuxA:%d MuxB:%d Ula:%d Mem64:%d MuxReg:%d EPC:%d Causa:%d wr:%d WriteDataReg:%d IRWrite:%d ",Instruction[11:7],opcode[6:0],clock, reset,Pc_Out[31:0],Estado, Registrador_A[31:0], Registrador_B[31:0], MUX_A_SAIDA[31:0], MUX_B_SAIDA[31:0], Ula_Out[63:0], Memoria64_Out, Mux64_Banco_Reg_Out[31:0],Reg_EPC[31:0],Reg_Caua[10:0],memoria_wr,reg_wr,Ld_ir);
           
            //$monitor("MenData:%d Address:%d L/S:%d WriteDataReg:%d MDR:%d Alu:%d AluOut:%d PC:%d wr:%d RegWrite:%d IRWrite:%d EPC:%d Estado:%d",Memoria64_Out,Ula_Out,memoria_wr,Mux64_Banco_Reg_Out,Reg_Memory_Data, Ula_Out,Reg_ULAOut, Pc_Out,memoria_wr,reg_wr,Ld_ir,Reg_EPC,Estado);
            
        end
        else begin
            $stop;
        end
    end
endmodule