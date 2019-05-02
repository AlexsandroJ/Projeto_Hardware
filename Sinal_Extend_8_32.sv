module  Sinal_Extend_8_32(
    input logic causa,
    input logic [31:0] Entrada_8_bits,
    output logic [63:0] Saida_32
);

always_comb begin
    if( causa )begin

        Saida_32 = {56'd0, Entrada_8_bits[31:24]};

    end
    else begin

        Saida_32 = {56'd0, Entrada_8_bits[23:16]};

    end
end
endmodule
