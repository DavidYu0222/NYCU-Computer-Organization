`timescale 1ns / 1ps
// <111550142>

/* Copy your Control (and its components) from Lab 2 */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [?:?]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output       addi,
    output [1:0] alu_op       // ALUOp passed to ALU Control unit
); 
    wire R_format, lw, sw, beq, addi;
    //addi 001000
    assign R_format = !(|opcode);
    assign lw =     opcode[5]  & (!opcode[4]) & (!opcode[3]) & (!opcode[2]) &   opcode[1]  &   opcode[0];
    assign sw =     opcode[5]  & (!opcode[4]) &   opcode[3]  & (!opcode[2]) &   opcode[1]  &   opcode[0];
    assign beq  = (!opcode[5]) & (!opcode[4]) & (!opcode[3]) &   opcode[2]  & (!opcode[1]) & (!opcode[0]);
    assign addi = (!opcode[5]) & (!opcode[4]) &   opcode[3]  & (!opcode[2]) & (!opcode[1]) & (!opcode[0]);
    
    assign reg_dst    = R_format;
    assign alu_src    = lw | sw;
    assign mem_to_reg = lw;
    assign reg_write  = R_format | lw | addi;
    assign mem_read   = lw;
    assign mem_write  = sw;
    assign branch     = beq;
    assign alu_op[1]  = R_format;
    assign alu_op[0]  = beq;
    
endmodule



    

