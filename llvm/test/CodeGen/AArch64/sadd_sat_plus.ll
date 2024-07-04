; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-- | FileCheck %s --check-prefixes=CHECK,CHECK-SD
; RUN: llc < %s -mtriple=aarch64-- -global-isel -global-isel-abort=2 2>&1 | FileCheck %s --check-prefixes=CHECK,CHECK-GI

declare i4 @llvm.sadd.sat.i4(i4, i4)
declare i8 @llvm.sadd.sat.i8(i8, i8)
declare i16 @llvm.sadd.sat.i16(i16, i16)
declare i32 @llvm.sadd.sat.i32(i32, i32)
declare i64 @llvm.sadd.sat.i64(i64, i64)

define i32 @func32(i32 %x, i32 %y, i32 %z) nounwind {
; CHECK-SD-LABEL: func32:
; CHECK-SD:       // %bb.0:
; CHECK-SD-NEXT:    mul w8, w1, w2
; CHECK-SD-NEXT:    adds w8, w0, w8
; CHECK-SD-NEXT:    asr w9, w8, #31
; CHECK-SD-NEXT:    eor w9, w9, #0x80000000
; CHECK-SD-NEXT:    csel w0, w9, w8, vs
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: func32:
; CHECK-GI:       // %bb.0:
; CHECK-GI-NEXT:    mul w8, w1, w2
; CHECK-GI-NEXT:    mov w9, #-2147483648 // =0x80000000
; CHECK-GI-NEXT:    adds w8, w0, w8
; CHECK-GI-NEXT:    cset w10, vs
; CHECK-GI-NEXT:    add w9, w9, w8, asr #31
; CHECK-GI-NEXT:    tst w10, #0x1
; CHECK-GI-NEXT:    csel w0, w9, w8, ne
; CHECK-GI-NEXT:    ret
  %a = mul i32 %y, %z
  %tmp = call i32 @llvm.sadd.sat.i32(i32 %x, i32 %a)
  ret i32 %tmp
}

define i64 @func64(i64 %x, i64 %y, i64 %z) nounwind {
; CHECK-SD-LABEL: func64:
; CHECK-SD:       // %bb.0:
; CHECK-SD-NEXT:    adds x8, x0, x2
; CHECK-SD-NEXT:    asr x9, x8, #63
; CHECK-SD-NEXT:    eor x9, x9, #0x8000000000000000
; CHECK-SD-NEXT:    csel x0, x9, x8, vs
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: func64:
; CHECK-GI:       // %bb.0:
; CHECK-GI-NEXT:    mov x8, #-9223372036854775808 // =0x8000000000000000
; CHECK-GI-NEXT:    adds x9, x0, x2
; CHECK-GI-NEXT:    cset w10, vs
; CHECK-GI-NEXT:    add x8, x8, x9, asr #63
; CHECK-GI-NEXT:    tst w10, #0x1
; CHECK-GI-NEXT:    csel x0, x8, x9, ne
; CHECK-GI-NEXT:    ret
  %a = mul i64 %y, %z
  %tmp = call i64 @llvm.sadd.sat.i64(i64 %x, i64 %z)
  ret i64 %tmp
}

define i16 @func16(i16 %x, i16 %y, i16 %z) nounwind {
; CHECK-SD-LABEL: func16:
; CHECK-SD:       // %bb.0:
; CHECK-SD-NEXT:    mul w8, w1, w2
; CHECK-SD-NEXT:    sxth w9, w0
; CHECK-SD-NEXT:    add w8, w9, w8, sxth
; CHECK-SD-NEXT:    mov w9, #32767 // =0x7fff
; CHECK-SD-NEXT:    cmp w8, w9
; CHECK-SD-NEXT:    csel w8, w8, w9, lt
; CHECK-SD-NEXT:    mov w9, #-32768 // =0xffff8000
; CHECK-SD-NEXT:    cmn w8, #8, lsl #12 // =32768
; CHECK-SD-NEXT:    csel w0, w8, w9, gt
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: func16:
; CHECK-GI:       // %bb.0:
; CHECK-GI-NEXT:    mul w8, w1, w2
; CHECK-GI-NEXT:    sxth w8, w8
; CHECK-GI-NEXT:    add w8, w8, w0, sxth
; CHECK-GI-NEXT:    sxth w9, w8
; CHECK-GI-NEXT:    asr w10, w9, #15
; CHECK-GI-NEXT:    cmp w8, w9
; CHECK-GI-NEXT:    sub w10, w10, #8, lsl #12 // =32768
; CHECK-GI-NEXT:    csel w0, w10, w8, ne
; CHECK-GI-NEXT:    ret
  %a = mul i16 %y, %z
  %tmp = call i16 @llvm.sadd.sat.i16(i16 %x, i16 %a)
  ret i16 %tmp
}

define i8 @func8(i8 %x, i8 %y, i8 %z) nounwind {
; CHECK-SD-LABEL: func8:
; CHECK-SD:       // %bb.0:
; CHECK-SD-NEXT:    mul w8, w1, w2
; CHECK-SD-NEXT:    sxtb w9, w0
; CHECK-SD-NEXT:    add w8, w9, w8, sxtb
; CHECK-SD-NEXT:    mov w9, #127 // =0x7f
; CHECK-SD-NEXT:    cmp w8, #127
; CHECK-SD-NEXT:    csel w8, w8, w9, lt
; CHECK-SD-NEXT:    mov w9, #-128 // =0xffffff80
; CHECK-SD-NEXT:    cmn w8, #128
; CHECK-SD-NEXT:    csel w0, w8, w9, gt
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: func8:
; CHECK-GI:       // %bb.0:
; CHECK-GI-NEXT:    mul w8, w1, w2
; CHECK-GI-NEXT:    sxtb w8, w8
; CHECK-GI-NEXT:    add w8, w8, w0, sxtb
; CHECK-GI-NEXT:    sxtb w9, w8
; CHECK-GI-NEXT:    asr w10, w9, #7
; CHECK-GI-NEXT:    cmp w8, w9
; CHECK-GI-NEXT:    sub w10, w10, #128
; CHECK-GI-NEXT:    csel w0, w10, w8, ne
; CHECK-GI-NEXT:    ret
  %a = mul i8 %y, %z
  %tmp = call i8 @llvm.sadd.sat.i8(i8 %x, i8 %a)
  ret i8 %tmp
}

define i4 @func4(i4 %x, i4 %y, i4 %z) nounwind {
; CHECK-SD-LABEL: func4:
; CHECK-SD:       // %bb.0:
; CHECK-SD-NEXT:    mul w8, w1, w2
; CHECK-SD-NEXT:    sbfx w9, w0, #0, #4
; CHECK-SD-NEXT:    lsl w8, w8, #28
; CHECK-SD-NEXT:    add w8, w9, w8, asr #28
; CHECK-SD-NEXT:    mov w9, #7 // =0x7
; CHECK-SD-NEXT:    cmp w8, #7
; CHECK-SD-NEXT:    csel w8, w8, w9, lt
; CHECK-SD-NEXT:    mov w9, #-8 // =0xfffffff8
; CHECK-SD-NEXT:    cmn w8, #8
; CHECK-SD-NEXT:    csel w0, w8, w9, gt
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: func4:
; CHECK-GI:       // %bb.0:
; CHECK-GI-NEXT:    mul w8, w1, w2
; CHECK-GI-NEXT:    sbfx w9, w0, #0, #4
; CHECK-GI-NEXT:    sbfx w8, w8, #0, #4
; CHECK-GI-NEXT:    add w8, w9, w8
; CHECK-GI-NEXT:    sbfx w9, w8, #0, #4
; CHECK-GI-NEXT:    asr w10, w9, #3
; CHECK-GI-NEXT:    cmp w8, w9
; CHECK-GI-NEXT:    add w10, w10, #8
; CHECK-GI-NEXT:    csel w0, w10, w8, ne
; CHECK-GI-NEXT:    ret
  %a = mul i4 %y, %z
  %tmp = call i4 @llvm.sadd.sat.i4(i4 %x, i4 %a)
  ret i4 %tmp
}
;; NOTE: These prefixes are unused and the list is autogenerated. Do not add tests below this line:
; CHECK: {{.*}}