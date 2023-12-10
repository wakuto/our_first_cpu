`default_nettype none

module Hazard (
    input wire [4:0]  rs1_d,
    input wire [4:0]  rs2_d,
    input wire [4:0]  rs1_e,
    input wire [4:0]  rs2_e,
    input wire [4:0]  rd_e,
    input wire        pc_src_e,
    input wire [2:0]  result_src_e,
    input wire [4:0]  rd_m,
    input wire        reg_write_m,
    input wire        read_enable,
    input wire        read_valid,
    input wire [4:0]  rd_w,
    input wire        reg_write_w,

    output logic      stall_f,
    output logic      stall_d,
    output logic      stall_read,
    output logic      flush_d,
    output logic      flush_e,
    output logic [1:0]forward_a_e,
    output logic [1:0]forward_b_e
);
logic lwstall;

always_comb begin
    if(((rs1_e == rd_m) & reg_write_m) & (rs1_e != 0)) begin
        forward_a_e = 2'b10;
    end
    else if(((rs1_e == rd_w) & reg_write_w) & (rs1_e != 0)) begin
        forward_a_e = 2'b01;
    end
    else forward_a_e= 2'b00;

    if(((rs2_e == rd_m) & reg_write_m) & (rs2_e != 0)) begin
        forward_b_e = 2'b10;
    end
    else if(((rs2_e == rd_w) & reg_write_w) & (rs2_e != 0)) begin
        forward_b_e = 2'b01;
    end
    else forward_b_e= 2'b00;

    lwstall = result_src_e[0] & ((rs1_d == rd_e) | (rs2_d == rd_e));
    stall_f = lwstall;
    stall_d = lwstall;
    stall_read = read_enable & !read_valid;
    flush_d = pc_src_e;
    flush_e = lwstall | pc_src_e;
end
endmodule
`default_nettype wire
