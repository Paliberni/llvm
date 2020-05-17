; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -code-model=small -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I-SMALL
; RUN: llc -mtriple=riscv32 -mattr=+f -code-model=medium -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I-MEDIUM

; Check lowering of globals
@G = global i32 0

define i32 @lower_global(i32 %a) nounwind {
; RV32I-SMALL-LABEL: lower_global:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(G)
; RV32I-SMALL-NEXT:    lw a0, %lo(G)(a0)
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_global:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .LBB0_1: # Label of block must be emitted
; RV32I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(G)
; RV32I-MEDIUM-NEXT:    addi a0, a0, %pcrel_lo(.LBB0_1)
; RV32I-MEDIUM-NEXT:    lw a0, 0(a0)
; RV32I-MEDIUM-NEXT:    ret
  %1 = load volatile i32, i32* @G
  ret i32 %1
}

; Check lowering of blockaddresses

@addr = global i8* null

define void @lower_blockaddress() nounwind {
; RV32I-SMALL-LABEL: lower_blockaddress:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a0, %hi(addr)
; RV32I-SMALL-NEXT:    addi a1, zero, 1
; RV32I-SMALL-NEXT:    sw a1, %lo(addr)(a0)
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_blockaddress:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .LBB1_1: # Label of block must be emitted
; RV32I-MEDIUM-NEXT:    auipc a0, %pcrel_hi(addr)
; RV32I-MEDIUM-NEXT:    addi a0, a0, %pcrel_lo(.LBB1_1)
; RV32I-MEDIUM-NEXT:    addi a1, zero, 1
; RV32I-MEDIUM-NEXT:    sw a1, 0(a0)
; RV32I-MEDIUM-NEXT:    ret
  store volatile i8* blockaddress(@lower_blockaddress, %block), i8** @addr
  ret void

block:
  unreachable
}

; Check lowering of blockaddress that forces a displacement to be added

define signext i32 @lower_blockaddress_displ(i32 signext %w) nounwind {
; RV32I-SMALL-LABEL: lower_blockaddress_displ:
; RV32I-SMALL:       # %bb.0: # %entry
; RV32I-SMALL-NEXT:    addi sp, sp, -16
; RV32I-SMALL-NEXT:    sw ra, 12(sp)
; RV32I-SMALL-NEXT:    lui a1, %hi(.Ltmp0)
; RV32I-SMALL-NEXT:    addi a1, a1, %lo(.Ltmp0)
; RV32I-SMALL-NEXT:    addi a2, zero, 101
; RV32I-SMALL-NEXT:    sw a1, 8(sp)
; RV32I-SMALL-NEXT:    blt a0, a2, .LBB2_3
; RV32I-SMALL-NEXT:  # %bb.1: # %if.then
; RV32I-SMALL-NEXT:    lw a0, 8(sp)
; RV32I-SMALL-NEXT:    jr a0
; RV32I-SMALL-NEXT:  .Ltmp0: # Block address taken
; RV32I-SMALL-NEXT:  .LBB2_2: # %return
; RV32I-SMALL-NEXT:    addi a0, zero, 4
; RV32I-SMALL-NEXT:    j .LBB2_4
; RV32I-SMALL-NEXT:  .LBB2_3: # %return.clone
; RV32I-SMALL-NEXT:    addi a0, zero, 3
; RV32I-SMALL-NEXT:  .LBB2_4: # %.split
; RV32I-SMALL-NEXT:    lw ra, 12(sp)
; RV32I-SMALL-NEXT:    addi sp, sp, 16
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_blockaddress_displ:
; RV32I-MEDIUM:       # %bb.0: # %entry
; RV32I-MEDIUM-NEXT:    addi sp, sp, -16
; RV32I-MEDIUM-NEXT:    sw ra, 12(sp)
; RV32I-MEDIUM-NEXT:  .LBB2_5: # %entry
; RV32I-MEDIUM-NEXT:    # Label of block must be emitted
; RV32I-MEDIUM-NEXT:    auipc a1, %pcrel_hi(.Ltmp0)
; RV32I-MEDIUM-NEXT:    addi a1, a1, %pcrel_lo(.LBB2_5)
; RV32I-MEDIUM-NEXT:    addi a2, zero, 101
; RV32I-MEDIUM-NEXT:    sw a1, 8(sp)
; RV32I-MEDIUM-NEXT:    blt a0, a2, .LBB2_3
; RV32I-MEDIUM-NEXT:  # %bb.1: # %if.then
; RV32I-MEDIUM-NEXT:    lw a0, 8(sp)
; RV32I-MEDIUM-NEXT:    jr a0
; RV32I-MEDIUM-NEXT:  .Ltmp0: # Block address taken
; RV32I-MEDIUM-NEXT:  .LBB2_2: # %return
; RV32I-MEDIUM-NEXT:    addi a0, zero, 4
; RV32I-MEDIUM-NEXT:    j .LBB2_4
; RV32I-MEDIUM-NEXT:  .LBB2_3: # %return.clone
; RV32I-MEDIUM-NEXT:    addi a0, zero, 3
; RV32I-MEDIUM-NEXT:  .LBB2_4: # %.split
; RV32I-MEDIUM-NEXT:    lw ra, 12(sp)
; RV32I-MEDIUM-NEXT:    addi sp, sp, 16
; RV32I-MEDIUM-NEXT:    ret
entry:
  %x = alloca i8*, align 8
  store i8* blockaddress(@lower_blockaddress_displ, %test_block), i8** %x, align 8
  %cmp = icmp sgt i32 %w, 100
  br i1 %cmp, label %if.then, label %if.end

if.then:
  %addr = load i8*, i8** %x, align 8
  br label %indirectgoto

if.end:
  br label %return

test_block:
  br label %return

return:
  %retval = phi i32 [ 3, %if.end ], [ 4, %test_block ]
  ret i32 %retval

indirectgoto:
  indirectbr i8* %addr, [ label %test_block ]
}

; Check lowering of constantpools

define float @lower_constantpool(float %a) nounwind {
; RV32I-SMALL-LABEL: lower_constantpool:
; RV32I-SMALL:       # %bb.0:
; RV32I-SMALL-NEXT:    lui a1, %hi(.LCPI3_0)
; RV32I-SMALL-NEXT:    flw ft0, %lo(.LCPI3_0)(a1)
; RV32I-SMALL-NEXT:    fmv.w.x ft1, a0
; RV32I-SMALL-NEXT:    fadd.s ft0, ft1, ft0
; RV32I-SMALL-NEXT:    fmv.x.w a0, ft0
; RV32I-SMALL-NEXT:    ret
;
; RV32I-MEDIUM-LABEL: lower_constantpool:
; RV32I-MEDIUM:       # %bb.0:
; RV32I-MEDIUM-NEXT:  .LBB3_1: # Label of block must be emitted
; RV32I-MEDIUM-NEXT:    auipc a1, %pcrel_hi(.LCPI3_0)
; RV32I-MEDIUM-NEXT:    addi a1, a1, %pcrel_lo(.LBB3_1)
; RV32I-MEDIUM-NEXT:    flw ft0, 0(a1)
; RV32I-MEDIUM-NEXT:    fmv.w.x ft1, a0
; RV32I-MEDIUM-NEXT:    fadd.s ft0, ft1, ft0
; RV32I-MEDIUM-NEXT:    fmv.x.w a0, ft0
; RV32I-MEDIUM-NEXT:    ret
  %1 = fadd float %a, 1.0
  ret float %1
}
