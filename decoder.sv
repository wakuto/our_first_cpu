`default_nettype none

module Decoder(
    input   wire       zero,
    input   wire [6:0] op,
    input   wire [2:0] funct3,
    input   wire [6:0] funct7,

    output  logic       pc_src,
    output  logic       result_src,
    output  logic       mem_write,
    output  logic [2:0] alu_control,
    output  logic       alu_src,
    output  logic [1:0] imm_src,
    output  logic       reg_write
);

logic       branch;
logic [1:0] alu_op;

always_comb begin
    case (op)
        // lw
        7'b0000011 : begin
            reg_write  = 1;
            imm_src    = 2'b0;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 1;
            branch     = 0;
            alu_op     = 2'b0;
        end
        // sw
        7'b0100011 : begin
            reg_write  = 0;
            imm_src    = 2'b01;
            alu_src    = 1;
            mem_write  = 1;
            result_src = 0;
            branch     = 0;
            alu_op     = 2'b00;
        end
        // R-形式
        7'b0110011 : begin
            reg_write  = 1;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            branch     = 0;
            alu_op     = 2'b10;
        end
        // beq
        7'b1100011 : begin
            reg_write  = 0;
            imm_src    = 2'b10;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            branch     = 1;
            alu_op     = 2'b01;
        end
        default : begin
            reg_write  = 0;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            branch     = 0;
            alu_op     = 0;
        end
    endcase
    
    pc_src = zero & branch;
end

logic [1:0] op5_funct7_5;
assign op5_funct7_5 = {op[5],funct7[5]};

always_comb begin
    case(alu_op)
        2'b00 : alu_control = 3'b000;
        2'b01 : alu_control = 3'b001;
        2'b10 : begin
            case(funct3)
                3'b000 : begin
                    
                    case (op5_funct7_5)
                        2'b11 : alu_control = 3'b001;
                        default : alu_control = 3'b000;
                    endcase
                end
                3'b010 : alu_control = 3'b101;
                3'b110 : alu_control = 3'b011;
                3'b111 : alu_control = 3'b010;
                default : alu_control = 3'b000;
            endcase
        end
        default : alu_control = 3'b000;
    endcase
end

endmodule
`default_nettype wire