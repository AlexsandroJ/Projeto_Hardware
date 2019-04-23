module mux64_PC
(   input logic [2:0] Seletor, [31:0] A, [63:0] B, [63:0] C, [63:0] D,

    output logic [63:0] Saida);
    
    always_comb begin
    case(Seletor)
        3'd0: begin

            Saida[31:0] = A[31:0]; 
            Saida[63:32] = 32'd0;

        end
        
        3'd1: Saida = B;
        3'd2: Saida = C;
        3'd3: Saida = D;
    endcase
    end
endmodule