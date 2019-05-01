module UC (
    
    input logic clock, reset,
    input logic [31:0]Register_Intruction_Instr31_0,
    input logic z,      //flag que indica se o resultado da operação foi 0
    input logic igual,  //flag que indica se A=B
    input logic maior,  //flag que indica se A>B
    input logic menor,  //flag que indica se A<B
    input logic overFlow,
    output logic PC_Write,
    output logic [2:0]Seletor_Ula,
    output logic Load_ir,
    output logic [2:0]mux_A_seletor,
    output logic [2:0]mux_B_seletor,
    output logic Data_Memory_wr,
    output logic bancoRegisters_wr,
    output logic reset_A, //bit de sinal que zera(reseta) o registrador A
    output logic [2:0]Mux_Banco_Reg_Seletor,
    output logic [1:0]Shift_Control,
    output logic Reg_A_Write,
    output logic Reg_B_Write,
    output logic [4:0] Situacao,
    output logic Reg_Memory_Data_wr,
    output logic EPC_wr,
    output logic Reg_Causa_wr,
    output logic [63:0] Reg_Causa_Dados_In,
    output logic [2:0] Mux64_PC_Extend_Seletor,
    output logic flag_overFlow,
    output logic Reg_ULAOut_Out
  
    );
    
    enum logic [4:0]{   BUSCA                   = 5'd1 ,
                        SELECAO                 = 5'd2 ,
                        SALTO                   = 5'd3 , 
                        MEM_INST                = 5'd4 , 
                        MEM_INST_2              = 5'd5 , 
                        FLAG                    = 5'd6 , 
                        MEM_DATA                = 5'd7 , 
                        MEM_DATA_2              = 5'd8 ,
                        ESPERA                  = 5'd9,
                        NOP                     = 5'd10, 
                        EXECECAO                = 5'd11, 
                        EXECECAO_OVEFLOW        = 5'd12 , 
                        EXECECAO_INEXISTENTE    = 5'd13, 
                        WAIT_MEM                = 5'd14, 
                        WAIT_EXTEND             = 5'd15 , 
                        WAIT_EPC_SOMA           = 5'd16, 
                        WAIT_PC                 = 5'd17,
                        ESPERA_2                = 5'd18,
                        INICIO                  = 5'd0 } estado;
    logic flag_overFlow2;
    always_ff @(posedge clock, posedge reset) begin 
        
        if(reset) begin
           
            reset_A                     = 1;
            Load_ir                     = 1; //Lê instrução vinda de PC
            flag_overFlow               = 0;
            flag_overFlow2              = 0;
            EPC_wr                      = 0;
            Reg_Causa_wr                = 0;
            Mux64_PC_Extend_Seletor    = 3'd0;
            estado                      = BUSCA;
        end
        else begin  

            if (flag_overFlow)begin
                flag_overFlow   = 0;
                flag_overFlow2  = 1;
                estado          = EXECECAO;
            end
            else begin
            
                case(estado)


                    BUSCA:begin
                        reset_A                     = 0;
                        Reg_Memory_Data_wr          = 0;
                        bancoRegisters_wr = 0; //Para de receber valor do mux                        
                        PC_Write                    = 1;
                        Seletor_Ula                 = 3'd1;
                        // Selecao de PC + 4
                        mux_A_seletor               = 3'd0;
                        mux_B_seletor               = 3'd1;
                        // Salvar Valores dos registadores das instrucoes
                        Reg_A_Write                 = 1;
                        Reg_B_Write                 = 1;
                        // Ir para proximo estado
                        estado                      = SELECAO;                        
                        Mux_Banco_Reg_Seletor       = 3'd1;
                    end
                    SELECAO:begin
    
                        PC_Write    = 0;//PC para de ler instrucao
                        // nao ler instrucao, valores salvos nos registradores
                        Reg_A_Write = 1;
                        Reg_B_Write = 1;
                        Mux64_PC_Extend_Seletor     = 3'd0;

                        

                        case(Register_Intruction_Instr31_0[6:0])
                            7'd51: begin //tipo R
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[14:12]==3'd0 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //add rd, rs1, rs2
                                    Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                    Seletor_Ula     = 3'd1;        //Operação soma
                                    mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor   = 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                    estado          = MEM_INST;
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd0 && Register_Intruction_Instr31_0[31:25]==7'd32) begin //sub rd, rs1, rs2
                                        Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                        Seletor_Ula     = 3'd2;        //Operação subtração
                                        mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                        mux_B_seletor   = 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                        estado          = MEM_INST;
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd7 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //and rd, rs1, rs2
                                            Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                            Seletor_Ula     = 3'd3;        //Operação AND
                                            mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor   = 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                            estado          = MEM_INST;            
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd2 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //slt rd, rs1, rs2
                                                Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                                Seletor_Ula     = 3'd7;        //Operação comparação
                                                mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                                mux_B_seletor   = 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                                estado          = FLAG;         
                                            end
                                            else begin
                                                Load_ir             = 0;
                                                PC_Write            = 0;
                                                Data_Memory_wr      = 0;
                                                bancoRegisters_wr   = 0;
                                                Reg_A_Write         = 0;
                                                Reg_B_Write         = 0;
                                                estado              = EXECECAO;
                                            end
                                        end
                                    end            
                                end
                            end
                            7'd19: begin //tipo I
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[31:7]==25'd0) begin //nop
                                    
                                
                                    bancoRegisters_wr   = 0;
                                    Reg_Memory_Data_wr  = 0;
                                    estado              = NOP;

                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //addi rd, rs1, immediate
                                        Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                        Seletor_Ula     = 3'd1;        //Operação soma(com constante)
                                        mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                        mux_B_seletor   = 3'd2;      //Valor contido em immediate sai do MUX de baixo  
                                        estado          = MEM_INST;                      
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //slti rd, rs1, immediate
                                            Shift_Control   = 2'd3;      //O deslocador_funcional não faz nada
                                            Seletor_Ula     = 3'd7;        //Operação comparação
                                            mux_A_seletor   = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor   = 3'd2;      //Valor immediate sai do MUX de baixo
                                            estado          = FLAG;                                        
                                        end
                                        else begin //tipo I(shifts)
                                            if(Register_Intruction_Instr31_0[14:12]==3'd5 && Register_Intruction_Instr31_0[31:26]==6'd0) begin //srli rd, rs1, shamt
                                                Shift_Control   = 2'd1;      //Shift a direita lógico
                                                Seletor_Ula     = 3'd0;        //Operação carregar A
                                                mux_A_seletor   = 3'd1;      //Valor contido em A sai do MUX de cima
                                                estado          = MEM_INST;
                                            end
                                            else begin
                                                if(Register_Intruction_Instr31_0[14:12]==3'd5 && Register_Intruction_Instr31_0[31:26]==6'd16) begin //srai rd, rs1, shamt
                                                    Shift_Control   = 2'd2;      //Shift a direita aritmético
                                                    Seletor_Ula     = 3'd0;        //Operação carregar A
                                                    mux_A_seletor   = 3'd1;      //Valor contido em A sai do MUX de cima
                                                    estado          = MEM_INST;
                                                end
                                                else begin
                                                    if(Register_Intruction_Instr31_0[14:12]==3'd1 && Register_Intruction_Instr31_0[31:26]==6'd0) begin //slli rd, rs1, shamt
                                                        Shift_Control   = 2'd0;      //Shift a esquerda lógico
                                                        Seletor_Ula     = 3'd0;        //Operação carregar A
                                                        mux_A_seletor   = 3'd1;      //Valor contido em A sai do MUX de cima
                                                        estado          = MEM_INST;
                                                    end
                                                    else begin
                                                            
                                                        Load_ir             = 0;
                                                        PC_Write            = 0;
                                                        Data_Memory_wr      = 0;
                                                        bancoRegisters_wr   = 0;
                                                        Reg_A_Write         = 0;
                                                        Reg_B_Write         = 0;
                                                        estado              = EXECECAO;
                                                    end
                                                end    
                                            end
                                        end    
                                    end
                                end
                            end
                            7'd115: begin //tipo I -> break  
                                Load_ir     = 0;    //Registrador de Instrução tem que estar travado                       
                                estado      = SELECAO; //Loop
                            end                                
                            7'd3: begin //tipo I
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[14:12]==3'd3) begin //ld rd, imm(rs1)
                                    Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                    Seletor_Ula         = 3'd1;        //Operação soma(com constante e endereço)
                                    mux_A_seletor       = 3'd1;      //Endereço contido em rs1 sai do MUX de cima
                                    mux_B_seletor       = 3'd2;      //Valor contido em immediate sai do MUX de baixo
                                    Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                    estado              = MEM_DATA;
                                end
                                else begin//a gente tem que ligar a memória a um extensor de sinal adicional só pra pra lidar com esses loads 
                                    if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //lb rd, imm(rs1)
                                        Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                        Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                        mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                        mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                        Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                        estado              = MEM_DATA;
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //lh rd, imm(rs1)
                                            Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                            Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                            mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                            mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                            Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                            estado              = MEM_DATA;
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //lw rd, imm(rs1)
                                                Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                                Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                                mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                                estado              = MEM_DATA;
                                            end
                                            else begin
                                                if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //lbu rd, imm(rs1)
                                                    Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                                    Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                                    mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                    mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                    Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                                    estado              = MEM_DATA;
                                                end
                                                else begin
                                                    if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //lhu rd, imm(rs1)
                                                        Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                                        Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                                        mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                        mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                        Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                                        estado              = MEM_DATA;
                                                    end
                                                    else begin
                                                        if(Register_Intruction_Instr31_0[14:12]==3'd6) begin //lwu rd, imm(rs1)
                                                            Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                                            Seletor_Ula         = 3'd1;         //Operação soma(com constante e endereço)
                                                            mux_A_seletor       = 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                            mux_B_seletor       = 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                            Reg_Memory_Data_wr  = 1; //Registrador de memória de dados vai receber o valor saído da memória
                                                            estado              = MEM_DATA;
                                                        end
                                                        else begin
                                                            
                                                            Load_ir             = 0;
                                                            PC_Write            = 0;
                                                            Data_Memory_wr      = 0;
                                                            bancoRegisters_wr   = 0;
                                                            Reg_A_Write         = 0;
                                                            Reg_B_Write         = 0;
                                                            estado              = EXECECAO;
                                                        end
                                                    end
                                                end    
                                            end    
                                        end
                                    end
                                end
                            end
                            7'd35: begin //tipo S
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[14:12]==3'd7) begin //sd rs2, imm(rs1)
                                    Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                    Seletor_Ula         = 3'd1;    //Operação soma(com constante e endereço)
                                    mux_A_seletor       = 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                    mux_B_seletor       = 3'd2;  //Valor contido em immediate sai do MUX de baixo 
                                    estado              = MEM_DATA_2;                               
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sw rs2, imm(rs1)
                                        Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                        Seletor_Ula         = 3'd1;    //Operação soma(com constante e endereço)
                                        mux_A_seletor       = 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                        mux_B_seletor       = 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                        estado              = MEM_DATA_2;
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //sh rs2, imm(rs1)
                                            Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                            Seletor_Ula         = 3'd1;    //Operação soma(com constante e endereço)
                                            mux_A_seletor       = 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                            mux_B_seletor       = 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                            estado              = MEM_DATA_2;
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //sb rs2, imm(rs1)
                                                Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                                Seletor_Ula         = 3'd1;    //Operação soma(com constante e endereço)
                                                mux_A_seletor       = 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                                mux_B_seletor       = 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                                estado              = MEM_DATA_2;
                                            end
                                            else begin
                                                            
                                                Load_ir             = 0;
                                                PC_Write            = 0;
                                                Data_Memory_wr      = 0;
                                                bancoRegisters_wr   = 0;
                                                Reg_A_Write         = 0;
                                                Reg_B_Write         = 0;
                                                estado              = EXECECAO;
                                            end
                                        end    
                                    end    
                                end                             
                            end
                            7'd99: begin //tipo SB
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //beq rs1, rs2, imm
                                    Shift_Control   = 2'd3;  //O deslocador_funcional não faz nada
                                    Seletor_Ula     = 3'd7;    //Operação comparação
                                    mux_A_seletor   = 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor   = 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                    estado          = SALTO;        //Outra operação vai acontecer na ULA
                                end
                                else begin
                                                            
                                    Load_ir             = 0;
                                    PC_Write            = 0;
                                    Data_Memory_wr      = 0;
                                    bancoRegisters_wr   = 0;
                                    Reg_A_Write         = 0;
                                    Reg_B_Write         = 0;
                                    estado              = EXECECAO;
                                end
                            end
                            7'd103: begin //tipo SB ou tipo I
                                Load_ir = 0;    //Registrador de Instrução tem que estar travado
                                if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //bne rs1, rs2, imm
                                    Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                    Seletor_Ula         = 3'd7;    //Operação comparação
                                    mux_A_seletor       = 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor       = 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                    estado              = SALTO;        //Outra operação vai acontecer na ULA
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //jalr rd, rs1, imm
                                        //rd = PC
                                        Seletor_Ula     = 3'd0;        //Operação carregar A
                                        mux_A_seletor   = 3'd0;      //Valor contido em PC sai do MUX de cima                                    
                                        estado          = MEM_INST;         //Outra operação vai acontecer na ULA
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //bge rs1, rs2, imm
                                            Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                            Seletor_Ula         = 3'd7;    //Operação comparação
                                            mux_A_seletor       = 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor       = 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                            estado              = SALTO;        //Outra operação vai acontecer na ULA   
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //blt rs1, rs2, imm
                                                Shift_Control       = 2'd3;  //O deslocador_funcional não faz nada
                                                Seletor_Ula         = 3'd7;    //Operação comparação
                                                mux_A_seletor       = 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                                mux_B_seletor       = 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                                estado              = SALTO;        //Outra operação vai acontecer na ULA
                                            end   
                                            else begin
                                                            
                                                Load_ir             = 0;
                                                PC_Write            = 0;
                                                Data_Memory_wr      = 0;
                                                bancoRegisters_wr   = 0;
                                                Reg_A_Write         = 0;
                                                Reg_B_Write         = 0;
                                                estado              = EXECECAO;
                                            end     
                                        end     
                                    end
                                end    
                            end
                            7'd55: begin //tipo U -> lui rd, imm
                                Load_ir             = 0;    //Registrador de Instrução tem que estar travado
                                reset_A             = 1;
                                Shift_Control       = 2'd3;      //O deslocador_funcional não faz nada
                                Seletor_Ula         = 3'd1;        //Operação soma
                                mux_A_seletor       = 3'd1;      //Valor contido em rs1(zerado) sai do MUX de cima
                                mux_B_seletor       = 3'd2;      //Valor contido em immediate[31:12] com o lado direito[11:0] zerado e com sinal extendido sai do MUX de baixo
                                estado              = MEM_INST;
                            end
                            7'd111: begin //tipo UJ -> jal rd, imm
                                //rd = PC
                                Load_ir         = 0;    //Registrador de Instrução tem que estar travado
                                Seletor_Ula     = 3'd0;        //Operação carregar A
                                mux_A_seletor   = 3'd0;      //Endereço contido em PC sai do MUX de cima
                                estado          = MEM_INST;
                            end
                            default: begin

                                Load_ir             = 0;
                                PC_Write            = 0;
                                Data_Memory_wr      = 0;
                                bancoRegisters_wr   = 0;
                                Reg_A_Write         = 0;
                                Reg_B_Write         = 0;
                                estado              = EXECECAO;

                            end           
                        endcase
                        
                    end            
                    SALTO:begin
                        case(Register_Intruction_Instr31_0[6:0])
                            7'd99: begin //beq rs1, rs2, imm
                                if(igual==1) begin                      //se rs1=rs2                                
                                    Seletor_Ula = 3'd1;                 //Operação soma
                                    mux_A_seletor = 3'd0;               //Endereço contido em PC sai do MUX de cima
                                    mux_B_seletor = 3'd3;               //Endereço contido em immediate sai do MUX de baixo
                                    PC_Write = 1;
                                end
                            end
                            7'd103:begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //bne rs1, rs2, imm
                                    if(igual==0) begin         //se rs1-rs2>0 ou rs1-rs2<0
                                        Seletor_Ula = 3'd1;    //Operação soma
                                        mux_A_seletor = 3'd0;  //Endereço contido em PC sai do MUX de cima
                                        mux_B_seletor = 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                        PC_Write = 1;
                                    end
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //bge rs1, rs2, imm
                                        if(menor==0) begin         //se rs1>=rs2
                                            Seletor_Ula = 3'd1;    //Operação soma
                                            mux_A_seletor = 3'd0;  //Endereço contido em PC sai do MUX de cima
                                            mux_B_seletor = 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                            PC_Write = 1;
                                        end 
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //blt rs1, rs2, imm
                                            if(menor==1) begin         //se rs1<rs2
                                                Seletor_Ula = 3'd1;    //Operação soma
                                                mux_A_seletor = 3'd0;  //Endereço contido em PC sai do MUX de cima
                                                mux_B_seletor = 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                                PC_Write = 1;
                                            end 
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //jalr rd, rs1, imm
                                            //PC = rs1 + imm
                                            Shift_Control = 2'd3;      //O deslocador_funcional não faz nada
                                            Seletor_Ula = 3'd1;        //Operação soma
                                            mux_A_seletor = 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor = 3'd2;      //Valor contido em immediate sai do MUX de baixo
                                            PC_Write = 1;
                                            end
                                        end
                                    end
                                end
                            end
                            7'd111:begin //tipo UJ -> jal rd, imm
                                //PC = PC + imm[20:1][0]*2
                                Seletor_Ula = 3'd1;        //Operação soma
                                mux_A_seletor = 3'd0;      //Endereço contido em PC sai do MUX de cima
                                mux_B_seletor = 3'd3;      //Endereço contido em immediate sai do MUX de baixo
                                PC_Write = 1;                                                              
                            end
                        endcase
                        bancoRegisters_wr = 0; //Para de receber valor do mux                      
                        estado = ESPERA;
                    end
                    MEM_INST:begin                  //escreve no rd o que vem da entrada 0(ULA) do mux            
                        Mux_Banco_Reg_Seletor = 3'd0;  //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                        bancoRegisters_wr = 1;      //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                        if((Register_Intruction_Instr31_0[14:12]==3'd0 && Register_Intruction_Instr31_0[6:0]==7'd103) || Register_Intruction_Instr31_0[6:0]==7'd111) begin //Se a instrução for jalr ou jal
                            estado = SALTO;         //Vai fazer o salto
                        end
                        else begin
                            Load_ir = 1;
                            estado = BUSCA;         //Volta à busca por instrução
                        end
                    end
                    MEM_INST_2:begin                //escreve no rd o que vem da entrada 1(Memória de Dados) do mux
                        Mux_Banco_Reg_Seletor = 3'd1;   //O valor lido da memória de dados vai para datain no banco de registradores
                        bancoRegisters_wr = 1;          //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd
                        Load_ir = 1;
                        estado = BUSCA;                 //Delay para o valor ser carregado no registrador correto
                    end
                    FLAG:begin                         //análise de flags é feita aqui, exceto quando se trata de instrução de salto
                        if(menor==1) begin             //Se rs1<rs2
                            reset_A = 1;               //A gente tem que zerar o registrador A
                            Seletor_Ula = 3'd4;        //Operação incremento de A                        
                            mux_A_seletor = 3'd1;      //Valor contido em A(A=1) sai do MUX de cima
                            estado = MEM_INST;                                            
                        end
                        else begin
                            if(menor==0) begin         //Se rs1>=rs2
                            reset_A = 1;               //A gente tem que zerar o registrador A
                            Seletor_Ula = 3'd0;        //Operação carregar A                        
                            mux_A_seletor = 3'd1;      //Valor contido em A(A=0) sai do MUX de cima
                            estado = MEM_INST;
                            end
                        end
                    end
                    MEM_DATA:begin              //Loads
                        Data_Memory_wr = 0;     //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                        estado = MEM_INST_2;
                    end
                    MEM_DATA_2:begin           //Stores
                        Data_Memory_wr = 1;    //Permite a memória de dados guardar valor de rs2 no endereço rs1+immediate
                        Load_ir = 1;
                        estado = BUSCA;        //Volta à busca por instrução
                    end
                    ESPERA:begin
                        PC_Write = 0;                                               
                        estado = ESPERA_2;
                    end
                    ESPERA_2:begin
                        Load_ir = 1; 
                        estado = BUSCA;
                    end                    
                    NOP:begin
                        Load_ir             = 1;
                        estado              = BUSCA;
                    end   

                    EXECECAO:begin
                        Mux64_PC_Extend_Seletor     = 3'd1;
                        Mux_Banco_Reg_Seletor       = 3'd1;
                        Load_ir             = 0;
                        PC_Write            = 0;
                        EPC_wr              = 1;
                        Reg_Causa_wr        = 0;
                        bancoRegisters_wr   = 0;
                        Seletor_Ula         = 3'd2;
                        mux_A_seletor       = 3'd0;
                        mux_B_seletor       = 3'd1;
                        Data_Memory_wr      = 0;
                        Reg_Memory_Data_wr  = 0;   
                        estado              = WAIT_EPC_SOMA;
                        
                    end
                    WAIT_EPC_SOMA:begin
                        
                        if( flag_overFlow2 ) begin
                            flag_overFlow2      = 0;
                            estado              = EXECECAO_OVEFLOW;
                            Reg_Causa_wr        = 1;
                            Data_Memory_wr      = 1;
                            Reg_Causa_Dados_In  = 64'd1;
                            

                        end
                        else begin
                            
                            estado              = EXECECAO_INEXISTENTE;
                            Reg_Causa_wr        = 1;
                            Data_Memory_wr      = 1;
                            Reg_Causa_Dados_In  = 64'd0;

                        end
                    end   
                    EXECECAO_OVEFLOW:begin
                        EPC_wr              = 0;
                        Reg_Causa_wr        = 1;
                        mux_A_seletor       = 3'd3; // selecionando o endereco 255
                        Seletor_Ula         = 3'd0;
                        Data_Memory_wr      = 1;
                        Reg_Memory_Data_wr  = 0;
                        estado              = WAIT_MEM;
                        
                    end         
                    EXECECAO_INEXISTENTE:begin
                        EPC_wr              = 0; 
                        Reg_Causa_wr        = 1;
                        mux_A_seletor       = 3'd2; // selecionando o endereco 254
                        Seletor_Ula         = 3'd0;
                        Data_Memory_wr      = 1;
                        Reg_Memory_Data_wr  = 0;
                        estado              = WAIT_MEM;
                        
                    end
                    WAIT_MEM:begin
                        Data_Memory_wr      = 0;
                        Reg_Memory_Data_wr  = 1;
                        EPC_wr              = 0; 
                        Reg_Causa_wr        = 0;
                        estado              = WAIT_EXTEND;
                    end
                    WAIT_EXTEND:begin
                        Reg_Memory_Data_wr      = 0;
                        Data_Memory_wr          = 0;
                        PC_Write                = 1;
                        Mux64_PC_Extend_Seletor = 3'd1;
                        estado                  = WAIT_PC;
                        
                    end
                    WAIT_PC:begin
                        Data_Memory_wr          = 0;
                        Reg_Memory_Data_wr      = 0;
                        Mux64_PC_Extend_Seletor = 3'd1;
                        PC_Write                = 1;
                        estado                  = BUSCA;
                    end
                endcase

            end
            
        end
    
    end

    always_ff @(overFlow)begin
        flag_overFlow = overFlow;
    end

    always_ff @(posedge clock or posedge reset) // sincrono
    begin
	
	  	Situacao <= estado;
	   	
    end

endmodule