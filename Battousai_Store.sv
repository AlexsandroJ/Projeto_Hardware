module Battousai_Store (	
					input logic [63:0] Reg_B_Out,
					input logic signed [63:0] Register_Intruction_Instr31_0,
					output logic [63:0] DadoIn_64
					);

    always_comb begin
        case(Register_Intruction_Instr31_0[6:0])
            7'd35: begin
                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //sb rd, imm(rs1)
                    DadoIn_64 = { 56'd0, Reg_B_Out[7:0] };
                end
                else begin
                    if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //sh rd, imm(rs1)
                        DadoIn_64 = { 48'd0, Reg_B_Out[15:0] };
                    end
                    else begin
                        if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sw rd, imm(rs1)
                            DadoIn_64 = { 32'd0, Reg_B_Out[31:0] };
                        end
                    end
                end
            end    
            default:
                DadoIn_64 = Reg_B_Out;
        endcase
    end

endmodule