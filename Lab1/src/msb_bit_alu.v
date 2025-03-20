`timescale 1ns / 1ps
// <your student id>

/* checkout FIGURE C.5.10 (Bottom) */
/* [Prerequisite] complete bit_alu.v */
module msb_bit_alu (
    input        a,          // 1 bit, a
    input        b,          // 1 bit, b
    input        less,       // 1 bit, Less
    input        a_invert,   // 1 bit, Ainvert
    input        b_invert,   // 1 bit, Binvert
    input        carry_in,   // 1 bit, CarryIn
    input  [1:0] operation,  // 2 bit, Operation
    output reg   result,     // 1 bit, Result (Must it be a reg?)
    output       set,        // 1 bit, Set
    output       overflow    // 1 bit, Overflow
);

    wire ai, bi;  
    assign ai = (a_invert)? ~a : a;  
    assign bi = (b_invert)? ~b : b;

    wire sum;
    assign carry_out = ai&bi | ((ai^bi) & carry_in);
    assign sum       = (ai ^ bi) ^ carry_in;
    
    //In slt operation, overflow is always 0
    assign overflow = (operation == 2'b11) ? 0 : carry_in ^ carry_out;  // The first way
    //assign overflow = (carry_in ^ carry_out) & !(&operation);         // The second way
    
    //There is two condition in SUB cause overflow: neg - pos and pos - neg, so the result of slt is a > b
    assign set = (carry_in ^ carry_out == 1)? a > b : sum;  
    
    always @(*) begin  
        case (operation) 
            2'b00:   result <= ai & bi;  // AND
            2'b01:   result <= ai | bi;  // OR
            2'b10:   result <= sum;  // ADD
            2'b11:   result <= less;// SLT
            default: result <= 0;  // should not happened
        endcase
    end
endmodule
