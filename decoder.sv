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
    endcase
end

endmodule