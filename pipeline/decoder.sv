`default_nettype none

module Decoder(
    input   wire [6:0] op,
    input   wire [2:0] funct3,
    input   wire [6:0] funct7,

    output  logic [1:0] result_src,
    output  logic       mem_write,
    output  logic [3:0] alu_control,
    output  logic       alu_src,
    output  logic [1:0] imm_src,
    output  logic       reg_write,
    output  logic       jump,
    output  logic       branch,
    
    //追加した制御信号
    output logic  pc_alu_src //jar or jalr
);

logic [1:0] alu_op;

always_comb begin
    case (op)
        // lw,lb,lh,lbu,lhu
        7'b0000011 : begin
            reg_write  = 1;
            imm_src    = 2'b0;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 1;
            alu_op     = 2'b0;
            branch     = 1'b0;
            jump       = 1'b0;
        end
        // sw,sb,sh(S-形式)
        7'b0100011 : begin
            reg_write  = 0;
            imm_src    = 2'b01;
            alu_src    = 1;
            mem_write  = 1;
            result_src = 0;
            alu_op     = 2'b00;
            branch     = 1'b0;
            jump       = 1'b0;
        end
        // R-形式
        7'b0110011 : begin
            reg_write  = 1;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b10;
            branch     = 1'b0;
            jump       = 1'b0;
        end
        // B-形式
        7'b1100011 : begin
            reg_write  = 0;
            imm_src    = 2'b10;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b01;
            branch     = 1'b1;
            jump       = 1'b0;
            pc_alu_src = 1'b0;
        end
        // addi,slli,slti,sltiu,xori,srli,srai,ori,andi
        7'b0010011 : begin
            reg_write  = 1;
            imm_src    = 2'b00;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b10;
            branch     = 1'b0;
            jump       = 1'b0;
        end
        // jal
        7'b1101111 : begin
            reg_write  = 1;
            imm_src    = 2'b11;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 2'b10;
            alu_op     = 2'b00;
            branch     = 1'b0;
            jump       = 1'b1;
            pc_alu_src = 1'b0;
        end
        // jalr
        7'b1100111 : begin
            reg_write  = 1;
            imm_src    = 2'b00;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 2'b10;
            alu_op     = 2'b10;
            branch     = 1'b0;
            jump       = 1'b1;
            pc_alu_src = 1'b1;
        end
        default : begin
            reg_write  = 0;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 0;
            branch     = 1'b0;
            jump       = 1'b0;
        end
    endcase
end

logic [1:0] op5_funct7_5;
assign op5_funct7_5 = {op[5],funct7[5]};

always_comb begin
    if(branch) begin
        case(funct3)
            //beq
            3'b000 : alu_control = 4'b1010;
            //bne
            3'b001 : alu_control = 4'b1011;
            //blt
            3'b100 : alu_control = 4'b0101;
            //bge
            3'b101 : alu_control = 4'b1100;
            //bltu
            3'b110 : alu_control = 4'b0110;
            //bgeu
            3'b111 : alu_control = 4'b1101;
            default: alu_control = 4'b0000;
        endcase
    end
    else begin
        case(alu_op)
            2'b00 : alu_control = 4'b0000;
            2'b01 : alu_control = 4'b0001;
            2'b10 : begin
                case(funct3)
                    3'b000 : begin
                        case (op5_funct7_5)
                            2'b11 : alu_control = 4'b0001;
                            default : alu_control = 4'b0000;
                        endcase
                    end
                    3'b001 : alu_control = 4'b0111;
                    3'b010 : alu_control = 4'b0101;
                    3'b011 : alu_control = 4'b0110;
                    3'b100 : alu_control = 4'b0100;
                    3'b101 : begin
                        case(op5_funct7_5)
                            2'b01 : alu_control = 4'b1001;
                            2'b11 : alu_control = 4'b1001;
                            default : alu_control = 4'b1000;
                        endcase
                    end
                    3'b110 : alu_control = 4'b0011;
                    3'b111 : alu_control = 4'b0010;
                    default : alu_control = 4'b0000;
                endcase
            end
            default : alu_control = 4'b0000;
        endcase
    end
end

endmodule
`default_nettype wire
