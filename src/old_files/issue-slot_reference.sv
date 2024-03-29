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
    
    // Incoming micro-op
    input         io_in_uop_valid,
    input  [6:0]  io_in_uop_bits_uopc, // micro-op code
    input  [31:0] io_in_uop_bits_inst, // instruction bits
    // input  [2:0]  io_in_uop_bits_iq_code, // which IQ to send to
    // input  [9:0]  io_in_uop_bits_fu_code, // which FU to send to
    input  [1:0]  io_in_uop_iw_state, // type of micro-op, valid or not
    input         io_in_uop_bits_iw_p1_poisoned,
                  io_in_uop_bits_iw_p2_poisoned,
                  io_in_uop_bits_is_br,
                  io_in_uop_bits_is_jalr,
                  io_in_uop_bits_is_jal,
                  // io_in_uop_bits_is_sfb,

    input  [11:0] io_in_uop_bits_br_mask, // branch mask
    // input  [3:0]  io_in_uop_bits_br_tag, // branch tag
    // input  [4:0]  io_in_uop_bits_ftq_idx, // fetch target queue index
    // input  [5:0]  io_in_uop_bits_pc_lob, // low order bits of PC
    // input         io_in_uop_bits_taken, // branch taken bit
    // input  [19:0] io_in_uop_bits_imm_packed, // densely pack the imm in decode
    // input  [11:0] io_in_uop_bits_csr_addr, // used for critical path reasons in Exe
    // input  [5:0]  io_in_uop_bits_rob_idx, // ROB index
    // input  [3:0]  io_in_uop_bits_ldq_idx, // load queue index
                  // io_in_uop_bits_stq_idx, // store queue index
    // input  [1:0]  io_in_uop_bits_rxq_idx, // RoCC queue index
    input  [6:0]  io_in_uop_bits_pdst, // destination physical register
                  io_in_uop_bits_prs1, // source physical register 1
                  io_in_uop_bits_prs2, // source physical register 2
                  io_in_uop_bits_prs3, // source physical register 3
    input  [4:0]  io_in_uop_bits_ppred, // prediction bits
    input         io_in_uop_bits_prs1_busy, // source physical register 1 busy
                  io_in_uop_bits_prs2_busy,
                  io_in_uop_bits_prs3_busy,
                  io_in_uop_bits_ppred_busy,
    // input  [6:0]  io_in_uop_bits_stale_pdst, // stale physical destination
    input         io_in_uop_bits_exception,
    // input  [63:0] io_in_uop_bits_exc_cause,
    input         io_in_uop_bits_bypassable,
    // input  [4:0]  io_in_uop_bits_mem_cmd, // memory command
    // input  [1:0]  io_in_uop_bits_mem_size,
    input         io_in_uop_bits_mem_signed,
                  io_in_uop_bits_is_fence, // is fence, which is a memory barrier
                  io_in_uop_bits_is_fencei, // is fencei, which is an instruction barrier
                  // io_in_uop_bits_is_amo, // is atomic memory operation
                  // io_in_uop_bits_uses_ldq,
                  // io_in_uop_bits_uses_stq,
                  // io_in_uop_bits_is_sys_pc2epc, // is system instruction to change PC to EPC
                  // io_in_uop_bits_is_unique, // is unique micro-op
                  // io_in_uop_bits_flush_on_commit, // flush on commit
                  // io_in_uop_bits_ldst_is_rs1, // load/store is source register 1, otherwise 2
    
    // logical specifiers (only used in Decode->Rename), except rollback (ldst)
    // input  [5:0]  io_in_uop_bits_ldst,
                  // io_in_uop_bits_lrs1,
                  // io_in_uop_bits_lrs2,
                  // io_in_uop_bits_lrs3,
    input         io_in_uop_bits_ldst_val, // is there a desitonation? invalid for stores, rd == x0, etc
    input  [1:0]  io_in_uop_bits_dst_rtype, // destination register type
                  io_in_uop_bits_lrs1_rtype, // source register 1 type
                  io_in_uop_bits_lrs2_rtype, // source register 2 type
    input         io_in_uop_bits_frs3_en, // enable source register 3
                  io_in_uop_bits_fp_val,
                  io_in_uop_bits_fp_single,
                  io_in_uop_bits_xcpt_pf_if, // I-TLB page fault
                  io_in_uop_bits_xcpt_ae_if, // I$ access exception
                  io_in_uop_bits_xcpt_ma_if, // Misaligned fetch
                  io_in_uop_bits_bp_debug_if, // breakpoint
                  io_in_uop_bits_bp_xcpt_if, // breakpoint
                  input  [1:0]  
                  // What prediction structure provides the prediction FROM this op
                  io_in_uop_bits_debug_fsrc, 
                  // What prediction structure provides the prediction TO this op
                  io_in_uop_bits_debug_tsrc,
);
// Which input signals does issue-slot use from in_uop?
// valid, iw_p1_poisoned, iw_p2_poisoned, bits_slop_uop, bits_iw_state, bits_prs1_busy, bits_prs2_busy, bits_prs3_busy, bits_ppred_busy

// Which output signals does issue-slot use from out_uop?
//   io.out_uop            := slot_uop
//  io.out_uop.iw_state   := next_state
//  io.out_uop.uopc       := next_uopc
//  io.out_uop.lrs1_rtype := next_lrs1_rtype
//  io.out_uop.lrs2_rtype := next_lrs2_rtype
//  io.out_uop.br_mask    := next_br_mask
//  io.out_uop.prs1_busy  := !p1
//  io.out_uop.prs2_busy  := !p2
//  io.out_uop.prs3_busy  := !p3
//  io.out_uop.ppred_busy := !ppred
//  io.out_uop.iw_p1_poisoned := p1_poisoned
//  io.out_uop.iw_p2_poisoned := p2_poisoned

// Which inputs does issue-unit use from dis_uops
// uopc, lrs2_rtype, ppred_busy, valid, exception, is_fence, is_fencei, bits, ready

// Which signals from in_uop are used by issue-unit?
// valid, bits, 

// Which signals from out_uop are used by issue-unit?
// bits

// Which signals from iss_uops
// prs1, prs2, prs3, lrs1_rtype, lrs2_rtype, bits


endmodule

