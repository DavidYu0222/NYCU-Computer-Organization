`timescale 1ns / 1ps
// <your student id>

/** [Reading] 4.7 p.372-375
 * Understand when and how to detect stalling caused by data hazards.
 * When read a reg right after it was load from memory,
 * it is impossible to solve the hazard just by forwarding.
 */

/* checkout FIGURE 4.59 to understand why a stall is needed */
/* checkout FIGURE 4.60 for how this unit should be connected */
module hazard_detection (
    input        ID_EX_mem_read,
    input  [4:0] ID_EX_rt,
    input  [4:0] IF_ID_rs,
    input  [4:0] IF_ID_rt,
    output       pc_write,        // only update PC when this is set
    output       IF_ID_write,     // only update IF/ID stage registers when this is set
    output       stall            // insert a stall (bubble) in ID/EX when this is set
);

    /** [step 3] Stalling
     * 1. calculate stall by equation from textbook.
     * 2. Should pc be written when stall?
     * 3. Should IF/ID stage registers be updated when stall?
     */
    assign pc_write    = ~(ID_EX_mem_read && ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt)));
    assign IF_ID_write = ~(ID_EX_mem_read && ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt)));
    assign stall       =  (ID_EX_mem_read && ((ID_EX_rt == IF_ID_rs) || (ID_EX_rt == IF_ID_rt)));

endmodule
