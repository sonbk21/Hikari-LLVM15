// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --version 2
// REQUIRES: riscv-registered-target
// RUN: %clang_cc1 -triple riscv64 -target-feature +v -target-feature +experimental-zvfbfmin -target-feature +xsfvfwmaccqqq \
// RUN:   -disable-O0-optnone -emit-llvm %s -o - | opt -S -passes=mem2reg | \
// RUN:   FileCheck --check-prefix=CHECK-RV64 %s

#include <sifive_vector.h>

// CHECK-RV64-LABEL: define dso_local <vscale x 1 x float> @test_sf_vfwmacc_4x4x4_f32mf2_tu
// CHECK-RV64-SAME: (<vscale x 1 x float> [[VD:%.*]], <vscale x 4 x bfloat> [[VS1:%.*]], <vscale x 1 x bfloat> [[VS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0:[0-9]+]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 1 x float> @llvm.riscv.sf.vfwmacc.4x4x4.nxv1f32.nxv4bf16.nxv1bf16.i64(<vscale x 1 x float> [[VD]], <vscale x 4 x bfloat> [[VS1]], <vscale x 1 x bfloat> [[VS2]], i64 [[VL]], i64 2)
// CHECK-RV64-NEXT:    ret <vscale x 1 x float> [[TMP0]]
//
vfloat32mf2_t test_sf_vfwmacc_4x4x4_f32mf2_tu(vfloat32mf2_t vd, vbfloat16m1_t vs1, vbfloat16mf4_t vs2, size_t vl) {
  return __riscv_sf_vfwmacc_4x4x4_f32mf2_tu(vd, vs1, vs2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 2 x float> @test_sf_vfwmacc_4x4x4_f32m1
// CHECK-RV64-SAME: (<vscale x 2 x float> [[VD:%.*]], <vscale x 4 x bfloat> [[VS1:%.*]], <vscale x 2 x bfloat> [[VS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 2 x float> @llvm.riscv.sf.vfwmacc.4x4x4.nxv2f32.nxv4bf16.nxv2bf16.i64(<vscale x 2 x float> [[VD]], <vscale x 4 x bfloat> [[VS1]], <vscale x 2 x bfloat> [[VS2]], i64 [[VL]], i64 2)
// CHECK-RV64-NEXT:    ret <vscale x 2 x float> [[TMP0]]
//
vfloat32m1_t test_sf_vfwmacc_4x4x4_f32m1(vfloat32m1_t vd, vbfloat16m1_t vs1, vbfloat16mf2_t vs2, size_t vl) {
  return __riscv_sf_vfwmacc_4x4x4_f32m1_tu(vd, vs1, vs2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 4 x float> @test_sf_vfwmacc_4x4x4_f32m2
// CHECK-RV64-SAME: (<vscale x 4 x float> [[VD:%.*]], <vscale x 4 x bfloat> [[VS1:%.*]], <vscale x 4 x bfloat> [[VS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 4 x float> @llvm.riscv.sf.vfwmacc.4x4x4.nxv4f32.nxv4bf16.nxv4bf16.i64(<vscale x 4 x float> [[VD]], <vscale x 4 x bfloat> [[VS1]], <vscale x 4 x bfloat> [[VS2]], i64 [[VL]], i64 2)
// CHECK-RV64-NEXT:    ret <vscale x 4 x float> [[TMP0]]
//
vfloat32m2_t test_sf_vfwmacc_4x4x4_f32m2(vfloat32m2_t vd, vbfloat16m1_t vs1, vbfloat16m1_t vs2, size_t vl) {
  return __riscv_sf_vfwmacc_4x4x4_f32m2_tu(vd, vs1, vs2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 8 x float> @test_sf_vfwmacc_4x4x4_f32m4
// CHECK-RV64-SAME: (<vscale x 8 x float> [[VD:%.*]], <vscale x 4 x bfloat> [[VS1:%.*]], <vscale x 8 x bfloat> [[VS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 8 x float> @llvm.riscv.sf.vfwmacc.4x4x4.nxv8f32.nxv4bf16.nxv8bf16.i64(<vscale x 8 x float> [[VD]], <vscale x 4 x bfloat> [[VS1]], <vscale x 8 x bfloat> [[VS2]], i64 [[VL]], i64 2)
// CHECK-RV64-NEXT:    ret <vscale x 8 x float> [[TMP0]]
//
vfloat32m4_t test_sf_vfwmacc_4x4x4_f32m4(vfloat32m4_t vd, vbfloat16m1_t vs1, vbfloat16m2_t vs2, size_t vl) {
  return __riscv_sf_vfwmacc_4x4x4_f32m4_tu(vd, vs1, vs2, vl);
}

// CHECK-RV64-LABEL: define dso_local <vscale x 16 x float> @test_sf_vfwmacc_4x4x4_f32m8
// CHECK-RV64-SAME: (<vscale x 16 x float> [[VD:%.*]], <vscale x 4 x bfloat> [[VS1:%.*]], <vscale x 16 x bfloat> [[VS2:%.*]], i64 noundef [[VL:%.*]]) #[[ATTR0]] {
// CHECK-RV64-NEXT:  entry:
// CHECK-RV64-NEXT:    [[TMP0:%.*]] = call <vscale x 16 x float> @llvm.riscv.sf.vfwmacc.4x4x4.nxv16f32.nxv4bf16.nxv16bf16.i64(<vscale x 16 x float> [[VD]], <vscale x 4 x bfloat> [[VS1]], <vscale x 16 x bfloat> [[VS2]], i64 [[VL]], i64 2)
// CHECK-RV64-NEXT:    ret <vscale x 16 x float> [[TMP0]]
//
vfloat32m8_t test_sf_vfwmacc_4x4x4_f32m8(vfloat32m8_t vd, vbfloat16m1_t vs1, vbfloat16m4_t vs2, size_t vl) {
  return __riscv_sf_vfwmacc_4x4x4_f32m8_tu(vd, vs1, vs2, vl);
}