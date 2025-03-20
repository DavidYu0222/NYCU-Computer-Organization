`timescale 1ns / 1ps
// <111550142>

/** [Reading] 4.4 p.318-321
 * "Designing the Main Control Unit"
 */
/** [Prerequisite] alu_control.v
 * This module is the Control unit in FIGURE 4.17
 * You can implement it by any style you want.
 */

/* checkout FIGURE 4.16/18 to understand each definition of control signals */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [?:?]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output [2:0] alu_op,      // ALUOp passed to ALU Control unit
    output       jump,
    output       lui
);
    
    /* implement "combinational" logic satisfying requirements in FIGURE 4.18 */
    /* You can check the "Green Card" to get the opcode/funct for each instruction. */
    
    /** [My annotation]
    I add jump and lui signal for jump and Load Immediate
    I expand alu_op from 2 bits to 3bits, and alu_op[2] is for ori
    
    jump = op: 000010, lui = op: 001111, ori = op: 001101
            reg_dst     alu_src     mem_to_reg  reg_write   mem_read    mem_write   branch      alu_op
    jump        x           x           x           x           x           x           x        xxx
    lui         0           1           0           1           0           0           0        000 (add)
    ori         0           1           0           1           0           0           0        100 (or)
    */
    
    wire R_format, lw, sw, beq;
    
    assign R_format = !(|opcode);
    assign lw =     opcode[5]  & (!opcode[4]) & (!opcode[3]) & (!opcode[2]) &   opcode[1]  &   opcode[0];
    assign sw =     opcode[5]  & (!opcode[4]) &   opcode[3]  & (!opcode[2]) &   opcode[1]  &   opcode[0];
    assign beq  = (!opcode[5]) & (!opcode[4]) & (!opcode[3]) &   opcode[2]  & (!opcode[1]) & (!opcode[0]);
    assign jump = (!opcode[5]) & (!opcode[4]) & (!opcode[3]) & (!opcode[2]) &   opcode[1]  & (!opcode[0]);
    assign lui  = (!opcode[5]) & (!opcode[4]) &   opcode[3]  &   opcode[2]  &   opcode[1]  &   opcode[0];
    assign ori  = (!opcode[5]) & (!opcode[4]) &   opcode[3]  &   opcode[2]  & (!opcode[1]) &   opcode[0];
    
    assign reg_dst    = R_format;
    assign alu_src    = lw | sw | lui | ori;
    assign mem_to_reg = lw;
    assign reg_write  = R_format | lw | lui | ori;
    assign mem_read   = lw;
    assign mem_write  = sw;
    assign branch     = beq;
    assign alu_op[2]  = ori;
    assign alu_op[1]  = R_format;
    assign alu_op[0]  = beq;
endmodule
