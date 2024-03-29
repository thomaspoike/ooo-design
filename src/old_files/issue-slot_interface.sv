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
