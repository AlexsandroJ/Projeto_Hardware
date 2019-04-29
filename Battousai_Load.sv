module Battousai_Load (	
					input logic [63:0] Dataout,
					input logic [31:0] Register_Intruction_Instr31_0,
					output logic [63:0]Saida_Memory_Data
					);

    always_comb begin
        case(Register_Intruction_Instr31_0[6:0])
            7'd3: begin
                if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //lbu rd, imm(rs1)
                    Saida_Memory_Data = { 56'd0, Dataout[7:0] };
                end
                else begin
                    if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //lhu rd, imm(rs1)
                        Saida_Memory_Data = { 48'd0, Dataout[15:0] };
                    end
                    else begin
                        if(Register_Intruction_Instr31_0[14:12]==3'd6) begin //lwu rd, imm(rs1)
                            Saida_Memory_Data = { 32'd0, Dataout[31:0] };
                        end
                        else begin
                            if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //lb rd, imm(rs1)
                                if(Dataout[7]==1'd0) begin
                                    Saida_Memory_Data = { 56'd0, Dataout[7:0] };
                                end
                                else begin
                                    Saida_Memory_Data = { 56'd72057594037927935, Dataout[7:0] };
                                end    
                            end
                            else begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //lh rd, imm(rs1)
                                    if(Dataout[15]==1'd0) begin
                                        Saida_Memory_Data = { 48'd0, Dataout[15:0] };
                                    end
                                    else begin
                                        Saida_Memory_Data = { 48'd281474976710655, Dataout[15:0] };
                                    end    
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //lw rd, imm(rs1)
                                        if(Dataout[31]==1'd0) begin
                                            Saida_Memory_Data = { 32'd0, Dataout[31:0] };
                                        end
                                        else begin
                                            Saida_Memory_Data = { 32'd4294967295, Dataout[31:0] };
                                        end    
                                    end
                                    else begin //ld rd, imm(rs1)
                                        Saida_Memory_Data = Dataout;   
                                    end
                                end
                            end
                        end
                    end
                end
            end
        endcase
    end

endmodule