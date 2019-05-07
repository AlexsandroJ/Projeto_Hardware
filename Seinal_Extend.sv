module Sinal_Extend(
            input logic [31:0] Sinal_In,
            output logic [64-1:0] Sinal_Out
        );

    always_comb begin

        if(Sinal_In[6:0]==7'd3 || (Sinal_In[6:0]==7'd103 && Sinal_In[14:12]==3'd0)) begin//tipo I
            if(Sinal_In[31]==0) begin
                Sinal_Out = { 52'd0, Sinal_In[31:20] };
            end
            else begin
                Sinal_Out = { 52'd4503599627370495, Sinal_In[31:20] };
            end
        end
        else begin
            if(Sinal_In[6:0]==7'd19) begin
                if(Sinal_In[14:12]==3'd0 || Sinal_In[14:12]==3'd2) begin //addi, slti(extensão signed)
                    if(Sinal_In[31]==0) begin
                        Sinal_Out = { 52'd0, Sinal_In[31:20] };
                    end
                    else begin
                        Sinal_Out = { 52'd4503599627370495, Sinal_In[31:20] };
                    end    
                end
            end
            else begin
                if(Sinal_In[6:0]==7'd35) begin //tipo S(extensão unsigned)
                    Sinal_Out = { 52'd0, Sinal_In[31:25], Sinal_In[11:7] };                      
                end
                else begin
                    if(Sinal_In[6:0]==7'd99) begin //tipo SB
                        if(Sinal_In[31]==0)
                        Sinal_Out = { 51'd0, Sinal_In[31], Sinal_In[7], Sinal_In[30:25], Sinal_In[11:8], 1'd0 };
                        else
                            Sinal_Out = { 51'h7FFFFFFFFFFFF, Sinal_In[31], Sinal_In[7], Sinal_In[30:25], Sinal_In[11:8], 1'd0 };                    
                    end
                    else begin
                        if(Sinal_In[6:0]==7'd103 && Sinal_In[14:12]!=3'd0) begin //tipo SB
                            if(Sinal_In[31]==0)
                            Sinal_Out = { 51'd0, Sinal_In[31], Sinal_In[7], Sinal_In[30:25], Sinal_In[11:8], 1'd0 };
                            else
                            Sinal_Out = { 51'h7FFFFFFFFFFFF, Sinal_In[31], Sinal_In[7], Sinal_In[30:25], Sinal_In[11:8], 1'd0 };  
                        end
                        else begin
                            if(Sinal_In[6:0]==7'd55) begin //tipo U
                                if(Sinal_In[31]==0)
                                Sinal_Out = { 32'd0, Sinal_In[31:12], 12'd0 };
                                else
                                Sinal_Out = { 32'd4294967295, Sinal_In[31:12], 12'd0 };
                            end
                            else begin
                                if(Sinal_In[6:0]==7'd111) begin //tipo UJ
                                if(Sinal_In[31]==0)
                                    Sinal_Out = { 43'd0, Sinal_In[31], Sinal_In[19:12], Sinal_In[20], Sinal_In[30:21], 1'd0 };
                                else
                                    Sinal_Out = { 43'd8796093022207, Sinal_In[31], Sinal_In[19:12], Sinal_In[20], Sinal_In[30:21], 1'd0 };                                    
                                end
                            end
                        end
                    end
                end
            end            
        end

    end

endmodule 
