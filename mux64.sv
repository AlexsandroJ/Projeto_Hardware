module mux64
(   input logic [2:0] Seletor, [63:0] A, [63:0] B, [63:0] C, [63:0] D,

    output logic [63:0] Saida);

    always_comb begin
    case(Seletor)
        3'd00: Saida = A;
        3'd01: Saida = B;
        3'd02: Saida = C;
        3'd03: Saida = D;
    endcase
    end
endmodule
