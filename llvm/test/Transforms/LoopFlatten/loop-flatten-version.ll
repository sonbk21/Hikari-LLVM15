; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt %s -S -passes='loop(loop-flatten),verify' -verify-loop-info -verify-dom-info -verify-scev -o - | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"

; We need to version the loop as the GEPs are not inbounds
define void @noinbounds_gep(i32 %N, ptr %A) {
; CHECK-LABEL: define void @noinbounds_gep(
; CHECK-SAME: i32 [[N:%.*]], ptr [[A:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP3:%.*]] = icmp ult i32 0, [[N]]
; CHECK-NEXT:    br i1 [[CMP3]], label [[FOR_INNER_PREHEADER_LVER_CHECK:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.inner.preheader.lver.check:
; CHECK-NEXT:    [[FLATTEN_MUL:%.*]] = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 [[N]], i32 [[N]])
; CHECK-NEXT:    [[FLATTEN_TRIPCOUNT:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 0
; CHECK-NEXT:    [[FLATTEN_OVERFLOW:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 1
; CHECK-NEXT:    br i1 [[FLATTEN_OVERFLOW]], label [[FOR_INNER_PREHEADER_PH_LVER_ORIG:%.*]], label [[FOR_INNER_PREHEADER_PH:%.*]]
; CHECK:       for.inner.preheader.ph.lver.orig:
; CHECK-NEXT:    br label [[FOR_INNER_PREHEADER_LVER_ORIG:%.*]]
; CHECK:       for.inner.preheader.lver.orig:
; CHECK-NEXT:    [[I_LVER_ORIG:%.*]] = phi i32 [ 0, [[FOR_INNER_PREHEADER_PH_LVER_ORIG]] ], [ [[INC2_LVER_ORIG:%.*]], [[FOR_OUTER_LVER_ORIG:%.*]] ]
; CHECK-NEXT:    br label [[FOR_INNER_LVER_ORIG:%.*]]
; CHECK:       for.inner.lver.orig:
; CHECK-NEXT:    [[J_LVER_ORIG:%.*]] = phi i32 [ 0, [[FOR_INNER_PREHEADER_LVER_ORIG]] ], [ [[INC1_LVER_ORIG:%.*]], [[FOR_INNER_LVER_ORIG]] ]
; CHECK-NEXT:    [[MUL_LVER_ORIG:%.*]] = mul i32 [[I_LVER_ORIG]], [[N]]
; CHECK-NEXT:    [[GEP_LVER_ORIG:%.*]] = getelementptr i32, ptr [[A]], i32 [[MUL_LVER_ORIG]]
; CHECK-NEXT:    [[ARRAYIDX_LVER_ORIG:%.*]] = getelementptr i32, ptr [[GEP_LVER_ORIG]], i32 [[J_LVER_ORIG]]
; CHECK-NEXT:    store i32 0, ptr [[ARRAYIDX_LVER_ORIG]], align 4
; CHECK-NEXT:    [[INC1_LVER_ORIG]] = add nuw i32 [[J_LVER_ORIG]], 1
; CHECK-NEXT:    [[CMP2_LVER_ORIG:%.*]] = icmp ult i32 [[INC1_LVER_ORIG]], [[N]]
; CHECK-NEXT:    br i1 [[CMP2_LVER_ORIG]], label [[FOR_INNER_LVER_ORIG]], label [[FOR_OUTER_LVER_ORIG]]
; CHECK:       for.outer.lver.orig:
; CHECK-NEXT:    [[INC2_LVER_ORIG]] = add i32 [[I_LVER_ORIG]], 1
; CHECK-NEXT:    [[CMP1_LVER_ORIG:%.*]] = icmp ult i32 [[INC2_LVER_ORIG]], [[N]]
; CHECK-NEXT:    br i1 [[CMP1_LVER_ORIG]], label [[FOR_INNER_PREHEADER_LVER_ORIG]], label [[FOR_END_LOOPEXIT_LOOPEXIT:%.*]]
; CHECK:       for.inner.preheader.ph:
; CHECK-NEXT:    br label [[FOR_INNER_PREHEADER:%.*]]
; CHECK:       for.inner.preheader:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[FOR_INNER_PREHEADER_PH]] ], [ [[INC2:%.*]], [[FOR_OUTER:%.*]] ]
; CHECK-NEXT:    [[FLATTEN_ARRAYIDX:%.*]] = getelementptr i32, ptr [[A]], i32 [[I]]
; CHECK-NEXT:    br label [[FOR_INNER:%.*]]
; CHECK:       for.inner:
; CHECK-NEXT:    [[J:%.*]] = phi i32 [ 0, [[FOR_INNER_PREHEADER]] ]
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[I]], [[N]]
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i32, ptr [[A]], i32 [[MUL]]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr i32, ptr [[GEP]], i32 [[J]]
; CHECK-NEXT:    store i32 0, ptr [[FLATTEN_ARRAYIDX]], align 4
; CHECK-NEXT:    [[INC1:%.*]] = add nuw i32 [[J]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult i32 [[INC1]], [[N]]
; CHECK-NEXT:    br label [[FOR_OUTER]]
; CHECK:       for.outer:
; CHECK-NEXT:    [[INC2]] = add i32 [[I]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ult i32 [[INC2]], [[FLATTEN_TRIPCOUNT]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_INNER_PREHEADER]], label [[FOR_END_LOOPEXIT_LOOPEXIT1:%.*]]
; CHECK:       for.end.loopexit.loopexit:
; CHECK-NEXT:    br label [[FOR_END_LOOPEXIT:%.*]]
; CHECK:       for.end.loopexit.loopexit1:
; CHECK-NEXT:    br label [[FOR_END_LOOPEXIT]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp3 = icmp ult i32 0, %N
  br i1 %cmp3, label %for.outer.preheader, label %for.end

for.outer.preheader:
  br label %for.inner.preheader

for.inner.preheader:
  %i = phi i32 [ 0, %for.outer.preheader ], [ %inc2, %for.outer ]
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.inner.preheader ], [ %inc1, %for.inner ]
  %mul = mul i32 %i, %N
  %gep = getelementptr i32, ptr %A, i32 %mul
  %arrayidx = getelementptr i32, ptr %gep, i32 %j
  store i32 0, ptr %arrayidx, align 4
  %inc1 = add nuw i32 %j, 1
  %cmp2 = icmp ult i32 %inc1, %N
  br i1 %cmp2, label %for.inner, label %for.outer

for.outer:
  %inc2 = add i32 %i, 1
  %cmp1 = icmp ult i32 %inc2, %N
  br i1 %cmp1, label %for.inner.preheader, label %for.end.loopexit

for.end.loopexit:
  br label %for.end

for.end:
  ret void
}

; We shouldn't version the loop here as the multiply would use an illegal type.
define void @noinbounds_gep_too_large_mul(i64 %N, ptr %A) {
; CHECK-LABEL: define void @noinbounds_gep_too_large_mul(
; CHECK-SAME: i64 [[N:%.*]], ptr [[A:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP3:%.*]] = icmp ult i64 0, [[N]]
; CHECK-NEXT:    br i1 [[CMP3]], label [[FOR_OUTER_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.outer.preheader:
; CHECK-NEXT:    br label [[FOR_INNER_PREHEADER:%.*]]
; CHECK:       for.inner.preheader:
; CHECK-NEXT:    [[I:%.*]] = phi i64 [ 0, [[FOR_OUTER_PREHEADER]] ], [ [[INC2:%.*]], [[FOR_OUTER:%.*]] ]
; CHECK-NEXT:    br label [[FOR_INNER:%.*]]
; CHECK:       for.inner:
; CHECK-NEXT:    [[J:%.*]] = phi i64 [ 0, [[FOR_INNER_PREHEADER]] ], [ [[INC1:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[MUL:%.*]] = mul i64 [[I]], [[N]]
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i32, ptr [[A]], i64 [[MUL]]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr i32, ptr [[GEP]], i64 [[J]]
; CHECK-NEXT:    store i32 0, ptr [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[INC1]] = add nuw i64 [[J]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult i64 [[INC1]], [[N]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[FOR_INNER]], label [[FOR_OUTER]]
; CHECK:       for.outer:
; CHECK-NEXT:    [[INC2]] = add i64 [[I]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp ult i64 [[INC2]], [[N]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR_INNER_PREHEADER]], label [[FOR_END_LOOPEXIT:%.*]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp3 = icmp ult i64 0, %N
  br i1 %cmp3, label %for.outer.preheader, label %for.end

for.outer.preheader:
  br label %for.inner.preheader

for.inner.preheader:
  %i = phi i64 [ 0, %for.outer.preheader ], [ %inc2, %for.outer ]
  br label %for.inner

for.inner:
  %j = phi i64 [ 0, %for.inner.preheader ], [ %inc1, %for.inner ]
  %mul = mul i64 %i, %N
  %gep = getelementptr i32, ptr %A, i64 %mul
  %arrayidx = getelementptr i32, ptr %gep, i64 %j
  store i32 0, ptr %arrayidx, align 4
  %inc1 = add nuw i64 %j, 1
  %cmp2 = icmp ult i64 %inc1, %N
  br i1 %cmp2, label %for.inner, label %for.outer

for.outer:
  %inc2 = add i64 %i, 1
  %cmp1 = icmp ult i64 %inc2, %N
  br i1 %cmp1, label %for.inner.preheader, label %for.end.loopexit

for.end.loopexit:
  br label %for.end

for.end:
  ret void
}

; A 3d loop corresponding to:
;
;   for (int k = 0; k < N; ++k)
;    for (int i = 0; i < N; ++i)
;      for (int j = 0; j < M; ++j)
;        f(&A[i*M+j]);
;
define void @d3_2(ptr %A, i32 %N, i32 %M) {
; CHECK-LABEL: define void @d3_2(
; CHECK-SAME: ptr [[A:%.*]], i32 [[N:%.*]], i32 [[M:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP30:%.*]] = icmp sgt i32 [[N]], 0
; CHECK-NEXT:    br i1 [[CMP30]], label [[FOR_COND1_PREHEADER_LR_PH:%.*]], label [[FOR_COND_CLEANUP:%.*]]
; CHECK:       for.cond1.preheader.lr.ph:
; CHECK-NEXT:    [[CMP625:%.*]] = icmp sgt i32 [[M]], 0
; CHECK-NEXT:    br label [[FOR_COND1_PREHEADER_US:%.*]]
; CHECK:       for.cond1.preheader.us:
; CHECK-NEXT:    [[K_031_US:%.*]] = phi i32 [ 0, [[FOR_COND1_PREHEADER_LR_PH]] ], [ [[INC13_US:%.*]], [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US:%.*]] ]
; CHECK-NEXT:    br i1 [[CMP625]], label [[FOR_COND5_PREHEADER_US_US_LVER_CHECK:%.*]], label [[FOR_COND5_PREHEADER_US43_PREHEADER:%.*]]
; CHECK:       for.cond5.preheader.us43.preheader:
; CHECK-NEXT:    br label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US_LOOPEXIT50:%.*]]
; CHECK:       for.cond5.preheader.us.us.lver.check:
; CHECK-NEXT:    [[FLATTEN_MUL:%.*]] = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 [[N]], i32 [[M]])
; CHECK-NEXT:    [[FLATTEN_TRIPCOUNT:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 0
; CHECK-NEXT:    [[FLATTEN_OVERFLOW:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 1
; CHECK-NEXT:    br i1 [[FLATTEN_OVERFLOW]], label [[FOR_COND5_PREHEADER_US_US_PH_LVER_ORIG:%.*]], label [[FOR_COND5_PREHEADER_US_US_PH:%.*]]
; CHECK:       for.cond5.preheader.us.us.ph.lver.orig:
; CHECK-NEXT:    br label [[FOR_COND5_PREHEADER_US_US_LVER_ORIG:%.*]]
; CHECK:       for.cond5.preheader.us.us.lver.orig:
; CHECK-NEXT:    [[I_028_US_US_LVER_ORIG:%.*]] = phi i32 [ [[INC10_US_US_LVER_ORIG:%.*]], [[FOR_COND5_FOR_COND_CLEANUP7_CRIT_EDGE_US_US_LVER_ORIG:%.*]] ], [ 0, [[FOR_COND5_PREHEADER_US_US_PH_LVER_ORIG]] ]
; CHECK-NEXT:    [[MUL_US_US_LVER_ORIG:%.*]] = mul nsw i32 [[I_028_US_US_LVER_ORIG]], [[M]]
; CHECK-NEXT:    br label [[FOR_BODY8_US_US_LVER_ORIG:%.*]]
; CHECK:       for.body8.us.us.lver.orig:
; CHECK-NEXT:    [[J_026_US_US_LVER_ORIG:%.*]] = phi i32 [ 0, [[FOR_COND5_PREHEADER_US_US_LVER_ORIG]] ], [ [[INC_US_US_LVER_ORIG:%.*]], [[FOR_BODY8_US_US_LVER_ORIG]] ]
; CHECK-NEXT:    [[ADD_US_US_LVER_ORIG:%.*]] = add nsw i32 [[J_026_US_US_LVER_ORIG]], [[MUL_US_US_LVER_ORIG]]
; CHECK-NEXT:    [[IDXPROM_US_US_LVER_ORIG:%.*]] = sext i32 [[ADD_US_US_LVER_ORIG]] to i64
; CHECK-NEXT:    [[ARRAYIDX_US_US_LVER_ORIG:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[IDXPROM_US_US_LVER_ORIG]]
; CHECK-NEXT:    tail call void @f(ptr [[ARRAYIDX_US_US_LVER_ORIG]])
; CHECK-NEXT:    [[INC_US_US_LVER_ORIG]] = add nuw nsw i32 [[J_026_US_US_LVER_ORIG]], 1
; CHECK-NEXT:    [[EXITCOND_LVER_ORIG:%.*]] = icmp ne i32 [[INC_US_US_LVER_ORIG]], [[M]]
; CHECK-NEXT:    br i1 [[EXITCOND_LVER_ORIG]], label [[FOR_BODY8_US_US_LVER_ORIG]], label [[FOR_COND5_FOR_COND_CLEANUP7_CRIT_EDGE_US_US_LVER_ORIG]]
; CHECK:       for.cond5.for.cond.cleanup7_crit_edge.us.us.lver.orig:
; CHECK-NEXT:    [[INC10_US_US_LVER_ORIG]] = add nuw nsw i32 [[I_028_US_US_LVER_ORIG]], 1
; CHECK-NEXT:    [[EXITCOND51_LVER_ORIG:%.*]] = icmp ne i32 [[INC10_US_US_LVER_ORIG]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND51_LVER_ORIG]], label [[FOR_COND5_PREHEADER_US_US_LVER_ORIG]], label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US_LOOPEXIT_LOOPEXIT:%.*]]
; CHECK:       for.cond5.preheader.us.us.ph:
; CHECK-NEXT:    br label [[FOR_COND5_PREHEADER_US_US:%.*]]
; CHECK:       for.cond1.for.cond.cleanup3_crit_edge.us.loopexit.loopexit:
; CHECK-NEXT:    br label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US_LOOPEXIT:%.*]]
; CHECK:       for.cond1.for.cond.cleanup3_crit_edge.us.loopexit.loopexit1:
; CHECK-NEXT:    br label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US_LOOPEXIT]]
; CHECK:       for.cond1.for.cond.cleanup3_crit_edge.us.loopexit:
; CHECK-NEXT:    br label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US]]
; CHECK:       for.cond1.for.cond.cleanup3_crit_edge.us.loopexit50:
; CHECK-NEXT:    br label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US]]
; CHECK:       for.cond1.for.cond.cleanup3_crit_edge.us:
; CHECK-NEXT:    [[INC13_US]] = add nuw nsw i32 [[K_031_US]], 1
; CHECK-NEXT:    [[EXITCOND52:%.*]] = icmp ne i32 [[INC13_US]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND52]], label [[FOR_COND1_PREHEADER_US]], label [[FOR_COND_CLEANUP_LOOPEXIT:%.*]]
; CHECK:       for.cond5.preheader.us.us:
; CHECK-NEXT:    [[I_028_US_US:%.*]] = phi i32 [ [[INC10_US_US:%.*]], [[FOR_COND5_FOR_COND_CLEANUP7_CRIT_EDGE_US_US:%.*]] ], [ 0, [[FOR_COND5_PREHEADER_US_US_PH]] ]
; CHECK-NEXT:    [[MUL_US_US:%.*]] = mul nsw i32 [[I_028_US_US]], [[M]]
; CHECK-NEXT:    br label [[FOR_BODY8_US_US:%.*]]
; CHECK:       for.cond5.for.cond.cleanup7_crit_edge.us.us:
; CHECK-NEXT:    [[INC10_US_US]] = add nuw nsw i32 [[I_028_US_US]], 1
; CHECK-NEXT:    [[EXITCOND51:%.*]] = icmp ne i32 [[INC10_US_US]], [[FLATTEN_TRIPCOUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND51]], label [[FOR_COND5_PREHEADER_US_US]], label [[FOR_COND1_FOR_COND_CLEANUP3_CRIT_EDGE_US_LOOPEXIT_LOOPEXIT1:%.*]]
; CHECK:       for.body8.us.us:
; CHECK-NEXT:    [[J_026_US_US:%.*]] = phi i32 [ 0, [[FOR_COND5_PREHEADER_US_US]] ]
; CHECK-NEXT:    [[ADD_US_US:%.*]] = add nsw i32 [[J_026_US_US]], [[MUL_US_US]]
; CHECK-NEXT:    [[IDXPROM_US_US:%.*]] = sext i32 [[I_028_US_US]] to i64
; CHECK-NEXT:    [[ARRAYIDX_US_US:%.*]] = getelementptr inbounds i32, ptr [[A]], i64 [[IDXPROM_US_US]]
; CHECK-NEXT:    tail call void @f(ptr [[ARRAYIDX_US_US]])
; CHECK-NEXT:    [[INC_US_US:%.*]] = add nuw nsw i32 [[J_026_US_US]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[INC_US_US]], [[M]]
; CHECK-NEXT:    br label [[FOR_COND5_FOR_COND_CLEANUP7_CRIT_EDGE_US_US]]
; CHECK:       for.cond.cleanup.loopexit:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
;
entry:
  %cmp30 = icmp sgt i32 %N, 0
  br i1 %cmp30, label %for.cond1.preheader.lr.ph, label %for.cond.cleanup

for.cond1.preheader.lr.ph:
  %cmp625 = icmp sgt i32 %M, 0
  br label %for.cond1.preheader.us

for.cond1.preheader.us:
  %k.031.us = phi i32 [ 0, %for.cond1.preheader.lr.ph ], [ %inc13.us, %for.cond1.for.cond.cleanup3_crit_edge.us ]
  br i1 %cmp625, label %for.cond5.preheader.us.us.preheader, label %for.cond5.preheader.us43.preheader

for.cond5.preheader.us43.preheader:
  br label %for.cond1.for.cond.cleanup3_crit_edge.us.loopexit50

for.cond5.preheader.us.us.preheader:
  br label %for.cond5.preheader.us.us

for.cond1.for.cond.cleanup3_crit_edge.us.loopexit:
  br label %for.cond1.for.cond.cleanup3_crit_edge.us

for.cond1.for.cond.cleanup3_crit_edge.us.loopexit50:
  br label %for.cond1.for.cond.cleanup3_crit_edge.us

for.cond1.for.cond.cleanup3_crit_edge.us:
  %inc13.us = add nuw nsw i32 %k.031.us, 1
  %exitcond52 = icmp ne i32 %inc13.us, %N
  br i1 %exitcond52, label %for.cond1.preheader.us, label %for.cond.cleanup.loopexit

for.cond5.preheader.us.us:
  %i.028.us.us = phi i32 [ %inc10.us.us, %for.cond5.for.cond.cleanup7_crit_edge.us.us ], [ 0, %for.cond5.preheader.us.us.preheader ]
  %mul.us.us = mul nsw i32 %i.028.us.us, %M
  br label %for.body8.us.us

for.cond5.for.cond.cleanup7_crit_edge.us.us:
  %inc10.us.us = add nuw nsw i32 %i.028.us.us, 1
  %exitcond51 = icmp ne i32 %inc10.us.us, %N
  br i1 %exitcond51, label %for.cond5.preheader.us.us, label %for.cond1.for.cond.cleanup3_crit_edge.us.loopexit

for.body8.us.us:
  %j.026.us.us = phi i32 [ 0, %for.cond5.preheader.us.us ], [ %inc.us.us, %for.body8.us.us ]
  %add.us.us = add nsw i32 %j.026.us.us, %mul.us.us
  %idxprom.us.us = sext i32 %add.us.us to i64
  %arrayidx.us.us = getelementptr inbounds i32, ptr %A, i64 %idxprom.us.us
  tail call void @f(ptr %arrayidx.us.us) #2
  %inc.us.us = add nuw nsw i32 %j.026.us.us, 1
  %exitcond = icmp ne i32 %inc.us.us, %M
  br i1 %exitcond, label %for.body8.us.us, label %for.cond5.for.cond.cleanup7_crit_edge.us.us

for.cond.cleanup.loopexit:
  br label %for.cond.cleanup

for.cond.cleanup:
  ret void
}

; GEP doesn't dominate the loop latch so we need to check if N*M will overflow.
@first = global i32 1, align 4
@a = external global [0 x i8], align 1
define void @overflow(i32 %lim, ptr %a) {
; CHECK-LABEL: define void @overflow(
; CHECK-SAME: i32 [[LIM:%.*]], ptr [[A:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP17_NOT:%.*]] = icmp eq i32 [[LIM]], 0
; CHECK-NEXT:    br i1 [[CMP17_NOT]], label [[FOR_COND_CLEANUP:%.*]], label [[FOR_COND1_PREHEADER_LVER_CHECK:%.*]]
; CHECK:       for.cond1.preheader.lver.check:
; CHECK-NEXT:    [[FLATTEN_MUL:%.*]] = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 [[LIM]], i32 100000)
; CHECK-NEXT:    [[FLATTEN_TRIPCOUNT:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 0
; CHECK-NEXT:    [[FLATTEN_OVERFLOW:%.*]] = extractvalue { i32, i1 } [[FLATTEN_MUL]], 1
; CHECK-NEXT:    br i1 [[FLATTEN_OVERFLOW]], label [[FOR_COND1_PREHEADER_PH_LVER_ORIG:%.*]], label [[FOR_COND1_PREHEADER_PH:%.*]]
; CHECK:       for.cond1.preheader.ph.lver.orig:
; CHECK-NEXT:    br label [[FOR_COND1_PREHEADER_LVER_ORIG:%.*]]
; CHECK:       for.cond1.preheader.lver.orig:
; CHECK-NEXT:    [[I_018_LVER_ORIG:%.*]] = phi i32 [ [[INC6_LVER_ORIG:%.*]], [[FOR_COND_CLEANUP3_LVER_ORIG:%.*]] ], [ 0, [[FOR_COND1_PREHEADER_PH_LVER_ORIG]] ]
; CHECK-NEXT:    [[MUL_LVER_ORIG:%.*]] = mul i32 [[I_018_LVER_ORIG]], 100000
; CHECK-NEXT:    br label [[FOR_BODY4_LVER_ORIG:%.*]]
; CHECK:       for.body4.lver.orig:
; CHECK-NEXT:    [[J_016_LVER_ORIG:%.*]] = phi i32 [ 0, [[FOR_COND1_PREHEADER_LVER_ORIG]] ], [ [[INC_LVER_ORIG:%.*]], [[IF_END_LVER_ORIG:%.*]] ]
; CHECK-NEXT:    [[ADD_LVER_ORIG:%.*]] = add i32 [[J_016_LVER_ORIG]], [[MUL_LVER_ORIG]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, ptr @first, align 4
; CHECK-NEXT:    [[TOBOOL_NOT_LVER_ORIG:%.*]] = icmp eq i32 [[TMP0]], 0
; CHECK-NEXT:    br i1 [[TOBOOL_NOT_LVER_ORIG]], label [[IF_END_LVER_ORIG]], label [[IF_THEN_LVER_ORIG:%.*]]
; CHECK:       if.then.lver.orig:
; CHECK-NEXT:    [[ARRAYIDX_LVER_ORIG:%.*]] = getelementptr inbounds [0 x i8], ptr @a, i32 0, i32 [[ADD_LVER_ORIG]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i8, ptr [[ARRAYIDX_LVER_ORIG]], align 1
; CHECK-NEXT:    tail call void asm sideeffect "", "r"(i8 [[TMP1]])
; CHECK-NEXT:    store i32 0, ptr @first, align 4
; CHECK-NEXT:    br label [[IF_END_LVER_ORIG]]
; CHECK:       if.end.lver.orig:
; CHECK-NEXT:    tail call void asm sideeffect "", "r"(i32 [[ADD_LVER_ORIG]])
; CHECK-NEXT:    [[INC_LVER_ORIG]] = add nuw nsw i32 [[J_016_LVER_ORIG]], 1
; CHECK-NEXT:    [[CMP2_LVER_ORIG:%.*]] = icmp ult i32 [[J_016_LVER_ORIG]], 99999
; CHECK-NEXT:    br i1 [[CMP2_LVER_ORIG]], label [[FOR_BODY4_LVER_ORIG]], label [[FOR_COND_CLEANUP3_LVER_ORIG]]
; CHECK:       for.cond.cleanup3.lver.orig:
; CHECK-NEXT:    [[INC6_LVER_ORIG]] = add i32 [[I_018_LVER_ORIG]], 1
; CHECK-NEXT:    [[CMP_LVER_ORIG:%.*]] = icmp ult i32 [[INC6_LVER_ORIG]], [[LIM]]
; CHECK-NEXT:    br i1 [[CMP_LVER_ORIG]], label [[FOR_COND1_PREHEADER_LVER_ORIG]], label [[FOR_COND_CLEANUP_LOOPEXIT_LOOPEXIT:%.*]]
; CHECK:       for.cond1.preheader.ph:
; CHECK-NEXT:    br label [[FOR_COND1_PREHEADER:%.*]]
; CHECK:       for.cond1.preheader:
; CHECK-NEXT:    [[I_018:%.*]] = phi i32 [ [[INC6:%.*]], [[FOR_COND_CLEANUP3:%.*]] ], [ 0, [[FOR_COND1_PREHEADER_PH]] ]
; CHECK-NEXT:    [[MUL:%.*]] = mul i32 [[I_018]], 100000
; CHECK-NEXT:    br label [[FOR_BODY4:%.*]]
; CHECK:       for.cond.cleanup.loopexit.loopexit:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP_LOOPEXIT:%.*]]
; CHECK:       for.cond.cleanup.loopexit.loopexit1:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP_LOOPEXIT]]
; CHECK:       for.cond.cleanup.loopexit:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.cond.cleanup3:
; CHECK-NEXT:    [[INC6]] = add i32 [[I_018]], 1
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 [[INC6]], [[FLATTEN_TRIPCOUNT]]
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_COND1_PREHEADER]], label [[FOR_COND_CLEANUP_LOOPEXIT_LOOPEXIT1:%.*]]
; CHECK:       for.body4:
; CHECK-NEXT:    [[J_016:%.*]] = phi i32 [ 0, [[FOR_COND1_PREHEADER]] ]
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[J_016]], [[MUL]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr @first, align 4
; CHECK-NEXT:    [[TOBOOL_NOT:%.*]] = icmp eq i32 [[TMP2]], 0
; CHECK-NEXT:    br i1 [[TOBOOL_NOT]], label [[IF_END:%.*]], label [[IF_THEN:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [0 x i8], ptr @a, i32 0, i32 [[I_018]]
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, ptr [[ARRAYIDX]], align 1
; CHECK-NEXT:    tail call void asm sideeffect "", "r"(i8 [[TMP3]])
; CHECK-NEXT:    store i32 0, ptr @first, align 4
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    tail call void asm sideeffect "", "r"(i32 [[I_018]])
; CHECK-NEXT:    [[INC:%.*]] = add nuw nsw i32 [[J_016]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult i32 [[J_016]], 99999
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP3]]
;
entry:
  %cmp17.not = icmp eq i32 %lim, 0
  br i1 %cmp17.not, label %for.cond.cleanup, label %for.cond1.preheader.preheader

for.cond1.preheader.preheader:
  br label %for.cond1.preheader

for.cond1.preheader:
  %i.018 = phi i32 [ %inc6, %for.cond.cleanup3 ], [ 0, %for.cond1.preheader.preheader ]
  %mul = mul i32 %i.018, 100000
  br label %for.body4

for.cond.cleanup.loopexit:
  br label %for.cond.cleanup

for.cond.cleanup:
  ret void

for.cond.cleanup3:
  %inc6 = add i32 %i.018, 1
  %cmp = icmp ult i32 %inc6, %lim
  br i1 %cmp, label %for.cond1.preheader, label %for.cond.cleanup.loopexit

for.body4:
  %j.016 = phi i32 [ 0, %for.cond1.preheader ], [ %inc, %if.end ]
  %add = add i32 %j.016, %mul
  %0 = load i32, ptr @first, align 4
  %tobool.not = icmp eq i32 %0, 0
  br i1 %tobool.not, label %if.end, label %if.then

if.then:
  %arrayidx = getelementptr inbounds [0 x i8], ptr @a, i32 0, i32 %add
  %1 = load i8, ptr %arrayidx, align 1
  tail call void asm sideeffect "", "r"(i8 %1)
  store i32 0, ptr @first, align 4
  br label %if.end

if.end:
  tail call void asm sideeffect "", "r"(i32 %add)
  %inc = add nuw nsw i32 %j.016, 1
  %cmp2 = icmp ult i32 %j.016, 99999
  br i1 %cmp2, label %for.body4, label %for.cond.cleanup3
}

declare dso_local void @f(ptr)