; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt -passes=newgvn -S < %s | FileCheck %s

%struct.t = type { ptr }

; The loaded address and the location of the address itself are not aliased,
; so the second reload is not necessary. Check that it can be eliminated.
define void @test1(ptr nocapture readonly %p, i32 %v) #0 {
; CHECK-LABEL: define void @test1(
; CHECK-SAME: ptr nocapture readonly [[P:%.*]], i32 [[V:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[P]], align 4, !tbaa [[TBAA0:![0-9]+]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP0]], align 4, !tbaa [[TBAA5:![0-9]+]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP0]], align 4, !tbaa [[TBAA5]]
; CHECK-NEXT:    ret void
;
entry:
  %0 = load ptr, ptr %p, align 4, !tbaa !1
  store volatile i32 %v, ptr %0, align 4, !tbaa !6
  %1 = load ptr, ptr %p, align 4, !tbaa !1
  store volatile i32 %v, ptr %1, align 4, !tbaa !6
  ret void
}

; The store via the loaded address may overwrite the address itself.
; Make sure that both loads remain.
define void @test2(ptr nocapture readonly %p, i32 %v) #0 {
; CHECK-LABEL: define void @test2(
; CHECK-SAME: ptr nocapture readonly [[P:%.*]], i32 [[V:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load ptr, ptr [[P]], align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP0]], align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    [[TMP1:%.*]] = load ptr, ptr [[P]], align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP1]], align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    ret void
;
entry:
  %0 = load ptr, ptr %p, align 4, !tbaa !1
  store volatile i32 %v, ptr %0, align 4, !tbaa !1
  %1 = load ptr, ptr %p, align 4, !tbaa !1
  store volatile i32 %v, ptr %1, align 4, !tbaa !1
  ret void
}

; The loads are ordered and non-monotonic. Although they are not aliased to
; the stores, make sure both are preserved.
define void @test3(ptr nocapture readonly %p, i32 %v) #0 {
; CHECK-LABEL: define void @test3(
; CHECK-SAME: ptr nocapture readonly [[P:%.*]], i32 [[V:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load atomic ptr, ptr [[P]] acquire, align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP0]], align 4, !tbaa [[TBAA5]]
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic ptr, ptr [[P]] acquire, align 4, !tbaa [[TBAA0]]
; CHECK-NEXT:    store volatile i32 [[V]], ptr [[TMP1]], align 4, !tbaa [[TBAA5]]
; CHECK-NEXT:    ret void
;
entry:
  %0 = load atomic ptr, ptr %p acquire, align 4, !tbaa !1
  store volatile i32 %v, ptr %0, align 4, !tbaa !6
  %1 = load atomic ptr, ptr %p acquire, align 4, !tbaa !1
  store volatile i32 %v, ptr %1, align 4, !tbaa !6
  ret void
}

attributes #0 = { norecurse nounwind }

!1 = !{!2, !3, i64 0}
!2 = !{!"", !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !4, i64 0}

;.
; CHECK: [[TBAA0]] = !{[[META1:![0-9]+]], [[META2:![0-9]+]], i64 0}
; CHECK: [[META1]] = !{!"", [[META2]], i64 0}
; CHECK: [[META2]] = !{!"any pointer", [[META3:![0-9]+]], i64 0}
; CHECK: [[META3]] = !{!"omnipotent char", [[META4:![0-9]+]], i64 0}
; CHECK: [[META4]] = !{!"Simple C/C++ TBAA"}
; CHECK: [[TBAA5]] = !{[[META6:![0-9]+]], [[META6]], i64 0}
; CHECK: [[META6]] = !{!"int", [[META3]], i64 0}
;.