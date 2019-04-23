module Battousai_Load (	
					input logic [63:0] Dataout,
					input logic signed [63:0] Register_Intruction_Instr31_0,
					output logic [63:0]Saida_Memory_Data
					);

    always_comb begin
        case(Register_Intruction_Instr31_0[6:0])
            7'd3: begin
                if(Register_Intruction_Instr31_0[14:12]==3'd0 || Register_Intruction_Instr31_0[14:12]==3'd4) begin //lb rd, imm(rs1) || lbu rd, imm(rs1)
                    Saida_Memory_Data = { 56'd0, Dataout[7:0] };
                end
                else begin
                    if(Register_Intruction_Instr31_0[14:12]==3'd1 || Register_Intruction_Instr31_0[14:12]==3'd5) begin //lh rd, imm(rs1) || lhu rd, imm(rs1)
                        Saida_Memory_Data = { 48'd0, Dataout[15:0] };
                    end
                    else begin
                        if(Register_Intruction_Instr31_0[14:12]==3'd2 || Register_Intruction_Instr31_0[14:12]==3'd6) begin //lw rd, imm(rs1) || lwu rd, imm(rs1)
                            Saida_Memory_Data = { 32'd0, Dataout[31:0] };
                        end
                    end
                end
            end    
            default:
                Saida_Memory_Data = Dataout;
        endcase
    end

endmodule