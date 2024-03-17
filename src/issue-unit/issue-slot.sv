interface uop_interface();

    // Signals
    logic         valid;
    logic [6:0]   bits_uopc; // micro-op code
    logic [31:0]  bits_inst; // instruction bits
    logic [1:0]   iw_state; // type of micro-op, valid or not
    logic         bits_iw_p1_poisoned, bits_iw_p2_poisoned, bits_is_br, bits_is_jalr, bits_is_jal, bits_is_fence, bits_is_fencei;
    logic [11:0]  bits_br_mask; // branch mask
    logic [6:0]   bits_pdst, bits_prs1, bits_prs2; // physical registers
    logic [4:0]   bits_ppred; // prediction bits
    logic         bits_prs1_busy, bits_prs2_busy, bits_ppred_busy;
    logic         bits_exception, bits_bypassable, bits_ldst_val;
    logic [1:0]   bits_dst_rtype, bits_lrs1_rtype, bits_lrs2_rtype; // register types

    // Modports
    modport input_port (
        input valid, bits_uopc, bits_inst, iw_state,
        input bits_iw_p1_poisoned, bits_iw_p2_poisoned, bits_is_br, bits_is_jalr, bits_is_jal, bits_is_fence, bits_is_fencei,
        input bits_br_mask, bits_pdst, bits_prs1, bits_prs2, bits_ppred, bits_prs1_busy, bits_prs2_busy, bits_ppred_busy,
        input bits_exception, bits_bypassable, bits_ldst_val, bits_dst_rtype, bits_lrs1_rtype, bits_lrs2_rtype
    );

    modport output_port (
        output valid, bits_uopc, bits_inst, iw_state,
        output bits_iw_p1_poisoned, bits_iw_p2_poisoned, bits_is_br, bits_is_jalr, bits_is_jal,
        output bits_br_mask, bits_pdst, bits_prs1, bits_prs2, bits_ppred, bits_prs1_busy, bits_prs2_busy, bits_ppred_busy,
        output bits_bypassable, bits_ldst_val, bits_dst_rtype, bits_lrs1_rtype, bits_lrs2_rtype
    );

endinterface

module issue_slot(
    input       clk,
                reset,
    
    // Output control signals
    output      io_valid,
                io_will_be_valid,
                io_request,
    
    // Input control signals
    input       io_grant,
                io_kill,
                io_clear,

    // Wakeup signals
    input       io_wakeup_ports_0_valid,
    input [6:0] io_wakeup_ports_0_bits_pdst,

    input       io_wakeup_ports_1_valid,
    input [6:0] io_wakeup_ports_1_bits_pdst,

    //_________________________________
    // Incoming micro-op
    uop_interface io_in_uop  (.input_port),  // Incoming micro-op interface
    uop_interface io_out_uop (.output_port), // Outgoing micro-op interface
    uop_interface io_oup     (.output_port)  // Current slots micro-op interface
    );

// slot invalid?
// slot is valid, holding 1 uop
// slot is valid, holding 2 uops
localparam s_invalid = 2b'00;
localparam s_valid_1 = 2b'01;
//localparam s_valid_2 = 2b'10;
wire is_valid, is_invalid;
assign is_invalid = (state == s_invalid);
assign is_valid = (state != s_invalid);


// need to create flip-flop for state, p1, p2, ppred, slot_uop, p1_poisoned, p2_poisoned, metadata
reg [1:0] state, next_state;
reg p1, next_p1;
reg p2, next_p2;
reg ppred, next_ppred;
reg [31:0] slot_uop, next_slot_uop;
reg bypassable, next_bypassable;
reg         p1_poisoned;
reg         p2_poisoned;

// Sequential logic
// State
always @(posedge clock ) begin : state_transition
    if (reset) begin
        state <= s_invalid;
    end else begin
        if (io_kill) begin
            state = s_invalid;
        end else if (io_in_uop.valid) begin
            state = io_in_uop_iw_state;
        end else if (io_clear) begin
            state = s_invalid;
        end else begin
            state = state;
        end;
    end
end

// Combined state transitions for p1, p2, ppred, slot_uop, p1_poisoned, and p2_poisoned
always @(posedge clock or reset) begin : combined_transitions
    if (reset) begin
        p1 <= 1'b0;
        p2 <= 1'b0;
        ppred <= 1'b0;
        slot_uop <= 32'b0;
        p1_poisoned <= 1'b0;
        p2_poisoned <= 1'b0;
    end else begin
        p1 <= next_p1;
        p2 <= next_p2;
        ppred <= next_ppred;
        slot_uop <= next_slot_uop;
        p1_poisoned <= next_p1_poisoned;
        p2_poisoned <= next_p2_poisoned;
    end
end




// Combinatorial logic
// poison combinatorial logic
wire        next_p1_poisoned = io_in_uop.valid ? io_in_uop_bits_iw_p1_poisoned : p1_poisoned;
wire        next_p2_poisoned = io_in_uop.valid ? io_in_uop_bits_iw_p2_poisoned : p2_poisoned;	

// next_state combinatorial logic
always_comb begin : next_state_comb
    next_state = state;
    if (io_kill) begin
        next_state = s_invalid;
    end else if (io_grant && state == s_valid_1) begin
        // Trying to issue
        next_state = s_invalid;
    end else if (io_clear) begin
        next_state = s_invalid;
    end else begin
        next_state = state;
    end
end

// next_slot_uop combinatorial logic
always_comb begin : next_slot_uop_comb
    next_slot_uop = slot_uop;
    if (io_in_uop.valid) begin
        next_slot_uop = io_in_uop.bits_inst;
    end else begin
        next_slot_uop = slot_uop;
    end
end


// next_p1 combinatorial logic should be true if wakeup_ports_0_valid and io_in_uop_bits_pdst match the wakeup_ports_0_bits_pdst
always_comb begin : next_p1_comb
    next_p1 = p1;
    if (io_wakeup_ports_0_valid && !io_out_uop_bits_prs2_busy && (io_in_uop_valid && io_in_uop_bits_pdst == io_wakeup_ports_0_bits_pdst)) begin
        next_p1 = 1'b1;
    end else begin
        next_p1 = 1'b0;
    end
end

// next_p2 combinatorial logic should be true if wakeup_ports_1_valid and io_in_uop_bits_pdst match the wakeup_ports_1_bits_pdst
always_comb begin : next_p2_comb
    next_p2 = p2;
    if (io_wakeup_ports_1_valid && !io_out_uop_bits_prs2_busy && (io_in_uop_valid && io_in_uop_bits_pdst == io_wakeup_ports_1_bits_pdst)) begin
        next_p2 = 1'b1;
    end else begin
        next_p2 = 1'b0;
    end
end

// output signals
assign io_request = is_valid && p1 && p2 && !io_kill;


endmodule

