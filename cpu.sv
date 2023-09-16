module IMemory(
    input  wire [31:0]   pc,
    output logic [31:0]  instr
);

always_comb begin
    case (pc)
        32'h0000 : instr = 32'h0000a303; // lw x6, 0(x1)
        32'h0004 : instr = 32'h00612023; // sw x6, 0(x2)
        default: begin
            instr = 32'h0000;
            $display("die");
        end
    endcase
end

endmodule

module Regfile(
    input   wire          clk,
    input   wire          rst,

    // 読み込み
    input  wire   [4:0]   addr1,
    output logic [31:0]   rd1,
    input  wire   [4:0]   addr2,
    output logic [31:0]   rd2,

    // 書き込み
    input  wire  [4:0]    addr3,
    input  wire           we3,
    input  wire [31:0]    wd3
);

logic [31:0] regfile [0:31];

always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 0; i < 32; i++) begin
            regfile[i] <= 32'h0;
        end
    end else begin
        if (we3) begin
            regfile[addr3] <= wd3;
        end
    end
end

always_comb begin
    // rd1にaddr1の中身を出力
    rd1 = regfile[addr1];

    // rd2にaddr2の中身を出力
    rd2 = regfile[addr2];
end

endmodule

module DMemory (
    input  wire             clk,
    input  wire [31: 0]     address,
    input  wire [31: 0]     write_data,
    input  wire             write_enable, 
    output logic [31: 0]     read_data
);

logic [31:0] dmemory [0:1023];

always_ff @(posedge clk) begin
    if(write_enable) begin
        dmemory[address] <= write_data;
    end
end

always_comb begin
    if (address == 32'h0) begin
        read_data = 32'hdeadbeef;
    end else begin
        read_data = dmemory[address];
    end
end

endmodule

module ALU (
    input  wire  [2:0]   alu_control,
    input  wire [31:0]   srca,
    input  wire [31:0]   srcb,

    output logic [31:0]   alu_result
);

always_comb begin
    case (alu_control)
        3'b000 : alu_result = srca + srcb;
        3'b001 : alu_result = srca - srcb;
        3'b010 : alu_result = srca & srcb;
        3'b011 : alu_result = srca | srcb;
        3'b101 : alu_result = srca < srcb;
        default: begin
            alu_result = 32'hDEADBEEF;
            $display("Unknown ALU command.");
        end
    endcase
end

// assign alu_result = 32'hDEADBEEF;

endmodule

module CPU(
    input   wire    clk,
    input   wire    rst
);
    logic   [31: 0] pc;
    logic   [31: 0] instr;
    logic   [2:0]   alu_control;

    IMemory instruction_memory(
        .pc(pc),
        .instr(instr)
    );
    
    always_comb begin
        alu_control = 3'b000;
    end

    wire [31: 0] pc_next = pc + 4;
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
        .rd2(write_data),
        
        .addr3(instr[11: 7]),
        .wd3(memory_read_data)
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
    function [31: 0] extend(input imm_src, input [31:0] instr);
        case(imm_src)
            // I-Type
            1'b0: extend = 32'(signed'(instr[31 -: 12]));
            // S-Type
            1'b1: extend = 32'(signed'({instr[31 -:  7], instr[7 +: 5]}));
            default: extend = 32'hdeadbeef;
        endcase
    endfunction

    logic   [31:0] alu_result;
    ALU alu(
        .alu_control(alu_control),
        .srca(rd1),
        .srcb(extend(instr)),
        .alu_result(alu_result)
    );

    logic   [31: 0] memory_read_data;

    DMemory data_memory(
        .clk(clk),
        .address(alu_result),
        .read_data(memory_read_data),
        .write_enable(1'b0),
        .write_data(write_data)
    );
endmodule