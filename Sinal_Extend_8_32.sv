module  Sinal_Extend_8_32(
    input logic [7:0] Entrada_8_bits,
    output logic [63:0] Saida_32
);

always_comb begin
    
    Saida_32 = {56'd0, Entrada_8_bits};

end



endmodule
