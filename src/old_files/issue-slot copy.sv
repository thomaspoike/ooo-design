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
    wakeup_port_if.consumer wakeup_ports [NUM_WAKEUP_PORTS],
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


endmodule

