`include "adder_32b.v"
`include "alu.v"
`include "aluControll.v"
`include "controll.v"
`include "multiplexer.v"
`include "registers.v"
`include "sign_extend.v"


module mips_core(
    inst_addr,
    inst,
    mem_addr,
    mem_data_out,
    mem_data_in,
    mem_write_en,
    halted,
    clk,
    rst_b
);
    output  [31:0] inst_addr;
    input   [31:0] inst;
    output  [31:0] mem_addr;
    input   [7:0]  mem_data_out[0:3];
    output  [7:0]  mem_data_in[0:3];
    output         mem_write_en;
    output reg     halted;
    input          clk;
    input          rst_b;

   /* inst_addr --> pc
      adder1 = pc + 4;
      adder2 = (pc+4) + shifter output;






    */

    // wire [5:0] rd_num;
    // reg [31:0] inst;
    // wire reg_dst,jump,branch,mem_read,mem_to_reg,alu_op,mem_write,alu_src,reg_write;


ADDER_32B adder1(.in1(inst_addr),.in2(4),.out(adder1_out)); // pc + 4


ADDER_32B adder2(.in1(adder1_out),.in2(shift_out),.out(adder2_out)); // pc + 4 + shift_out


// SHIFT_LEFT_2 sl_1(.in(inst[25:0]),out(jump_adr)); // this is not needed in harward impelementation


SHIFT_LEFT_2 sl_2(.in(sign_extend_out),out(shift_out)); // gives the output to adder2

// ALU_CONTROLL alu_controll(.clk(clk) // this is going to be merged with controller
// ,.inst(inst[5:0])
// ,.alu_op(alu_op)
// ,.alu_ctl_res(alu_ctl_res));


ALU alu(.clk(clk)
,.in1(rs_data) //Read data 1
,.in2(mux_2_out) // mux that alu_src controlls
,.alu_op(alu_op) 
,.zero(zero)
,.alu_result(mem_addr));


MULTIPLEXER mux1(.in0(inst[20:16]),.in1(inst[15:11]),.select(reg_dst),.out(rd_num));


MULTIPLEXER mux2(.in0(mem_data_in),.in1(sign_extend_out),.select(alu_src),.out(mux_2_out));


MULTIPLEXER mux3(.in0(mem_addr),.in1(mem_data_out),.select(mem_to_reg),.out(rd_data));


MULTIPLEXER mux4(.in0(adder1_out),.in1(adder2_out),.select(mux_4_select),.out(mux_4_out));


MULTIPLEXER mux5(.in0(mux_4_out),.in1(jump_adr),.select(jump),.out(inst_addr));

SIGN_EXTEND sign_extend(inst(inst[15:0]),.out(sign_extend_out));

and(mux_4_select,branch,zero);


regfile regfile(
    .rs_data(rs_data),
    .rt_data(mem_data_in),
    .rs_num(inst[25:21]),
    .rt_num(inst[20:16]),
    .rd_num(rd_num),
    .rd_data(rd_data),
    .rd_we(reg_write),
    .clk(clk),
    .rst_b(rst_b),
    .halted(halted)
);    



CONTROLL controll(.clk(clk)
,.inst(inst[31:26])
,.func(inst[5:0])
,.reg_dst(reg_dst)
,.jump(jump)
,.branch(branch)
,.mem_read(mem_read)
,.mem_write_en(mem_write_en)
,.mem_to_reg(mem_to_reg)
,.alu_op(alu_op)
,.alu_src(alu_src)
,.reg_write(reg_write)
);


always_ff @(posedge clk,negedge rst_b) begin
    if(rst_b == 0) begin
        inst_addr <= 1;
        halted <= 0;
    end
    else begin
        inst_addr += 4;
    end
end



endmodule
