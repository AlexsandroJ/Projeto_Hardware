module mux64
(   
    input logic [2:0]Seletor, 
    input logic [63:0] A, 
    input logic [63:0] B, 
    input logic [63:0] C, 
    input logic [63:0] D,
    output logic [63:0] Saida);

   // reg [2:0]Seletor;
    
    always_comb begin
        
        case(Seletor)
            3'b000: Saida = A;
            //end
            3'b001: Saida = B;
            //end
            3'b010: Saida = C;
            //end
            3'b011: Saida = D ;
            //end
            default: Saida = 64'd0;
            //end
        endcase
    end
endmodule
