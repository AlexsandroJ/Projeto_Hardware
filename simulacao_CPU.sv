`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0] Ula_Out;
    logic [63:0] Pc_Out;
    logic [31:0] opcode;
    logic [2:0 ]STT;
 


    CPU teste_CPU(      .clock(         clock                   ),
                        .reset(         reset                   ),
                        .ULA_Out(       Ula_Out                 ),
                        .Pc_Out(        Pc_Out                  ),
                        .opcode(        opcode                  ),
                        .STT(           STT                     )
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
        $monitor($time," OpCode = %b Clock :%b Reset:%b PC = %d Estado: %d Ula = %d",opcode[6:0],clock, reset,Pc_Out,STT, Ula_Out);
    end
endmodule
