`timescale 1ps/1ps
module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0]Ula_Out;
    logic [31:0]mem;
 


    CPU teste_CPU(      .clock(     clock           ),
                        .reset(     reset           ),
                        .ULA_Out(   Ula_Out         ),
                        .merda(       mem            )
                                                    );
    localparam CLKPERIODO = 10000;
    localparam CLKDELAY = CLKPERIODO/2;
    initial begin
        clock = 1'b1;
        reset = 1'b1;
        #(CLKPERIODO)
        reset = 1'b0;
    end

    always #(CLKDELAY) clock = ~clock;

    always_ff@(posedge clock or posedge reset)begin
        $monitor($time," Instrucao = %d Clock :%b Reset:%b , PC = %d",Ula_Out,clock, reset,mem);
    end
endmodule
