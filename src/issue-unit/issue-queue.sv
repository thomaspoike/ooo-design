interface wakeup_port_if;
    logic valid;
    logic [6:0] bits_pdst;
    modport producer (output valid, output bits_pdst); // For writing to the interface
    modport consumer (input valid, input bits_pdst);   // For reading from the interface
endinterface

interface issue_slot_io;
    // 
    logic [6:0] src_id1;
    logic p1;
    logic v1;

    logic [6:0] src_id2;
    logic p2;
    logic v2;

    // Static info for the micro-op (type of required ALU, etc.)
    logic ctrl_info;
    

    // Incoming micro-op
    modport input_port (
        input src_id1, p1, v1, src_id2, p2, v2, ctrl_info
    );
    
    // Outgoing micro-op
    modport output_port (
        output src_id1, p1, v1, src_id2, p2, v2, ctrl_info
    );
endinterface

module issue_queue #(
    parameter DISPATCH_WIDTH = 2,
    parameter ISSUE_WIDTH = 2,
    parameter NUM_WAKEUP_PORTS = 2,
    parameter NUM_ISSUE_SLOTS = 8
) (
    input clk,
    input reset,
    

);
    
endmodule