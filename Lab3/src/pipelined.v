`timescale 1ns / 1ps
// <111550142>

/** [Prerequisite] Lab 2: alu, control, alu_control
 * This module is the pipelined MIPS processor in FIGURE 4.51
 * You can implement it by any style you want, as long as it passes testbench
 */

/* checkout FIGURE 4.51 */
module pipelined #(
    parameter integer TEXT_BYTES = 1024,        // size in bytes of instruction memory
    parameter integer TEXT_START = 'h00400000,  // start address of instruction memory
    parameter integer DATA_BYTES = 1024,        // size in bytes of data memory
    parameter integer DATA_START = 'h10008000   // start address of data memory
) (
    input clk,  // clock
    input rstn  // negative reset
);

    /* Instruction Memory */
    wire [31:0] instr_mem_address, instr_mem_instr;
    instr_mem #(
        .BYTES(TEXT_BYTES),
        .START(TEXT_START)
    ) instr_mem (
        .address(instr_mem_address),
        .instr  (instr_mem_instr)
    );

    /* Register Rile */
    wire [4:0] reg_file_read_reg_1, reg_file_read_reg_2, reg_file_write_reg;
    wire reg_file_reg_write;
    wire [31:0] reg_file_write_data, reg_file_read_data_1, reg_file_read_data_2;
    reg_file reg_file (
        .clk        (~clk),                  // only write when negative edge
        .rstn       (rstn),
        .read_reg_1 (reg_file_read_reg_1),
        .read_reg_2 (reg_file_read_reg_2),
        .reg_write  (reg_file_reg_write),
        .write_reg  (reg_file_write_reg),
        .write_data (reg_file_write_data),
        .read_data_1(reg_file_read_data_1),
        .read_data_2(reg_file_read_data_2)
    );

    /* ALU */
    wire [31:0] alu_a, alu_b, alu_result;
    wire [3:0] alu_ALU_ctl;
    wire alu_zero, alu_overflow;
    alu alu (
        .a       (alu_a),
        .b       (alu_b),
        .ALU_ctl (alu_ALU_ctl),
        .result  (alu_result),
        .zero    (alu_zero),
        .overflow(alu_overflow)
    );

    /* Data Memory */
    wire data_mem_mem_read, data_mem_mem_write;
    wire [31:0] data_mem_address, data_mem_write_data, data_mem_read_data;
    data_mem #(
        .BYTES(DATA_BYTES),
        .START(DATA_START)
    ) data_mem (
        .clk       (~clk),                 // only write when negative edge
        .mem_read  (data_mem_mem_read),
        .mem_write (data_mem_mem_write),
        .address   (data_mem_address),
        .write_data(data_mem_write_data),
        .read_data (data_mem_read_data)
    );

    /* ALU Control */
    wire [1:0] alu_control_alu_op;
    wire [5:0] alu_control_funct;
    wire [3:0] alu_control_operation;
    alu_control alu_control (
        .alu_op   (alu_control_alu_op),
        .funct    (alu_control_funct),
        .operation(alu_control_operation)
    );

    /* (Main) Control */
    wire [5:0] control_opcode;
    // Execution/address calculation stage control lines
    wire control_reg_dst, control_alu_src;
    wire [1:0] control_alu_op;
    // Memory access stage control lines
    wire control_branch, control_mem_read, control_mem_write, control_addi;
    // Wire-back stage control lines
    wire control_reg_write, control_mem_to_reg;
    control control (
        .opcode    (control_opcode),
        .reg_dst   (control_reg_dst),
        .alu_src   (control_alu_src),
        .mem_to_reg(control_mem_to_reg),
        .reg_write (control_reg_write),
        .mem_read  (control_mem_read),
        .mem_write (control_mem_write),
        .branch    (control_branch),
        .alu_op    (control_alu_op),
        .addi      (control_addi)
    );

    /** [step 1] Instruction fetch (IF)
     * 1. We need a register to store PC (acts like pipeline register).
     * 2. Wire pc to instruction memory.
     * 3. Implement an adder to calculate PC+4. (combinational)
     *    Hint: use "+" operator.
     * 4. Update IF/ID pipeline registers, and reset them @(negedge rstn)
     *    a. fetched instruction
     *    b. PC+4
     *    Hint: What else should be done when reset?
     *    Hint: Update of PC can be handle later in MEM stage.
     */
    // 1.
    reg [31:0] pc;  // DO NOT change this line
    // 2.
    assign instr_mem_address = pc;
    // 3.
    wire [31:0] pc_4 = pc + 4;
    // 4.
    reg [31:0] IF_ID_instr, IF_ID_pc_4;
    always @(posedge clk)
        if (rstn) begin
            IF_ID_instr <= instr_mem_instr;  // a.
            IF_ID_pc_4  <= pc_4;  // b.
        end
    always @(negedge rstn) begin
        IF_ID_instr <= 0;  // a.
        IF_ID_pc_4  <= 0;  // b.
    end

    /** [step 2] Instruction decode and register file read (ID)
     * From top to down in FIGURE 4.51: (instr. refers to the instruction from IF/ID)
     * 1. Generate control signals of the instr. (as Lab 2)
     * 2. Read desired registers (from register file) in the instr.
     * 3. Calculate sign-extended immediate from the instr.
     * 4. Update ID/EX pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB, MEM, EX)
     *    b. ??? (something from IF/ID)
     *    c. Data read from register file
     *    d. Sign-extended immediate
     *    e. ??? & ??? (WB stage needs to know which reg to write)
     */
    wire [31:0]sign_extend;
    assign control_opcode = IF_ID_instr[31:26];
    assign reg_file_read_reg_1 = IF_ID_instr[25:21];
    assign reg_file_read_reg_2 = IF_ID_instr[20:16];
    assign sign_extend = {{16{IF_ID_instr[15]}}, IF_ID_instr[15: 0]};
    
    reg ID_EX_addi;
    reg [1:0] ID_EX_alu_op;
    reg ID_EX_reg_dst, ID_EX_alu_src, ID_EX_branch, ID_EX_mem_write, ID_EX_mem_read, ID_EX_mem_to_reg, ID_EX_reg_write;
    reg [31:0] ID_EX_reg_file_read_data_1, ID_EX_reg_file_read_data_2, ID_EX_sign_extend, ID_EX_pc_4;
    reg [4:0] ID_EX_reg_file_write_reg1, ID_EX_reg_file_write_reg2;
    always @(posedge clk)
        if (rstn) begin
            ID_EX_reg_file_read_data_1 <= reg_file_read_data_1;
            ID_EX_reg_file_read_data_2 <= reg_file_read_data_2;
            ID_EX_sign_extend <= sign_extend;
            ID_EX_pc_4 <= IF_ID_pc_4;
            
            ID_EX_reg_file_write_reg1 <= IF_ID_instr[20:16];
            ID_EX_reg_file_write_reg2 <= IF_ID_instr[15:11];
            
            ID_EX_reg_dst <= control_reg_dst;
            ID_EX_alu_src <= control_alu_src;
            ID_EX_alu_op <= control_alu_op;
            ID_EX_branch <= control_branch;
            ID_EX_mem_write <= control_mem_write;
            ID_EX_mem_read <= control_mem_read;
            ID_EX_mem_to_reg <= control_mem_to_reg;
            ID_EX_reg_write <= control_reg_write;
            ID_EX_addi <= control_addi;
        end
    always @(negedge rstn) begin
        ID_EX_reg_file_read_data_1 <= 0;
        ID_EX_reg_file_read_data_2 <= 0;
        ID_EX_sign_extend <= 0;
        ID_EX_pc_4 <= 0;
        
        ID_EX_reg_file_write_reg1 <= 0;
        ID_EX_reg_file_write_reg2 <= 0;
        
        ID_EX_reg_dst <= 0;
        ID_EX_alu_src <= 0;
        ID_EX_alu_op <= 0;
        ID_EX_branch <= 0;
        ID_EX_mem_write <= 0;
        ID_EX_mem_read <= 0;
        ID_EX_mem_to_reg <= 0;
        ID_EX_reg_write <= 0;
        ID_EX_addi <= 0;
    end
    //assign alu_control_alu_op = alu_op;
    //assign alu_control_funct = instr_mem_instr[ 5: 0];
    /** [step 3] Execute or address calculation (EX)
     * From top to down in FIGURE 4.51
     * 1. Calculate branch target address from sign-extended immediate.
     * 2. Select correct operands of ALU like in Lab 2.
     * 3. Wire control signals to ALU control & ALU like in Lab 2.
     * 4. Select correct register to write.
     * 5. Update EX/MEM pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB, MEM)
     *    b. Branch target address
     *    c. ??? (What information dose MEM stage need to determine whether to branch?)
     *    d. ALU result
     *    e. ??? (What information does MEM stage need when executing Store?)
     *    f. ??? (WB stage needs to know which reg to write)
     */
    wire [31:0] branch_pc;
    wire [31:0] addi_result;
    assign branch_pc = {ID_EX_sign_extend[29:0], 2'b00} + ID_EX_pc_4;
    assign alu_control_alu_op = ID_EX_alu_op;
    assign alu_control_funct = ID_EX_sign_extend[5:0];
    assign alu_ALU_ctl = alu_control_operation;
    assign alu_a = ID_EX_reg_file_read_data_1;
    assign alu_b = (ID_EX_alu_src) ? ID_EX_sign_extend : ID_EX_reg_file_read_data_2;
    
    assign addi_result = ID_EX_sign_extend + ID_EX_reg_file_read_data_1;
    
    reg EX_MEM_zero, EX_MEM_branch, EX_MEM_mem_write, EX_MEM_mem_read, EX_MEM_mem_to_reg, EX_MEM_reg_write;
    reg [31:0] EX_MEM_alu_result, EX_MEM_data_mem_write_data, EX_MEM_branch_pc;
    reg [4:0] EX_MEM_reg_file_write_reg;
    always @(posedge clk)
        if (rstn) begin
            EX_MEM_alu_result <= (ID_EX_addi)? addi_result : alu_result;
            EX_MEM_data_mem_write_data <= ID_EX_reg_file_read_data_2;
            EX_MEM_branch_pc <= branch_pc;
            
            EX_MEM_reg_file_write_reg <= (ID_EX_reg_dst) ? ID_EX_reg_file_write_reg2 : ID_EX_reg_file_write_reg1;
            
            EX_MEM_zero <= alu_zero;
            EX_MEM_branch <= ID_EX_branch;
            EX_MEM_mem_write <= ID_EX_mem_write;
            EX_MEM_mem_read <= ID_EX_mem_read;
            EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
            EX_MEM_reg_write <= ID_EX_reg_write;
        end
    always @(negedge rstn) begin
        EX_MEM_alu_result <= 0;
        EX_MEM_data_mem_write_data <= 0;
        EX_MEM_branch_pc <= 0;
        
        EX_MEM_reg_file_write_reg <= 0;
        
        EX_MEM_zero <= 0;
        EX_MEM_branch <= 0;
        EX_MEM_mem_write <= 0;
        EX_MEM_mem_read <= 0;
        EX_MEM_mem_to_reg <= 0;
        EX_MEM_reg_write <= 0;
    end
    
    /** [step 4] Memory access (MEM)
     * From top to down in FIGURE 4.51
     * 1. Decide whether to branch or not.
     * 2. Wire address & data to write
     * 3. Wire control signal of read/write
     * 4. Update MEM/WB pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB)
     *    b. ???
     *    c. ???
     *    d. ???
     * 5. Update PC.
     */
    wire pc_src;
    assign pc_src = EX_MEM_zero & EX_MEM_branch;
    assign data_mem_address = EX_MEM_alu_result;
    assign data_mem_write_data = EX_MEM_data_mem_write_data;
    assign data_mem_mem_read = EX_MEM_mem_read;
    assign data_mem_mem_write = EX_MEM_mem_write;
    
    reg MEM_WB_mem_to_reg, MEM_WB_reg_write;
    reg [31:0] MEM_WB_alu_result, MEM_WB_data_mem_read_data;
    reg [4:0] MEM_WB_reg_file_write_reg;
    //reg[64:0] display = 0;
    always @(posedge clk)
        if (rstn) begin
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_data_mem_read_data <= data_mem_read_data;
            MEM_WB_reg_file_write_reg <= EX_MEM_reg_file_write_reg;
            
            MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
            MEM_WB_reg_write <= EX_MEM_reg_write;
            //display <= {ID_EX_reg_file_read_data_1, 1'bx, ID_EX_reg_file_read_data_2};
            
            if (pc_src) begin // 5.
                pc <= EX_MEM_branch_pc;
            end else begin
                pc <= pc_4;
            end 
        end
    always @(negedge rstn) begin
        MEM_WB_alu_result <= 0;
        MEM_WB_data_mem_read_data <= 0;
        MEM_WB_reg_file_write_reg <= 0;
        
        MEM_WB_mem_to_reg <= 0;
        MEM_WB_reg_write <= 0;
        
        pc <= 32'h00400000;
    end
    /** [step 5] Write-back (WB)
     * From top to down in FIGURE 4.51
     * 1. Wire RegWrite of register file.
     * 2. Select the data to write into register file.
     * 3. Select which register to write.
     */
    assign reg_file_write_data = (MEM_WB_mem_to_reg) ? MEM_WB_data_mem_read_data : MEM_WB_alu_result;
    assign reg_file_write_reg = MEM_WB_reg_file_write_reg;
    assign reg_file_reg_write = MEM_WB_reg_write;
    
endmodule  // pipelined
