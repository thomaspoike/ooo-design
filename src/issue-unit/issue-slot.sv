// Each issue queue slot should contain the OpCode, addresses of up to two source operand registers, the destination register address, a valid bit, and ready flags for each source operand to indicate their availability.

// The inputs 
// From dispatch stage to issue stage:
// OpCode, source register addresses, destination register address, ready flags for each source operand, and the valid bit.

// Execution stage sends wake-up signals to the issue stage to indicate that the result of an instruction is ready. The wake-up signals are sent to the issue stage using the destination register address and a valid bit to indicate a valid wake up.

// From execute stage to issue stage:
// Valid bit, destination register address

// From instruction scheduler to issue stage:
// Grant

// The outputs
// From issue stage to execute stage:
// OpCode, source register addresses, destination register address

// From issue stage to priority encoder dispatch stage:
// Valid bit

// From issue stage to instruction scheduler:
// Request

module issue_slot
    (
    input logic clk, reset,
    
    // Output control signals

    //______________________________
    // Input control signals
    input logic kill,

    //______________________________
    // Wakeup ports interface array
    input logic wakeup_valid,
    input logic [4:0] wakeup_dest,

    //______________________________
    // Input micro-op
    input logic [6:0] opcode,
    input logic [4:0] src1_addr,
    input logic [4:0] src2_addr,
    input logic [4:0] dest_addr,
    input logic src1_ready,
    input logic src2_ready,
    input logic valid,
    
    //______________________________
    // Output micro-op
    output logic [6:0] opcode_out,
    output logic [4:0] src1_addr_out,
    output logic [4:0] src2_addr_out,
    output logic [4:0] dest_addr_out,
    output logic src1_ready_out,
    output logic src2_ready_out,
    output logic valid_out,

    //______________________________
    // Instruction scheduler signals
    input logic grant,
    output logic request,

    // Current slots micro-op interfacee
    output test
    );
    // Declaration of variables
    logic [6:0] opcode_reg, opcode_next;
    logic [4:0] src1_addr_reg, src1_addr_next;
    logic [4:0] src2_addr_reg, src2_addr_next;
    logic [4:0] dest_addr_reg, dest_addr_next;
    logic src1_ready_reg, src1_ready_next;
    logic src2_ready_reg, src2_ready_next;
    logic valid_reg, valid_next;

    // Sequential logic
    always_ff @(posedge clk or negedge reset or posedge kill) begin
        if (!reset || kill) begin
            opcode_reg <= 7'b0;
            src1_addr_reg <= 5'b0;
            src2_addr_reg <= 5'b0;
            dest_addr_reg <= 5'b0;
            src1_ready_reg <= 1'b0;
            src2_ready_reg <= 1'b0;
            valid_reg <= 1'b0;
        end
        else begin
            opcode_reg <= opcode_next;
            src1_addr_reg <= src1_addr_next;
            src2_addr_reg <= src2_addr_next;
            dest_addr_reg <= dest_addr_next;
            src1_ready_reg <= src1_ready_next;
            src2_ready_reg <= src2_ready_next;
            valid_reg <= valid_next;
        end
    end

    // Combinational logic
    always_comb begin
        opcode_next = opcode;
        src1_addr_next = src1_addr;
        src2_addr_next = src2_addr;
        dest_addr_next = dest_addr;
        src1_ready_next = src1_ready | src1_ready_reg;
        src2_ready_next = src2_ready | src2_ready_reg;
        valid_next = valid;

        // Wake up logic
        if (wakeup_valid == 1) begin
            if (wakeup_dest == src1_addr_reg) begin
                src1_ready_next = 1;
            end
            if (wakeup_dest == src2_addr_reg) begin
                src2_ready_next = 1;
            end
        end
    end
    

    // Request signal
    assign request = src1_ready_reg & src2_ready_reg & valid_reg & !kill;

    // Output micro-op
    assign opcode_out = opcode_reg;
    assign src1_addr_out = src1_addr_reg;
    assign src2_addr_out = src2_addr_reg;
    assign dest_addr_out = dest_addr_reg;
    assign src1_ready_out = src1_ready_reg;
    assign src2_ready_out = src2_ready_reg;
    assign valid_out = valid_reg;
endmodule

