`timescale 1ns / 1ps
// <111550142>

/* checkout FIGURE C.5.12 */
/** [Prerequisite] complete bit_alu.v & msb_alu.v
 * We recommend you to design a 32-bit ALU with 1-bit ALU.
 * However, you can still implement ALU with more advanced feature in Verilog.
 * Feel free to code as long as the I/O ports remain the same shape.
 */
module alu (
    input  [31:0] a,        // 32 bits, source 1 (A)
    input  [31:0] b,        // 32 bits, source 2 (B)
    input  [ 3:0] ALU_ctl,  // 4 bits, ALU control input
    output [31:0] result,   // 32 bits, result
    output        zero,     // 1 bit, set to 1 when the output is 0
    output        overflow  // 1 bit, overflow
);

    //wire [31:0] a_invert, b_negate;   //unnecessary wire
    wire [31:0] less, carry_in;
    wire [30:0] carry_out;
    wire [1:0] operation;
    wire        set;  // set of most significant bit

    bit_alu lsbs[30:0] (
        .a        (a[30:0]),
        .b        (b[30:0]),
        .less     (less[30:0]),
        .a_invert (ALU_ctl[3]),
        .b_invert (ALU_ctl[2]),
        .carry_in (carry_in[30:0]),
        .operation(operation),
        .result   (result[30:0]),
        .carry_out(carry_out)
    );

    msb_bit_alu msb (
        .a        (a[31]),
        .b        (b[31]),
        .less     (less[31]),
        .a_invert (ALU_ctl[3]),
        .b_invert (ALU_ctl[2]),
        .carry_in (carry_in[31]),
        .operation(operation),
        .result   (result[31]),
        .set      (set),
        .overflow (overflow)
    );

     //assign a_invert = (ALU_ctl[3])? 32'hFFFFFFFF: 0;
     //assign b_invert = (ALU_ctl[2])? 32'hFFFFFFFF: 0;
     assign less = {31'h0, set};
     assign carry_in = {carry_out, ALU_ctl[2]};
     assign operation =  ALU_ctl[1:0];
     assign zero = ~(|result[31:0]);
     
endmodule
