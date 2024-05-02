`include "/home/thomas/Documents/NTNU/VAR2024/tfe4205/ooo-design/src/issue-unit/issue-slot.sv"
`include "/home/thomas/Documents/NTNU/VAR2024/tfe4205/ooo-design/src/issue-unit/priority-encoder.sv"



module issue_queue 
    (
    input logic    clk, reset,
    
    // Inputs
    // From dispatch stage to issue queue
    input logic [6:0] opcode,
    input logic [4:0] src1_addr,
    input logic [4:0] src2_addr,
    input logic [4:0] dest_addr,
    input logic src1_ready,
    input logic src2_ready,
    input logic valid,


    // From execution stage to issue queue
    input logic wakeup_valid,
    input logic [4:0] wakeup_dest,

    // Control signals
    input logic flush,

    // Outputs
    // From issue queue to issue stage/instruction scheduler/age matrix
    output logic [1:0] request_mask,

    // From issue queue to execution stage/instruction scheduler
    output logic [6:0] opcode_out,
    output logic [4:0] src1_addr_out,
    output logic [4:0] src2_addr_out,
    output logic [4:0] dest_addr_out,

    // Issue queue to dispatch stage
    input test
    );
    // Declaration of variables
    logic row_pointer;
    // Sequential logic

    // Combinational logic

endmodule