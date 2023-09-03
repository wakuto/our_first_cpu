module IMemory(
    input  wire [31:0]   pc,
    output logic [31:0]  instr
);

always_comb begin 
    case (pc)
        0x0000 : instr = 0x0000a303; // lw x6, 0(x1)
        0x0004 : instr = 0x00612023; // sw x6, 0(x2)
        default: begin
            instr = 0x0000;
            $display("die");
        end
    endcase
end

endmodule

module Regfile(
    input  wire           clk,
    
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
    if (we3) begin
        regfile[addr3] <= wd3;
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
    output wire [31: 0]     read_data
)

logic [31:0] dmemory [0:1023];

always_ff @(poaedge clk) begin
    if(write_enable) begin
        dmemory[addresss] <= write_data;
    end
end

always_comb begin
    read_data = dmemory[address];
end

endmodule

module ALU (
    input  wire  [2:0]   alu_control,
    input  wire [31:0]   srca,
    input  wire [31:0]   srcb,

    output wire [31:0]   alu_result
)

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

endmodule

module CPU(
    input   wire    clk,
)
    logic   [31: 0] pc;
    logic   [31: 0] instr;
    logic   [2:0]   alu_control

    IMemory instruction_memory(
        .pc(pc),
        .instr(instr)
    );

    wire [31: 0] pc_next = pc + 4;
    always_ff @(posedge clk) begin
        pc <= pc_next;
    end

    logic   [31: 0] rd1, rd2;

    // for I-format
    Regfile reg_file(
        .clk(clk),
        
        .addr1(instr[19: 15]),
        .rd1(rd1),
        
        .addr3(instr[11: 7]),
        .wd3(memory_read_data)
    );

    //logic   data_address = rd1 + instr[11: 0];
    
    function [31: 0] extend(input wire [11:0] imm);
        extend = {20{imm[11]}, imm[11:0]};
    endfunction

    logic   [31:0] alu_result;
    ALU alu(
        .alu_control(alu_control)
        .srca(rd1)
        .srcb(extend(instr[31:20]))
        .alu_result(alu_result)
    );

    logic   [31: 0] memory_read_data;

    DMemory data_memory(
        .clk(clk),
        .address(alu_result)
        .read_data(memory_read_data),
        .write_enable(0)
    );
endmodule