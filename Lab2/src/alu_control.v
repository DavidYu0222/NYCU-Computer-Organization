`timescale 1ns / 1ps
// <111550142>

/** [Reading] 4.4 p.316-318
 * "The ALU Control"
 */
/**
 * This module is the ALU control in FIGURE 4.17
 * You can implement it by any style you want.
 * There's a more hardware efficient design in Appendix D.
 */

/* checkout FIGURE 4.12/13 */
module alu_control (
    input  [2:0] alu_op,    // ALUOp
    input  [5:0] funct,     // Funct field
    output [3:0] operation  // Operation
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.12 */
    
    /** [My annotation]
    I expand alu_op from 2 bits to 3bits, and alu_op[2] is for ori
    100(ori) => 0001 (or);
    */
    assign operation[3] = 1'b0;
    assign operation[2] = (alu_op[1] & funct[1]) | alu_op[0] & !alu_op[2];
    assign operation[1] = !(alu_op[1] & funct[2]) & !alu_op[2];
    assign operation[0] = (funct[3] | funct[0]) & alu_op[1] | alu_op[2];
    
endmodule
