module CPU(
    input   wire    clk,
    input   wire    rst
);
    logic   [31: 0] pc;
    logic   [31: 0] instr;
    
    // control signal
    logic   [2:0]   alu_control;
    logic   [1:0]   imm_src;
    logic           reg_write;
    logic           mem_write;
    logic           alu_src;
    logic           result_src;
    logic           pc_src;
    logic           zero;

    IMemory instruction_memory(
        .pc(pc),
        .instr(instr)
    );
    
    always_comb begin
        alu_control = 3'b000;
    end

    logic [31:0] pc_next;

    assign pc_next = pc + 4;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 0;
        end
        else begin
            pc <= pc_next;
        end
    end

    logic   [31: 0] rd1, rd2;
    logic   [31: 0] write_data;

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
    assign write_data = rd2;

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
            2'b10: extend = 32'(signed'({instr[31], instr[7], instr[30:25], instr[12:9]}));
            default: extend = 32'hdeadbeef;
        endcase
    endfunction

    logic   [31: 0] pc_target;
    
    assign pc_target = pc + extend(imm_src, instr);

    logic   [31:0] alu_result;
    logic   [31:0] srcb;

    assign srcb = alu_src ? extend(imm_src, instr) : rd2;
    ALU alu(
        .alu_control(alu_control),
        .srca(rd1),
        .srcb(srcb),
        .alu_result(alu_result),
        .zero(zero)
    );

    logic   [31: 0] read_data;
    logic   [31: 0] result;
    assign result = result_src ? read_data : alu_result;
    DMemory data_memory(
        .clk(clk),
        .address(alu_result),
        .read_data(read_data),
        .write_enable(mem_write),
        .write_data(write_data)
    );
endmodule