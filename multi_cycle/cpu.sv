`default_nettype none

module CPU(
    input   wire    clk,
    input   wire    rst
);
    logic   [31: 0] pc;

    // non architectural register
    logic  [31: 0]  instr;
    logic  [31: 0]  old_pc;
    logic  [31: 0]  data;

    // control signal
    logic   [2:0]   alu_control;
    logic   [1:0]   imm_src;
    logic           reg_write;
    logic           mem_write;
    logic   [1:0]   result_src;
    logic   [1:0]   pc_src;
    logic           zero;
    
    // fsm signal
    logic           ir_write;
    logic           adr_src;
    logic           pc_write;
    logic           alu_src_a;
    logic           alu_src_b;
    
    logic  [31:0]  read_data;
    logic  [31:0]  adr;
    
    
    always_ff @(posedge clk) begin
        if (rst) begin
            instr <= 32'h0;
            old_pc <= 0;
        end else begin
            if (ir_write) begin
                instr <= read_data;
                old_pc <= pc;
            end
            data <= read_data;
        end
    end
    
    assign adr = adr_src ? alu_out : pc;

    Memory memory(
        .clk(clk),
        .address(pc),
        .read_data(read_data),
        .write_enable(mem_write),
        .write_data(write_data)
    );

    logic [31:0] pc_next;
    logic [31:0] pc_plus_4;
    logic [31:0] pc_target;

    assign pc_next = result;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 0;
        end
        else begin
            if (pc_write) begin
                pc <= pc_next;
            end
        end
    end

    logic   [6:0] op;
    logic   [6:0] funct7;
    logic   [2:0] funct3;

    assign op     = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];

    Decoder decoder(
        .zero(zero),
        .op(op),
        .funct3(funct3),
        .funct7(funct7),

        .pc_src(pc_src),
        .result_src(result_src),
        .mem_write(mem_write),
        .alu_control(alu_control),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write)
    );

    logic   [31: 0] rd1, rd2;
    logic   [31: 0] write_data;
    // non architectural register
    logic   [31: 0] a;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            a <= 0;
            write_data <= 0;
        end else begin
            a <= rd1;
            write_data <= rd2;
        end
    end

    // for I-format
    Regfile reg_file(
        .clk(clk),
        .rst(rst),

        .addr1(instr[19: 15]),
        .rd1(rd1),
        .addr2(instr[24: 20]),
        .rd2(rd2),

        .addr3(instr[11: 7]),
        .wd3(result),
        .we3(reg_write)
    );

    //logic   data_address = rd1 + instr[11: 0];
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

    logic   [31:0]  imm_ext;
    assign imm_ext = extend(imm_src, instr);

    assign pc_target = pc + imm_ext;

    logic   [31:0] alu_result;
    logic   [31:0] srca;
    logic   [31:0] srcb;
    // non architectural register
    logic   [31:0] alu_out;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            alu_out <= 0;
        end else begin
            alu_out <= alu_result;
        end
    end
    
    always_comb begin
        case(alu_src_a)
            2'b00 : srca = pc;
            2'b01 : srca = old_pc;
            2'b10 : srca = a;
            default : srca = 32'hdeadbeef;
        endcase
    end

    always_comb begin
        case(alu_src_b)
            //2'b00 : srcb = pc;
            2'b01 : srcb = imm_ext;
            2'b10 : srcb = 32'd4;
            default : srcb = 32'hdeadbeef;
        endcase
    end

    ALU alu(
        .alu_control(alu_control),
        .srca(srca),
        .srcb(srcb),
        .alu_result(alu_result),
        .zero(zero)
    );
    logic   [31: 0] result;
    always_comb begin
        case(result_src)
            2'b00 : result = alu_out;
            2'b01 : result = data;
            2'b10 : result = alu_result;
            default : result = 32'hdeadbeef;
        endcase
    end


endmodule
`default_nettype wire