`include "/home/thomas/Documents/NTNU/VAR2024/tfe4205/ooo-design/src/issue-unit/issue-slot.sv"

interface wakeup_port_if;
    logic valid;
    logic [6:0] bits_pdst;
    modport producer (output valid, output bits_pdst); // For writing to the interfacee
    modport consumer (input valid, input bits_pdst);   // For reading from the inteerface
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
    ) 
    (
    input       clk,
                reset,
    // dispatch, this entails wires for instruction to enter the issue queue
    // src_id1, p1, v1, src_id2, p2, v2, ctrl_info
    // need ready signal for whenever issue queue is full
    issue_slot_io.input_port dispatch_uops [DISPATCH_WIDTH-1:0] ,
    output logic ready,

    
    // issue, this entails wires for instruction to leave the issue queue
    // src_id1, p1, v1, src_id2, p2, v2, ctrl_info
    // also a valid vector for each 
    output [DISPATCH_WIDTH-1:0] issue_valids,
    issue_slot_io.output_port issue_uops [DISPATCH_WIDTH-1:0],
    // Wakeup ports,
    wakeup_port_if.producer wakeup_ports [NUM_WAKEUP_PORTS-1:0],

    // Input control (flush_pipelines)
    input flush_pipelines
    // TO-DO implement fu_types input for steering to exe-units
    );
    // setup signals for issue queue
    genvar i;
    
    // request, will_be_valid, valid, grant, kill, clear
    logic [NUM_ISSUE_SLOTS-1:0] request;
    reg [NUM_ISSUE_SLOTS-1:0] valid;
    // Set up the dispatch uops

    // --------------------------------------------
    // Issue Table
    generate
        for (i = 0; i < NUM_ISSUE_SLOTS; i++) begin : gen_issue_slot
            issue_slot #(
                .NUM_WAKEUP_PORTS(NUM_WAKEUP_PORTS)
            ) issue_slot_inst (
                .clk(clk),
                .reset(reset),
                // Example connections; replace with actual signals
                .io_request(/* your_signal_here */),
                .io_will_be_valid(/* your_signal_here */),
                .io_valid(/* your_signal_here */),
                .io_grant(/* your_signal_here */),
                .io_kill(/* your_signal_here */),
                .io_clear(/* your_signal_here */),
                .wakeup_ports(wakeup_ports),
                .wakeup_ports_valid(/* your_signal_here */),
                .wakeup_ports_bits_pdst(/* your_signal_here */),
                .io_in_uop(dispatch_uops[i]),
                .io_out_uop(issue_uops[i])
            );
        end
    endgenerate


    // --------------------------------------------
    // Figure which entries I can dispatch instructions
    
    // --------------------------------------------
    // Which entries will still be next cycle?

    // --------------------------------------------
    // Dispatch/Entry Logic
    // did we find a sport to slide new dispatched uops into
    
    // Checks if number of available is greater than width of dispatch.

    // --------------------------------------------
    // Issue select logic
    
endmodule