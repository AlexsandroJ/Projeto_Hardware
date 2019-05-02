module Battousai_Store (	
					input logic [63:0] Reg_B_Out,
                    input logic [63:0] Mem64_Out,
					input logic [31:0] Register_Intruction_Instr31_0,
					output logic [63:0] DadoIn_64
					);

    always_comb begin
        case(Register_Intruction_Instr31_0[6:0])
            7'd35: begin
                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //sb rd, imm(rs1)
                    DadoIn_64[63:8] = Mem64_Out[63:8];
                    DadoIn_64[7:0] = Reg_B_Out[7:0];                      
                end
                else begin
                    if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //sh rd, imm(rs1)
                        DadoIn_64[63:16] = Mem64_Out[63:16];
                        DadoIn_64[15:0] = Reg_B_Out[15:0];
                    end
                    else begin
                        if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sw rd, imm(rs1)
                            DadoIn_64[63:32] = Mem64_Out[63:32];
                            DadoIn_64[31:0] = Reg_B_Out[31:0];
                        end
                        else begin //sd rd, imm(rs1)
                            DadoIn_64 = Reg_B_Out;
                        end
                    end
                end
            end
        endcase
    end

endmodule