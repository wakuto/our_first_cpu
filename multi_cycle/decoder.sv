`default_nettype none

module Decoder(
    input   wire       clk,
    input   wire       rst,
    input   wire       zero,
    input   wire [6:0] op,
    input   wire [2:0] funct3,
    input   wire [6:0] funct7,

    output  logic       pc_write,
    output  logic       reg_write,
    output  logic       mem_write,
    output  logic       ir_write,
    output  logic [1:0] result_src,
    output  logic       alu_src_b,
    output  logic       alu_src_a,
    output  logic       adr_src,
    output  logic [2:0] alu_control,
    output  logic [1:0] imm_src
);

logic       branch;
logic       pc_update;
logic [1:0] alu_op;

assign pc_write = (zero & branch) | pc_update;

typedef enum logic [3:0] {
    FETCH,
    DECODE,
    MEMADR,
    MEMREAD,
    MEMWB,
    MEMWRITE,
    EXECUTER,
    ALUWB,
    EXECUTEL,
    JAL,
    BEQ
} fsm_state_t;

fsm_state_t state;

always_ff @(posedge clk) begin
    if (rst) begin
        state <= FETCH;
    end else begin
        case (state)
            FETCH : state <= DECODE;
            DECODE : begin
                case (op)
                    7'b0000011 : state <= MEMADR;
                    7'b0100011 : state <= MEMADR;
                    7'b0110011 : state <= EXECUTER;
                    7'b0010011 : state <= EXECUTEL;
                    7'b1101111 : state <= JAL;
                    7'b1100011 : state <= BEQ;
                    default    : state <= FETCH;
                endcase
            end
            MEMADR : begin
                case (op)
                    7'b0000011 : state <= MEMREAD;
                    7'b0100011 : state <= MEMWRITE;
                    default    : state <= FETCH;
                endcase
            end
            MEMREAD : state <= MEMWB;
            MEMWB   : state <= FETCH;
            MEMWRITE: state <= FETCH;
            EXECUTER: state <= ALUWB;
            EXECUTEL: state <= ALUWB;
            JAL     : state <= ALUWB;
            BEQ     : state <= FETCH;
            default : state <= FETCH;
        endcase
    end
end

always_comb begin
    case (state)
        FETCH : begin
            adr_src     = 0;
            ir_write    = 1;
            alu_src_a   = 2'b00;
            alu_src_b   = 2'b10;
            alu_op      = 2'b00;
            result_src  = 2'b10;
            pc_update   = 1;
        end
        DECODE : begin
            alu_src_a   = 2'b01;
            alu_src_b   = 2'b01;
            alu_op      = 2'b00;
        end
        MEMADR : begin
            alu_src_a   = 2'b10;
            alu_src_b   = 2'b01;
            alu_op      = 2'b00;
        end
        MEMREAD : begin
            result_src   = 2'b00;
            adr_src      = 1;
        end
        MEMWB : begin
            result_src   = 2'b01;
            reg_write    = 1;
        end
        MEMWRITE : begin
            result_src   = 2'b01;
            adr_src      = 2'b01;
            mem_write    = 2'b00;
        end
        EXECUTER : begin
            alu_src_a   = 2'b10;
            alu_src_b   = 2'b00;
            alu_op      = 2'b10;
        end
        ALUWB: begin
            result_src   = 2'b00;
            reg_write    = 1;
        end
        EXECUTEL : begin
            alu_src_a   = 2'b10;
            alu_src_b   = 2'b01;
            alu_op      = 2'b10;
        end
    endcase
end

always_comb begin
    case (op)
        // lw
        7'b0000011 : begin
            reg_write  = 1;
            imm_src    = 2'b0;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 1;
            alu_op     = 2'b0;
            pc_src     = 2'b0;
        end
        // sw
        7'b0100011 : begin
            reg_write  = 0;
            imm_src    = 2'b01;
            alu_src    = 1;
            mem_write  = 1;
            result_src = 0;
            alu_op     = 2'b00;
            pc_src     = 2'b0;
        end
        // R-形式
        7'b0110011 : begin
            reg_write  = 1;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b10;
            pc_src     = 2'b00;
        end
        // beq
        7'b1100011 : begin
            reg_write  = 0;
            imm_src    = 2'b10;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b01;
            pc_src     = {1'b0, zero};
        end
        // addi
        7'b0010011 : begin
            reg_write  = 1;
            imm_src    = 2'b00;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 2'b10;
            pc_src     = 2'b00;
        end
        // jal
        7'b1101111 : begin
            reg_write  = 1;
            imm_src    = 2'b11;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 2'b10;
            alu_op     = 2'b00;
            pc_src     = 2'b01;
        end
        // jalr
        7'b1100111 : begin
            reg_write  = 1;
            imm_src    = 2'b00;
            alu_src    = 1;
            mem_write  = 0;
            result_src = 2'b10;
            alu_op     = 2'b10;
            pc_src     = 2'b10;
        end
        default : begin
            reg_write  = 0;
            imm_src    = 0;
            alu_src    = 0;
            mem_write  = 0;
            result_src = 0;
            alu_op     = 0;
            pc_src     = 2'b00;
        end
    endcase
    
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