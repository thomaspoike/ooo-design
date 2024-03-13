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
    input         io_in_uop_valid,
    input  [6:0]  io_in_uop_bits_uopc, // micro-op code
    input  [31:0] io_in_uop_bits_inst, // instruction bits
    input  [1:0]  io_in_uop_iw_state, // type of micro-op, valid or not
    input         io_in_uop_bits_iw_p1_poisoned,
                  io_in_uop_bits_iw_p2_poisoned,
                  io_in_uop_bits_is_br,
                  io_in_uop_bits_is_jalr,
                  io_in_uop_bits_is_jal,
                  // io_in_uop_bits_is_sfb,

    input  [11:0] io_in_uop_bits_br_mask, // branch mask
    input  [6:0]  io_in_uop_bits_pdst, // destination physical register
                  io_in_uop_bits_prs1, // source physical register 1
                  io_in_uop_bits_prs2, // source physical register 2
    input  [4:0]  io_in_uop_bits_ppred, // prediction bits
    input         io_in_uop_bits_prs1_busy, // source physical register 1 busy
                  io_in_uop_bits_prs2_busy,
                  io_in_uop_bits_ppred_busy,

    input         io_in_uop_bits_bypassable,
    input         io_in_uop_bits_ldst_val, // is there a desitonation? invalid for stores, rd == x0, etc
    input  [1:0]  io_in_uop_bits_dst_rtype, // destination register type
                  io_in_uop_bits_lrs1_rtype, // source register 1 type
                  io_in_uop_bits_lrs2_rtype
                     // source register 2 type
    
    //_________________________________
    // Output micro-op
    output         io_out_uop_valid,
    output  [6:0]  io_out_uop_bits_uopc, // micro-op code
    output  [31:0] io_out_uop_bits_inst, // instruction bits
    output  [1:0]  io_out_uop_iw_state, // type of micro-op, valid or not
    output         io_out_uop_bits_iw_p1_poisoned,
                  io_out_uop_bits_iw_p2_poisoned,
                  io_out_uop_bits_is_br,
                  io_out_uop_bits_is_jalr,
                  io_out_uop_bits_is_jal,

    output  [11:0] io_out_uop_bits_br_mask, // branch mask
    output  [6:0]  io_out_uop_bits_pdst, // destination physical register
                  io_out_uop_bits_prs1, // source physical register 1
                  io_out_uop_bits_prs2, // source physical register 2
    output  [4:0]  io_out_uop_bits_ppred, // prediction bits
    output         io_out_uop_bits_prs1_busy, // source physical register 1 busy
                  io_out_uop_bits_prs2_busy,
                  io_out_uop_bits_ppred_busy,

    output         io_out_uop_bits_bypassable,
    output         io_out_uop_bits_ldst_val, // is there a desitonation? invalid for stores, rd == x0, etc
    output  [1:0]  io_out_uop_bits_dst_rtype, // destination register type
                  io_out_uop_bits_lrs1_rtype, // source register 1 type
                  io_out_uop_bits_lrs2_rtype
                     // source register 2 type

    //_________________________________
    // Current slots uop
    output         io_oup_valid,
    output  [6:0]  io_oup_bits_uopc, // micro-op code
    output  [31:0] io_oup_bits_inst, // instruction bits
    output  [1:0]  io_oup_iw_state, // type of micro-op, valid or not
    output         io_oup_bits_iw_p1_poisoned,
                  io_oup_bits_iw_p2_poisoned,
                  io_oup_bits_is_br,
                  io_oup_bits_is_jalr,
                  io_oup_bits_is_jal,

    output  [11:0] io_oup_bits_br_mask, // branch mask
    output  [6:0]  io_oup_bits_pdst, // destination physical register
                  io_oup_bits_prs1, // source physical register 1
                  io_oup_bits_prs2, // source physical register 2
    output  [4:0]  io_oup_bits_ppred, // prediction bits
    output         io_oup_bits_prs1_busy, // source physical register 1 busy
                  io_oup_bits_prs2_busy,
                  io_oup_bits_ppred_busy,

    output         io_oup_bits_bypassable,
    output         io_oup_bits_ldst_val, // is there a desitonation? invalid for stores, rd == x0, etc
    output  [1:0]  io_oup_bits_dst_rtype, // destination register type
                  io_oup_bits_lrs1_rtype, // source register 1 type
                  io_oup_bits_lrs2_rtype
                     // source register 2 type
);

// slot invalid?
// slot is valid, holding 1 uop
// slot is valid, holding 2 uops
localparam s_invalid = 2b'00;
localparam s_valid_1 = 2b'01;
localparam s_valid_2 = 2b'10;
wire is_valid, is_invalid;
assign is_invalid = (state == s_invalid);
assign is_valid = (state != s_invalid);


// need to create flip-flop for state, p1, p2, ppred, slot_uop
reg [1:0] state, next_state;
reg p1, next_p1;
reg p2, next_p2;
reg ppred, next_ppred;
reg [31:0] slot_uop, next_slot_uop; // Storing the instruction bits
reg bypassable, next_bypassable;



endmodule

