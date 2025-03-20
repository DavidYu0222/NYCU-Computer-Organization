`timescale 1ns / 1ps
// <your student id>

/** [Reading] 4.7 p.363-371
 * Understand when and how to forward
 */

/* checkout FIGURE 4.55 for definition of mux control signals */
/* checkout FIGURE 4.56/60 for how this unit should be connected */
module forwarding (
    input      [4:0] ID_EX_rs,          // inputs are pipeline registers relate to forwarding
    input      [4:0] ID_EX_rt,
    input            EX_MEM_reg_write,
    input      [4:0] EX_MEM_rd,
    input            MEM_WB_reg_write,
    input      [4:0] MEM_WB_rd,
    output     [1:0] forward_A,         // ALU operand is from: 00:ID/EX, 10: EX/MEM, 01:MEM/WB
    output     [1:0] forward_B
);
    /** [step 1] Forwarding
     * 1. EX hazard (p.366)
     * 2. MEM hazard (p.369)
     * 3. Solve potential data hazards between:
          the result of the instruction in the WB stage,
          the result of the instruction in the MEM stage,
          and the source operand of the instruction in the ALU stage.
          Hint: Be careful that the textbook is wrong here!
          Hint: Which of EX & MEM hazard has higher priority?
     */
    wire EX_MEM_hazard_rs;
    wire EX_MEM_hazard_rt;
    wire MEM_WB_hazard_rs;
    wire MEM_WB_hazard_rt;
    
    assign EX_MEM_hazard_rs = EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs);
    assign EX_MEM_hazard_rt = EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rt);
    
    assign MEM_WB_hazard_rs = MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs);
    assign MEM_WB_hazard_rt = MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rt);
    
    assign forward_A = EX_MEM_hazard_rs ? 2'b10 : (MEM_WB_hazard_rs ? 2'b01 : 2'b00); 
    assign forward_B = EX_MEM_hazard_rt ? 2'b10 : (MEM_WB_hazard_rt ? 2'b01 : 2'b00);

endmodule
