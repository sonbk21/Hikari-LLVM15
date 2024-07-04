; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S < %s | FileCheck %s

declare <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptrs, i32, <2 x i1> %mask, <2 x double> %src0)
declare void @llvm.masked.store.v2f64.p0(<2 x double> %val, ptr %ptrs, i32, <2 x i1> %mask)
declare <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32, <2 x i1> %mask, <2 x double> %passthru)
declare <4 x double> @llvm.masked.gather.v4f64.v4p0(<4 x ptr> %ptrs, i32, <4 x i1> %mask, <4 x double> %passthru)
declare void @llvm.masked.scatter.v2f64.v2p0(<2 x double> %val, <2 x ptr> %ptrs, i32, <2 x i1> %mask)

define <2 x double> @load_zeromask(ptr %ptr, <2 x double> %passthru)  {
; CHECK-LABEL: @load_zeromask(
; CHECK-NEXT:    ret <2 x double> [[PASSTHRU:%.*]]
;
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 1, <2 x i1> zeroinitializer, <2 x double> %passthru)
  ret <2 x double> %res
}

define <2 x double> @load_onemask(ptr %ptr, <2 x double> %passthru)  {
; CHECK-LABEL: @load_onemask(
; CHECK-NEXT:    [[UNMASKEDLOAD:%.*]] = load <2 x double>, ptr [[PTR:%.*]], align 2
; CHECK-NEXT:    ret <2 x double> [[UNMASKEDLOAD]]
;
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 2, <2 x i1> <i1 1, i1 1>, <2 x double> %passthru)
  ret <2 x double> %res
}

define <2 x double> @load_undefmask(ptr %ptr, <2 x double> %passthru)  {
; CHECK-LABEL: @load_undefmask(
; CHECK-NEXT:    [[UNMASKEDLOAD:%.*]] = load <2 x double>, ptr [[PTR:%.*]], align 2
; CHECK-NEXT:    ret <2 x double> [[UNMASKEDLOAD]]
;
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 2, <2 x i1> <i1 1, i1 undef>, <2 x double> %passthru)
  ret <2 x double> %res
}

@G = external global i8

define <2 x double> @load_cemask(ptr %ptr, <2 x double> %passthru)  {
; CHECK-LABEL: @load_cemask(
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0(ptr [[PTR:%.*]], i32 2, <2 x i1> <i1 true, i1 ptrtoint (ptr @G to i1)>, <2 x double> [[PASSTHRU:%.*]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 2, <2 x i1> <i1 1, i1 ptrtoint (ptr @G to i1)>, <2 x double> %passthru)
  ret <2 x double> %res
}

define <2 x double> @load_lane0(ptr %ptr, double %pt)  {
; CHECK-LABEL: @load_lane0(
; CHECK-NEXT:    [[PTV2:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 1
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0(ptr [[PTR:%.*]], i32 2, <2 x i1> <i1 true, i1 false>, <2 x double> [[PTV2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 2, <2 x i1> <i1 true, i1 false>, <2 x double> %ptv2)
  ret <2 x double> %res
}

define double @load_all(ptr %base, double %pt)  {
; CHECK-LABEL: @load_all(
; CHECK-NEXT:    [[PTRS:%.*]] = getelementptr double, ptr [[BASE:%.*]], <4 x i64> <i64 0, i64 poison, i64 2, i64 3>
; CHECK-NEXT:    [[RES:%.*]] = call <4 x double> @llvm.masked.gather.v4f64.v4p0(<4 x ptr> [[PTRS]], i32 4, <4 x i1> <i1 true, i1 false, i1 true, i1 true>, <4 x double> poison)
; CHECK-NEXT:    [[ELT:%.*]] = extractelement <4 x double> [[RES]], i64 2
; CHECK-NEXT:    ret double [[ELT]]
;
  %ptrs = getelementptr double, ptr %base, <4 x i64> <i64 0, i64 1, i64 2, i64 3>
  %res = call <4 x double> @llvm.masked.gather.v4f64.v4p0(<4 x ptr> %ptrs, i32 4, <4 x i1> <i1 true, i1 false, i1 true, i1 true>, <4 x double> undef)
  %elt = extractelement <4 x double> %res, i64 2
  ret double %elt
}

define <2 x double> @load_generic(ptr %ptr, double %pt, <2 x i1> %mask)  {
; CHECK-LABEL: @load_generic(
; CHECK-NEXT:    [[PTV1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PTV2:%.*]] = shufflevector <2 x double> [[PTV1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0(ptr [[PTR:%.*]], i32 4, <2 x i1> [[MASK:%.*]], <2 x double> [[PTV2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 4, <2 x i1> %mask, <2 x double> %ptv2)
  ret <2 x double> %res
}

define <2 x double> @load_speculative(ptr dereferenceable(16) align 4 %ptr, double %pt, <2 x i1> %mask) nofree nosync {
; CHECK-LABEL: @load_speculative(
; CHECK-NEXT:    [[PTV1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PTV2:%.*]] = shufflevector <2 x double> [[PTV1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[UNMASKEDLOAD:%.*]] = load <2 x double>, ptr [[PTR:%.*]], align 4
; CHECK-NEXT:    [[RES:%.*]] = select <2 x i1> [[MASK:%.*]], <2 x double> [[UNMASKEDLOAD]], <2 x double> [[PTV2]]
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 4, <2 x i1> %mask, <2 x double> %ptv2)
  ret <2 x double> %res
}

define <2 x double> @load_speculative_less_aligned(ptr dereferenceable(16) %ptr, double %pt, <2 x i1> %mask) nofree nosync {
; CHECK-LABEL: @load_speculative_less_aligned(
; CHECK-NEXT:    [[PTV1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PTV2:%.*]] = shufflevector <2 x double> [[PTV1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[UNMASKEDLOAD:%.*]] = load <2 x double>, ptr [[PTR:%.*]], align 4
; CHECK-NEXT:    [[RES:%.*]] = select <2 x i1> [[MASK:%.*]], <2 x double> [[UNMASKEDLOAD]], <2 x double> [[PTV2]]
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 4, <2 x i1> %mask, <2 x double> %ptv2)
  ret <2 x double> %res
}

; Can't speculate since only half of required size is known deref

define <2 x double> @load_spec_neg_size(ptr dereferenceable(8) %ptr, double %pt, <2 x i1> %mask) nofree nosync {
; CHECK-LABEL: @load_spec_neg_size(
; CHECK-NEXT:    [[PTV1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PTV2:%.*]] = shufflevector <2 x double> [[PTV1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0(ptr nonnull [[PTR:%.*]], i32 4, <2 x i1> [[MASK:%.*]], <2 x double> [[PTV2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 4, <2 x i1> %mask, <2 x double> %ptv2)
  ret <2 x double> %res
}

; Can only speculate one lane (but it's the only one active)
define <2 x double> @load_spec_lan0(ptr dereferenceable(8) %ptr, double %pt, <2 x i1> %mask) nofree nosync {
; CHECK-LABEL: @load_spec_lan0(
; CHECK-NEXT:    [[PTV1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PTV2:%.*]] = shufflevector <2 x double> [[PTV1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[MASK2:%.*]] = insertelement <2 x i1> [[MASK:%.*]], i1 false, i64 1
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.load.v2f64.p0(ptr nonnull [[PTR:%.*]], i32 4, <2 x i1> [[MASK2]], <2 x double> [[PTV2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptv1 = insertelement <2 x double> undef, double %pt, i64 0
  %ptv2 = insertelement <2 x double> %ptv1, double %pt, i64 1
  %mask2 = insertelement <2 x i1> %mask, i1 false, i64 1
  %res = call <2 x double> @llvm.masked.load.v2f64.p0(ptr %ptr, i32 4, <2 x i1> %mask2, <2 x double> %ptv2)
  ret <2 x double> %res
}

define void @store_zeromask(ptr %ptr, <2 x double> %val)  {
; CHECK-LABEL: @store_zeromask(
; CHECK-NEXT:    ret void
;
  call void @llvm.masked.store.v2f64.p0(<2 x double> %val, ptr %ptr, i32 4, <2 x i1> zeroinitializer)
  ret void
}

define void @store_onemask(ptr %ptr, <2 x double> %val)  {
; CHECK-LABEL: @store_onemask(
; CHECK-NEXT:    store <2 x double> [[VAL:%.*]], ptr [[PTR:%.*]], align 4
; CHECK-NEXT:    ret void
;
  call void @llvm.masked.store.v2f64.p0(<2 x double> %val, ptr %ptr, i32 4, <2 x i1> <i1 1, i1 1>)
  ret void
}

define void @store_demandedelts(ptr %ptr, double %val)  {
; CHECK-LABEL: @store_demandedelts(
; CHECK-NEXT:    [[VALVEC1:%.*]] = insertelement <2 x double> poison, double [[VAL:%.*]], i64 0
; CHECK-NEXT:    call void @llvm.masked.store.v2f64.p0(<2 x double> [[VALVEC1]], ptr [[PTR:%.*]], i32 4, <2 x i1> <i1 true, i1 false>)
; CHECK-NEXT:    ret void
;
  %valvec1 = insertelement <2 x double> undef, double %val, i32 0
  %valvec2 = insertelement <2 x double> %valvec1, double %val, i32 1
  call void @llvm.masked.store.v2f64.p0(<2 x double> %valvec2, ptr %ptr, i32 4, <2 x i1> <i1 true, i1 false>)
  ret void
}

define <2 x double> @gather_generic(<2 x ptr> %ptrs, <2 x i1> %mask, <2 x double> %passthru)  {
; CHECK-LABEL: @gather_generic(
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> [[PTRS:%.*]], i32 4, <2 x i1> [[MASK:%.*]], <2 x double> [[PASSTHRU:%.*]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32 4, <2 x i1> %mask, <2 x double> %passthru)
  ret <2 x double> %res
}


define <2 x double> @gather_zeromask(<2 x ptr> %ptrs, <2 x double> %passthru)  {
; CHECK-LABEL: @gather_zeromask(
; CHECK-NEXT:    ret <2 x double> [[PASSTHRU:%.*]]
;
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32 4, <2 x i1> zeroinitializer, <2 x double> %passthru)
  ret <2 x double> %res
}


define <2 x double> @gather_onemask(<2 x ptr> %ptrs, <2 x double> %passthru)  {
; CHECK-LABEL: @gather_onemask(
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> [[PTRS:%.*]], i32 4, <2 x i1> <i1 true, i1 true>, <2 x double> poison)
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32 4, <2 x i1> <i1 true, i1 true>, <2 x double> %passthru)
  ret <2 x double> %res
}

define <4 x double> @gather_lane2(ptr %base, double %pt)  {
; CHECK-LABEL: @gather_lane2(
; CHECK-NEXT:    [[PTRS:%.*]] = getelementptr double, ptr [[BASE:%.*]], <4 x i64> <i64 poison, i64 poison, i64 2, i64 poison>
; CHECK-NEXT:    [[PT_V1:%.*]] = insertelement <4 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PT_V2:%.*]] = shufflevector <4 x double> [[PT_V1]], <4 x double> poison, <4 x i32> <i32 0, i32 0, i32 poison, i32 0>
; CHECK-NEXT:    [[RES:%.*]] = call <4 x double> @llvm.masked.gather.v4f64.v4p0(<4 x ptr> [[PTRS]], i32 4, <4 x i1> <i1 false, i1 false, i1 true, i1 false>, <4 x double> [[PT_V2]])
; CHECK-NEXT:    ret <4 x double> [[RES]]
;
  %ptrs = getelementptr double, ptr %base, <4 x i64> <i64 0, i64 1, i64 2, i64 3>
  %pt_v1 = insertelement <4 x double> undef, double %pt, i64 0
  %pt_v2 = shufflevector <4 x double> %pt_v1, <4 x double> undef, <4 x i32> zeroinitializer
  %res = call <4 x double> @llvm.masked.gather.v4f64.v4p0(<4 x ptr> %ptrs, i32 4, <4 x i1> <i1 false, i1 false, i1 true, i1 false>, <4 x double> %pt_v2)
  ret <4 x double> %res
}

define <2 x double> @gather_lane0_maybe(ptr %base, double %pt, <2 x i1> %mask)  {
; CHECK-LABEL: @gather_lane0_maybe(
; CHECK-NEXT:    [[PTRS:%.*]] = getelementptr double, ptr [[BASE:%.*]], <2 x i64> <i64 0, i64 1>
; CHECK-NEXT:    [[PT_V1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PT_V2:%.*]] = shufflevector <2 x double> [[PT_V1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[MASK2:%.*]] = insertelement <2 x i1> [[MASK:%.*]], i1 false, i64 1
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> [[PTRS]], i32 4, <2 x i1> [[MASK2]], <2 x double> [[PT_V2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptrs = getelementptr double, ptr %base, <2 x i64> <i64 0, i64 1>
  %pt_v1 = insertelement <2 x double> undef, double %pt, i64 0
  %pt_v2 = insertelement <2 x double> %pt_v1, double %pt, i64 1
  %mask2 = insertelement <2 x i1> %mask, i1 false, i64 1
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32 4, <2 x i1> %mask2, <2 x double> %pt_v2)
  ret <2 x double> %res
}

define <2 x double> @gather_lane0_maybe_spec(ptr %base, double %pt, <2 x i1> %mask)  {
; CHECK-LABEL: @gather_lane0_maybe_spec(
; CHECK-NEXT:    [[PTRS:%.*]] = getelementptr double, ptr [[BASE:%.*]], <2 x i64> <i64 0, i64 1>
; CHECK-NEXT:    [[PT_V1:%.*]] = insertelement <2 x double> poison, double [[PT:%.*]], i64 0
; CHECK-NEXT:    [[PT_V2:%.*]] = shufflevector <2 x double> [[PT_V1]], <2 x double> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[MASK2:%.*]] = insertelement <2 x i1> [[MASK:%.*]], i1 false, i64 1
; CHECK-NEXT:    [[RES:%.*]] = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> [[PTRS]], i32 4, <2 x i1> [[MASK2]], <2 x double> [[PT_V2]])
; CHECK-NEXT:    ret <2 x double> [[RES]]
;
  %ptrs = getelementptr double, ptr %base, <2 x i64> <i64 0, i64 1>
  %pt_v1 = insertelement <2 x double> undef, double %pt, i64 0
  %pt_v2 = insertelement <2 x double> %pt_v1, double %pt, i64 1
  %mask2 = insertelement <2 x i1> %mask, i1 false, i64 1
  %res = call <2 x double> @llvm.masked.gather.v2f64.v2p0(<2 x ptr> %ptrs, i32 4, <2 x i1> %mask2, <2 x double> %pt_v2)
  ret <2 x double> %res
}


define void @scatter_zeromask(<2 x ptr> %ptrs, <2 x double> %val)  {
; CHECK-LABEL: @scatter_zeromask(
; CHECK-NEXT:    ret void
;
  call void @llvm.masked.scatter.v2f64.v2p0(<2 x double> %val, <2 x ptr> %ptrs, i32 8, <2 x i1> zeroinitializer)
  ret void
}

define void @scatter_demandedelts(ptr %ptr, double %val)  {
; CHECK-LABEL: @scatter_demandedelts(
; CHECK-NEXT:    [[PTRS:%.*]] = getelementptr double, ptr [[PTR:%.*]], <2 x i64> <i64 0, i64 poison>
; CHECK-NEXT:    [[VALVEC1:%.*]] = insertelement <2 x double> poison, double [[VAL:%.*]], i64 0
; CHECK-NEXT:    call void @llvm.masked.scatter.v2f64.v2p0(<2 x double> [[VALVEC1]], <2 x ptr> [[PTRS]], i32 8, <2 x i1> <i1 true, i1 false>)
; CHECK-NEXT:    ret void
;
  %ptrs = getelementptr double, ptr %ptr, <2 x i64> <i64 0, i64 1>
  %valvec1 = insertelement <2 x double> undef, double %val, i32 0
  %valvec2 = insertelement <2 x double> %valvec1, double %val, i32 1
  call void @llvm.masked.scatter.v2f64.v2p0(<2 x double> %valvec2, <2 x ptr> %ptrs, i32 8, <2 x i1> <i1 true, i1 false>)
  ret void
}


; Test scatters that can be simplified to scalar stores.

;; Value splat (mask is not used)
define void @scatter_v4i16_uniform_vals_uniform_ptrs_no_all_active_mask(ptr %dst, i16 %val) {
; CHECK-LABEL: @scatter_v4i16_uniform_vals_uniform_ptrs_no_all_active_mask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i16 [[VAL:%.*]], ptr [[DST:%.*]], align 2
; CHECK-NEXT:    ret void
;
entry:
  %broadcast.splatinsert = insertelement <4 x ptr> poison, ptr %dst, i32 0
  %broadcast.splat = shufflevector <4 x ptr> %broadcast.splatinsert, <4 x ptr> poison, <4 x i32> zeroinitializer
  %broadcast.value = insertelement <4 x i16> poison, i16 %val, i32 0
  %broadcast.splatvalue = shufflevector <4 x i16> %broadcast.value, <4 x i16> poison, <4 x i32> zeroinitializer
  call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> %broadcast.splatvalue, <4 x ptr> %broadcast.splat, i32 2, <4 x i1> <i1 0, i1 0, i1 1, i1 1>)
  ret void
}

define void @scatter_nxv4i16_uniform_vals_uniform_ptrs_all_active_mask(ptr %dst, i16 %val) {
; CHECK-LABEL: @scatter_nxv4i16_uniform_vals_uniform_ptrs_all_active_mask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i16 [[VAL:%.*]], ptr [[DST:%.*]], align 2
; CHECK-NEXT:    ret void
;
entry:
  %broadcast.splatinsert = insertelement <vscale x 4 x ptr> poison, ptr %dst, i32 0
  %broadcast.splat = shufflevector <vscale x 4 x ptr> %broadcast.splatinsert, <vscale x 4 x ptr> poison, <vscale x 4 x i32> zeroinitializer
  %broadcast.value = insertelement <vscale x 4 x i16> poison, i16 %val, i32 0
  %broadcast.splatvalue = shufflevector <vscale x 4 x i16> %broadcast.value, <vscale x 4 x i16> poison, <vscale x 4 x i32> zeroinitializer
  call void @llvm.masked.scatter.nxv4i16.nxv4p0(<vscale x 4 x i16> %broadcast.splatvalue, <vscale x 4 x ptr> %broadcast.splat, i32 2, <vscale x 4 x i1> splat (i1 true))
  ret void
}

;; The pointer is splat and mask is all active, but value is not a splat
define void @scatter_v4i16_no_uniform_vals_uniform_ptrs_all_active_mask(ptr %dst, ptr  %src)  {
; CHECK-LABEL: @scatter_v4i16_no_uniform_vals_uniform_ptrs_all_active_mask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i16>, ptr [[SRC:%.*]], align 2
; CHECK-NEXT:    [[TMP0:%.*]] = extractelement <4 x i16> [[WIDE_LOAD]], i64 3
; CHECK-NEXT:    store i16 [[TMP0]], ptr [[DST:%.*]], align 2
; CHECK-NEXT:    ret void
;
entry:
  %broadcast.splatinsert = insertelement <4 x ptr> poison, ptr %dst, i32 0
  %broadcast.splat = shufflevector <4 x ptr> %broadcast.splatinsert, <4 x ptr> poison, <4 x i32> zeroinitializer
  %wide.load = load <4 x i16>, ptr %src, align 2
  call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> %wide.load, <4 x ptr> %broadcast.splat, i32 2, <4 x i1> <i1 1, i1 1, i1 1, i1 1>)
  ret void
}

define void @scatter_nxv4i16_no_uniform_vals_uniform_ptrs_all_active_mask(ptr %dst, ptr %src) {
; CHECK-LABEL: @scatter_nxv4i16_no_uniform_vals_uniform_ptrs_all_active_mask(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 4 x i16>, ptr [[SRC:%.*]], align 2
; CHECK-NEXT:    [[TMP0:%.*]] = call i32 @llvm.vscale.i32()
; CHECK-NEXT:    [[TMP1:%.*]] = shl i32 [[TMP0]], 2
; CHECK-NEXT:    [[TMP2:%.*]] = add i32 [[TMP1]], -1
; CHECK-NEXT:    [[TMP3:%.*]] = extractelement <vscale x 4 x i16> [[WIDE_LOAD]], i32 [[TMP2]]
; CHECK-NEXT:    store i16 [[TMP3]], ptr [[DST:%.*]], align 2
; CHECK-NEXT:    ret void
;
entry:
  %broadcast.splatinsert = insertelement <vscale x 4 x ptr> poison, ptr %dst, i32 0
  %broadcast.splat = shufflevector <vscale x 4 x ptr> %broadcast.splatinsert, <vscale x 4 x ptr> poison, <vscale x 4 x i32> zeroinitializer
  %wide.load = load <vscale x 4 x i16>, ptr %src, align 2
  call void @llvm.masked.scatter.nxv4i16.nxv4p0(<vscale x 4 x i16> %wide.load, <vscale x 4 x ptr> %broadcast.splat, i32 2, <vscale x 4 x i1> splat (i1 true))
  ret void
}

; Negative scatter tests

;; Pointer is splat, but mask is not all active and  value is not a splat
define void @negative_scatter_v4i16_no_uniform_vals_uniform_ptrs_all_inactive_mask(ptr %dst, ptr %src) {
; CHECK-LABEL: @negative_scatter_v4i16_no_uniform_vals_uniform_ptrs_all_inactive_mask(
; CHECK-NEXT:    [[INSERT_ELT:%.*]] = insertelement <4 x ptr> poison, ptr [[DST:%.*]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <4 x ptr> [[INSERT_ELT]], <4 x ptr> poison, <4 x i32> <i32 poison, i32 poison, i32 0, i32 0>
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i16>, ptr [[SRC:%.*]], align 2
; CHECK-NEXT:    call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> [[WIDE_LOAD]], <4 x ptr> [[BROADCAST_SPLAT]], i32 2, <4 x i1> <i1 false, i1 false, i1 true, i1 true>)
; CHECK-NEXT:    ret void
;
  %insert.elt = insertelement <4 x ptr> poison, ptr %dst, i32 0
  %broadcast.splat = shufflevector <4 x ptr> %insert.elt, <4 x ptr> poison, <4 x i32> zeroinitializer
  %wide.load = load <4 x i16>, ptr %src, align 2
  call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> %wide.load, <4 x ptr> %broadcast.splat, i32 2, <4 x i1> <i1 0, i1 0, i1 1, i1 1>)
  ret void
}

;; The pointer in NOT a splat
define void @negative_scatter_v4i16_no_uniform_vals_no_uniform_ptrs_all_active_mask(<4 x ptr> %inPtr, ptr %src) {
; CHECK-LABEL: @negative_scatter_v4i16_no_uniform_vals_no_uniform_ptrs_all_active_mask(
; CHECK-NEXT:    [[BROADCAST:%.*]] = shufflevector <4 x ptr> [[INPTR:%.*]], <4 x ptr> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i16>, ptr [[SRC:%.*]], align 2
; CHECK-NEXT:    call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> [[WIDE_LOAD]], <4 x ptr> [[BROADCAST]], i32 2, <4 x i1> <i1 true, i1 true, i1 true, i1 true>)
; CHECK-NEXT:    ret void
;
  %broadcast= shufflevector <4 x ptr> %inPtr, <4 x ptr> poison, <4 x i32> zeroinitializer
  %wide.load = load <4 x i16>, ptr %src, align 2
  call void @llvm.masked.scatter.v4i16.v4p0(<4 x i16> %wide.load, <4 x ptr> %broadcast, i32 2, <4 x i1> <i1 1, i1 1, i1 1, i1 1> )
  ret void
}


; Function Attrs:
declare void @llvm.masked.scatter.v4i16.v4p0(<4 x i16>, <4 x ptr>, i32 immarg, <4 x i1>)
declare void @llvm.masked.scatter.nxv4i16.nxv4p0(<vscale x 4 x i16>, <vscale x 4 x ptr>, i32 immarg, <vscale x 4 x i1>)

; Test gathers that can be simplified to scalar load + splat

;; Splat address and all active mask
define <vscale x 2 x i64> @gather_nxv2i64_uniform_ptrs_all_active_mask(ptr %src) {
; CHECK-LABEL: @gather_nxv2i64_uniform_ptrs_all_active_mask(
; CHECK-NEXT:    [[LOAD_SCALAR:%.*]] = load i64, ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT1:%.*]] = insertelement <vscale x 2 x i64> poison, i64 [[LOAD_SCALAR]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT2:%.*]] = shufflevector <vscale x 2 x i64> [[BROADCAST_SPLATINSERT1]], <vscale x 2 x i64> poison, <vscale x 2 x i32> zeroinitializer
; CHECK-NEXT:    ret <vscale x 2 x i64> [[BROADCAST_SPLAT2]]
;
  %broadcast.splatinsert = insertelement <vscale x 2 x ptr> poison, ptr %src, i32 0
  %broadcast.splat = shufflevector <vscale x 2 x ptr> %broadcast.splatinsert, <vscale x 2 x ptr> poison, <vscale x 2 x i32> zeroinitializer
  %res = call <vscale x 2 x i64> @llvm.masked.gather.nxv2i64(<vscale x 2 x ptr> %broadcast.splat, i32 8, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i64> undef)
  ret <vscale x 2 x i64> %res
}

define <2 x i64> @gather_v2i64_uniform_ptrs_all_active_mask(ptr %src) {
; CHECK-LABEL: @gather_v2i64_uniform_ptrs_all_active_mask(
; CHECK-NEXT:    [[LOAD_SCALAR:%.*]] = load i64, ptr [[SRC:%.*]], align 8
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT1:%.*]] = insertelement <2 x i64> poison, i64 [[LOAD_SCALAR]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT2:%.*]] = shufflevector <2 x i64> [[BROADCAST_SPLATINSERT1]], <2 x i64> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    ret <2 x i64> [[BROADCAST_SPLAT2]]
;
  %broadcast.splatinsert = insertelement <2 x ptr> poison, ptr %src, i32 0
  %broadcast.splat = shufflevector <2 x ptr> %broadcast.splatinsert, <2 x ptr> poison, <2 x i32> zeroinitializer
  %res = call <2 x i64> @llvm.masked.gather.v2i64(<2 x ptr> %broadcast.splat, i32 8, <2 x i1> <i1 1, i1 1>, <2 x i64> undef)
  ret <2 x i64> %res
}

; Negative gather tests

;; Vector of pointers is not a splat.
define <2 x i64> @negative_gather_v2i64_non_uniform_ptrs_all_active_mask(<2 x ptr> %inVal, ptr %src ) {
; CHECK-LABEL: @negative_gather_v2i64_non_uniform_ptrs_all_active_mask(
; CHECK-NEXT:    [[INSERT_VALUE:%.*]] = insertelement <2 x ptr> [[INVAL:%.*]], ptr [[SRC:%.*]], i64 1
; CHECK-NEXT:    [[RES:%.*]] = call <2 x i64> @llvm.masked.gather.v2i64.v2p0(<2 x ptr> [[INSERT_VALUE]], i32 8, <2 x i1> <i1 true, i1 true>, <2 x i64> poison)
; CHECK-NEXT:    ret <2 x i64> [[RES]]
;
  %insert.value = insertelement <2 x ptr> %inVal, ptr %src, i32 1
  %res = call <2 x i64> @llvm.masked.gather.v2i64(<2 x ptr> %insert.value, i32 8, <2 x i1><i1 1, i1 1>, <2 x i64> undef)
  ret <2 x i64> %res
}

;; Unknown mask value
define <2 x i64> @negative_gather_v2i64_uniform_ptrs_no_all_active_mask(ptr %src, <2 x i1> %mask) {
; CHECK-LABEL: @negative_gather_v2i64_uniform_ptrs_no_all_active_mask(
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <2 x ptr> poison, ptr [[SRC:%.*]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <2 x ptr> [[BROADCAST_SPLATINSERT]], <2 x ptr> poison, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[RES:%.*]] = call <2 x i64> @llvm.masked.gather.v2i64.v2p0(<2 x ptr> [[BROADCAST_SPLAT]], i32 8, <2 x i1> [[MASK:%.*]], <2 x i64> undef)
; CHECK-NEXT:    ret <2 x i64> [[RES]]
;
  %broadcast.splatinsert = insertelement <2 x ptr> poison, ptr %src, i32 0
  %broadcast.splat = shufflevector <2 x ptr> %broadcast.splatinsert, <2 x ptr> poison, <2 x i32> zeroinitializer
  %res = call <2 x i64> @llvm.masked.gather.v2i64(<2 x ptr> %broadcast.splat, i32 8, <2 x i1> %mask, <2 x i64> undef)
  ret <2 x i64> %res
}

; Function Attrs:
declare <vscale x 2 x i64> @llvm.masked.gather.nxv2i64(<vscale x 2 x ptr>, i32, <vscale x 2 x i1>, <vscale x 2 x i64>)
declare <2 x i64> @llvm.masked.gather.v2i64(<2 x ptr>, i32, <2 x i1>, <2 x i64>)
