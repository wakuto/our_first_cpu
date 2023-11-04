`default_nettype none

module CPU(
    input   wire    clk,
    input   wire    rst
);
    logic   [31: 0] pc_f;
    logic   [31: 0] instr_f;

    // control signal
    logic           reg_write_d;
    logic   [1:0]   result_src_d;
    logic           mem_write_d;
    logic           jump_d;
    logic           branch_d;
    logic   [2:0]   alu_control_d;
    logic           alu_src_d;
    logic   [1:0]   imm_src_d;

    logic           pc_alu_src_d;

    //PC
    logic [31:0] pc_next;
    logic [31:0] pc_plus_4_f;
    logic [31:0] pc_target_e;

    // Instruction
    logic   [6:0] op;
    logic   [6:0] funct7;
    logic   [2:0] funct3;

    // IF/ID register
    logic   [31: 0] instr_d;
    logic   [31: 0] pc_d;
    logic   [31: 0] pc_plus_4_d; 

    // Decode stage
    logic   [31: 0] rd1_d, rd2_d;
    logic   [31:0]  imm_ext_d;
    logic   [4 : 0] rd_d;
    logic   [4: 0] rs1_d, rs2_d;

    // ID/EX register
    logic   [31:0] rd1_e;
    logic   [31:0] rd2_e;
    logic   [31:0] pc_e;
    logic   [31:0] imm_ext_e;
    logic   [31:0] pc_plus_4_e;
    logic   [4 :0] rd_e;

    logic           reg_write_e;
    logic   [1:0]   result_src_e;
    logic           mem_write_e;
    logic           jump_e;
    logic           branch_e;
    logic   [2:0]   alu_control_e;
    logic           alu_src_e;
    logic           pc_alu_src_e;
    logic   [31:0]  pc_alu_src_a;


    logic   [4: 0] rs1_e, rs2_e;

    //ALU
    logic   [31:0] alu_result_e;
    logic   [31:0] srca_e;
    logic   [31:0] srcb_e;
    logic   [31: 0] write_data_e;
    
    logic          pc_src_e;
    logic          zero_e;
    
    // EX/MEM register
    logic   [31:0] alu_result_m;
    logic   [31:0] write_data_m;
    logic   [31:0] pc_plus_4_m;
    logic   [4 :0] rd_m;
    
    logic           reg_write_m;
    logic   [1:0]   result_src_m;
    logic           mem_write_m;

    //Data Memory
    logic   [31: 0] read_data_m;
    logic   [31: 0] result_w;
    
    // MEM/WB register
    logic   [31:0] alu_result_w;
    logic   [31:0] read_data_w;
    logic   [31:0] pc_plus_4_w;
    logic   [4 :0] rd_w;

    logic           reg_write_w;
    logic   [1:0]   result_src_w;
    
    // hazard signal
    logic           stall_f;
    logic           stall_d;
    logic           flush_d;
    logic           flush_e;
    logic           forward_rd2_d;
    logic  [1:0]    forward_a_e;
    logic  [1:0]    forward_b_e;

    IMemory instruction_memory(
        .pc(pc_f),
        .instr(instr_f)
    );

    assign pc_plus_4_f = pc_f + 4;
    assign pc_src_e = jump_e | (branch_e & zero_e);
    always_comb begin
        case(pc_src_e)
            2'b00:   pc_next   = pc_plus_4_f;
            2'b01:   pc_next   = pc_target_e;
            // 2'b10:   pc_next   = alu_result;
            default: pc_next = 32'hdeadbeef;
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_f <= 0;
        end
        else begin
            if (!stall_f) pc_f <= pc_next;
        end
    end

    always_ff @(posedge clk) begin
        if (rst | flush_d) begin
            instr_d <= 0;
            pc_d <= 0;
            pc_plus_4_d <= 0;
        end
        else begin
            if (!stall_d) begin
                instr_d <= instr_f;
                pc_d <= pc_f;
                pc_plus_4_d <= pc_plus_4_f;
            end
        end
    end

    assign rs1_d  = instr_d[19:15];
    assign rs2_d  = instr_d[24:20];
    assign rd_d   = instr_d[11:7];

    assign op     = instr_d[6:0];
    assign funct7 = instr_d[31:25];
    assign funct3 = instr_d[14:12];

    Decoder decoder(
        .op(op),
        .funct3(funct3),
        .funct7(funct7),

        .reg_write(reg_write_d),
        .result_src(result_src_d),
        .mem_write(mem_write_d),
        .jump(jump_d),
        .branch(branch_d),
        .alu_control(alu_control_d),
        .alu_src(alu_src_d),
        .imm_src(imm_src_d),

        .pc_alu_src(pc_alu_src_d)

    );

    // for I-format
    Regfile reg_file(
        .clk(clk),
        .rst(rst),

        .addr1(instr_d[19: 15]),
        .rd1(rd1_d),
        .addr2(instr_d[24: 20]),
        .rd2(rd2_d),

        .addr3(rd_w),
        .wd3(result_w),
        .we3(reg_write_w)
    );

    /*
    function 関数名(
        input 入力1,
        input 入力2
    );
        関数名 = 入力1 + 入力2;
    endfunction
    */
    function [31: 0] extend(input [1:0] imm_src, input [31:0] instr);
        case(imm_src)
            // I-Type
            2'b00: extend = 32'(signed'(instr[31 -: 12]));
            // S-Type
            2'b01: extend = 32'(signed'({instr[31 -:  7], instr[7 +: 5]}));
            // B-Type
            2'b10: extend = 32'(signed'({instr[31], instr[7], instr[30:25], instr[11:8],1'b0}));
            // J-Type
            2'b11: extend = 32'(signed'({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}));
            default: extend = 32'hdeadbeef;
        endcase
    endfunction

    assign imm_ext_d = extend(imm_src_d, instr_d);

    // assign pc_target_e = pc_e + imm_ext_e;
    assign pc_target_e = pc_alu_src_a + imm_ext_e;
    always_comb begin
        case(pc_alu_src_e)
            1'b0: pc_alu_src_a = pc_e;
            1'b1: begin
                case(forward_a_e)
                    2'b00 : pc_alu_src_a = rd1_e;
                    2'b01 : pc_alu_src_a = result_w;
                    2'b10 : pc_alu_src_a = alu_result_m;
                    default : pc_alu_src_a = 32'hBAD0001;
                endcase
            end
            default : pc_alu_src_a = 32'hBAD0002;
        endcase
    end

    // write to ID/EX registers
    always_ff @(posedge clk) begin
        if (rst | flush_e) begin
            rd1_e <= 0;
            rd2_e <= 0;
            pc_e <= 0;
            imm_ext_e <= 0;
            pc_plus_4_e <= 0;
            rd_e <= 0;

            reg_write_e <= 0;
            result_src_e <= 0;
            mem_write_e <= 0;
            jump_e <= 0;
            branch_e <= 0;
            alu_control_e <= 0;
            alu_src_e <= 0;
            pc_alu_src_e <= 0;

            rs1_e <= 0;
            rs2_e <= 0;
        end else begin
            rd1_e <= rd1_d;
            rd2_e <= forward_rd2_d ? result_w : rd2_d;
            pc_e <= pc_d;
            imm_ext_e <= imm_ext_d;
            pc_plus_4_e <= pc_plus_4_d;
            rd_e <= rd_d;

            reg_write_e <= reg_write_d;
            result_src_e <= result_src_d;
            mem_write_e <= mem_write_d;
            jump_e <= jump_d;
            branch_e <= branch_d;
            alu_control_e <= alu_control_d;
            alu_src_e <= alu_src_d;
            pc_alu_src_e <= pc_alu_src_d;

            rs1_e <= rs1_d;
            rs2_e <= rs2_d;
        end
    end

    always_comb begin
        case(forward_a_e)
            2'b00 : srca_e = rd1_e;
            2'b01 : srca_e = result_w;
            2'b10 : srca_e = alu_result_m;
            default : srca_e = 32'hBADCAFE;
        endcase
    end

    always_comb begin
        case(forward_b_e)
            2'b00 : write_data_e = rd2_e;
            2'b01 : write_data_e = result_w;
            2'b10 : write_data_e = alu_result_m;
            default : write_data_e = 32'hCAFEBABE;
        endcase
        if(alu_src_e == 0) begin
            srcb_e = write_data_e;
        end
        else begin
            srcb_e = imm_ext_e;
        end
    end

    ALU alu(
        .alu_control(alu_control_e),
        .srca(pc_alu_src_a_e),
        .srcb(srcb_e),
        .alu_result(alu_result_e),
        .zero(zero_e)
    );

    // assign result = result_src ? read_data : alu_result;
    always_comb begin
        case(result_src_w)
            2'b00 : result_w = alu_result_w;
            2'b01 : result_w = read_data_w;
            2'b10 : result_w = pc_plus_4_w;
            default : result_w = 32'hdeadbeef;
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (rst) begin
            alu_result_m <= 0;
            write_data_m <= 0;
            pc_plus_4_m <= 0;
            rd_m <= 0;

            reg_write_m <= 0;
            result_src_m <= 0;
            mem_write_m <= 0;
        end else begin
            alu_result_m <= alu_result_e;
            write_data_m <= write_data_e;
            pc_plus_4_m <= pc_plus_4_e;
            rd_m <= rd_e;

            reg_write_m <= reg_write_e;
            result_src_m <= result_src_e;
            mem_write_m <= mem_write_e;
        end
    end

    DMemory data_memory(
        .clk(clk),
        .address(alu_result_m),
        .read_data(read_data_m),
        .write_enable(mem_write_m),
        .write_data(write_data_m)
    );
    
    always_ff @(posedge clk) begin
        if (rst) begin
            alu_result_w <= 0;
            read_data_w <= 0;
            pc_plus_4_w <= 0;
            rd_w <= 0;

            reg_write_w <= 0;
            result_src_w <= 0;
        end else begin
            alu_result_w <= alu_result_m;
            read_data_w <= read_data_m;
            pc_plus_4_w <= pc_plus_4_m;
            rd_w <= rd_m;

            reg_write_w <=  reg_write_m;
            result_src_w <= result_src_m;
        end
    end
    
    Hazard hazard(
        .rs1_e(rs1_e),
        .rs2_e(rs2_e),
        .rs1_d(rs1_d),
        .rs2_d(rs2_d),
        .rd_e(rd_e),
        .result_src_e(result_src_e),
        .pc_src_e(pc_src_e),
        .rd_m(rd_m),
        .reg_write_m(reg_write_m),
        .rd_w(rd_w),
        .reg_write_w(reg_write_w),

        .stall_f(stall_f),
        .stall_d(stall_d),
        .flush_d(flush_d),
        .flush_e(flush_e),
        .forward_rd2_d(forward_rd2_d),
        .forward_a_e(forward_a_e),
        .forward_b_e(forward_b_e)
    );
endmodule
`default_nettype wire