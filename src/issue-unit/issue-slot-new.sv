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

module issue_slot #(
        parameter NUM_WAKEUP_PORTS = 2
    )
    (
    input       clk,
                reset,
    
    // Output control signals
    output logic     io_request,
                io_will_be_valid,
                io_valid,
    
    // Input control signals
    input  logic     io_grant,
                io_kill,
                io_clear,
    //______________________________
    // Wakeup ports interfacee array
    wakeup_port_if.consumer pins,
    wakeup_port_if wakeup_ports [NUM_WAKEUP_PORTS],
    input wakeup_ports_valid [NUM_WAKEUP_PORTS-1:0],
    input [6:0] wakeup_ports_bits_pdst [NUM_WAKEUP_PORTS-1:0],

    // Incoming micro-op
    issue_slot_io.input_port io_in_uop, // Incoming micro-op interface
    input [6:0] io_in_uop_src_id1, io_in_uop_src_id2,
    input io_in_uop_p1, io_in_uop_p2, io_in_uop_v1, io_in_uop_v2, io_in_uop_ctrl_info,

    // Outgoing micro-op
    issue_slot_io.output_port io_out_uop, // Outgoing micro-op interface

    // Current slots micro-op interfacee
    issue_slot_io.output_port io_oup  // Current slots micro-op interface
    );

    // Need registers for src_id1, P1, v1, src_id2, p2, v2, ctrl_info(Metadata, Dst, Uop, Bypassable, etc.)
    // Need combinational logic
    reg [NUM_WAKEUP_PORTS-1:0] wakeup_ports_src_id1;
    reg [NUM_WAKEUP_PORTS-1:0] wakeup_ports_src_id2;
    reg [6:0] src_id1, src_id2, src_id1_next, src_id2_next;
    reg p1, p2, p1_next, p2_next;
    reg v1, v2, v1_next, v2_next;
    reg ctrl_info, ctrl_info_next;


    // Sequential logic
    always_ff @( posedge clk or negedge reset ) begin : issue_slot_ff
        if (reset) begin
            src_id1 <= 7'b0;
            src_id2 <= 7'b0;
            p1 <= 1'b0;
            p2 <= 1'b0;
            v1 <= 1'b0;
            v2 <= 1'b0;
            ctrl_info <= 1'b0;
        end
        else begin
            src_id1 <= src_id1_next;
            src_id2 <= src_id2_next;
            p1 <= p1_next;
            p2 <= p2_next;
            v1 <= v1_next;
            v2 <= v2_next;
            ctrl_info <= ctrl_info_next;
        end
    end

    // Combinational logic
    // Request logic
    always_comb begin : request
        io_request = (p1 & p2 & v1 & v2 & !io_kill);
    end

    // Ready / p1_next / p2_next logic
    // Need to check if src_id1 is equal to any of the wakeup ports
    genvar i;
    generate;
        for (i = 0; i < NUM_WAKEUP_PORTS; i++) begin : p1_next_gen
            assign wakeup_ports_src_id1[i] = (wakeup_ports[i].valid) ? (src_id1 == wakeup_ports[i].bits_pdst) : 1'b0;

            assign wakeup_ports_src_id2[i] = (wakeup_ports[i].valid) ? (src_id2 == wakeup_ports[i].bits_pdst) : 1'b0;
        end
    endgenerate

    // p1_next / p2_next logic
    always_comb begin : p1_p2_next
        p1_next = |wakeup_ports_src_id1 || p1;
        p2_next = |wakeup_ports_src_id2 || p2;
    end

    // ctrl_info_next / src_id1_next / src_id2_next
    always_comb begin : combinational_logic
        if (io_in_uop.valid) begin
            ctrl_info_next = io_in_uop.ctrl_info;
            src_id1_next = io_in_uop.src_id1;
            src_id2_next = io_in_uop.src_id2;
        end
        else begin
            ctrl_info_next = ctrl_info;
            src_id1_next = src_id1;
            src_id2_next = src_id2;
        end
    end

    // 1_next / v2_next logic / 
    always_comb begin : valid
        // Valid is the same as the valid of the incoming micro-op
        // Keep valid from the incoming micro-op until the micro-op is issued
        if (io_grant) begin
            v1_next = 1'b0;
            v2_next = 1'b0;
            io_will_be_valid = 1'b0;
        end
        else begin
            v1_next = io_in_uop.v1 | v1;
            v2_next = io_in_uop.v2 | v2;
            io_will_be_valid = (v1_next | v2_next);
        end
    end

    // Output micro-op
    always_comb begin : output_micro_op
        io_out_uop.src_id1 = src_id1;
        io_out_uop.src_id2 = src_id2;
        io_out_uop.p1 = p1;
        io_out_uop.p2 = p2;
        io_out_uop.v1 = v1;
        io_out_uop.v2 = v2;
        io_out_uop.ctrl_info = ctrl_info;
    end



endmodule

