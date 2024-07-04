; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 3
; RUN: opt -S -passes=jump-threading < %s | FileCheck %s

declare void @set_value(ptr)

declare void @bar()

define void @foo(i1 %0) {
; CHECK-LABEL: define void @foo(
; CHECK-SAME: i1 [[TMP0:%.*]]) {
; CHECK-NEXT:  start:
; CHECK-NEXT:    [[V:%.*]] = alloca i64, align 8
; CHECK-NEXT:    call void @set_value(ptr [[V]])
; CHECK-NEXT:    [[L1:%.*]] = load i64, ptr [[V]], align 8
; CHECK-NEXT:    br i1 [[TMP0]], label [[BB0:%.*]], label [[BB2:%.*]]
; CHECK:       bb0:
; CHECK-NEXT:    [[C1:%.*]] = icmp eq i64 [[L1]], 0
; CHECK-NEXT:    br i1 [[C1]], label [[BB2_THREAD:%.*]], label [[BB2]]
; CHECK:       bb2.thread:
; CHECK-NEXT:    store i64 0, ptr [[V]], align 8
; CHECK-NEXT:    br label [[BB4:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    [[L2:%.*]] = phi i64 [ [[L1]], [[BB0]] ], [ [[L1]], [[START:%.*]] ]
; CHECK-NEXT:    [[TMP1:%.*]] = icmp eq i64 [[L2]], 2
; CHECK-NEXT:    br i1 [[TMP1]], label [[BB3:%.*]], label [[BB4]]
; CHECK:       bb3:
; CHECK-NEXT:    call void @bar()
; CHECK-NEXT:    ret void
; CHECK:       bb4:
; CHECK-NEXT:    ret void
;
start:
  %v = alloca i64, align 8
  call void @set_value(ptr %v)
  %l1 = load i64, ptr %v, align 8, !range !0
  br i1 %0, label %bb0, label %bb2

bb0:                                              ; preds = %start
  %c1 = icmp eq i64 %l1, 0
  br i1 %c1, label %bb1, label %bb2

bb1:                                              ; preds = %bb0
  store i64 0, ptr %v, align 8
  br label %bb2

bb2:                                              ; preds = %bb1, %bb0, %start
  %l2 = load i64, ptr %v, align 8
  %1 = icmp eq i64 %l2, 2
  br i1 %1, label %bb3, label %bb4

bb3:                                              ; preds = %bb2
  call void @bar()
  ret void

bb4:                                              ; preds = %bb2
  ret void
}

!0 = !{i64 0, i64 2}