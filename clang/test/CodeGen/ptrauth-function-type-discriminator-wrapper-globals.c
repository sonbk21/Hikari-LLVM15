// RUN: %clang_cc1 %s       -mllvm -ptrauth-emit-wrapper-globals=1 -fptrauth-function-pointer-type-discrimination -triple arm64e-apple-ios13 -fptrauth-calls -fptrauth-intrinsics -disable-llvm-passes -emit-llvm -o- | FileCheck %s --check-prefix=CHECK --check-prefix=CHECKC
// RUN: %clang_cc1 -xc++ %s -mllvm -ptrauth-emit-wrapper-globals=1 -fptrauth-function-pointer-type-discrimination -triple arm64e-apple-ios13 -fptrauth-calls -fptrauth-intrinsics -disable-llvm-passes -emit-llvm -o- | FileCheck %s --check-prefix=CHECK
// RUN: %clang_cc1 -mllvm -ptrauth-emit-wrapper-globals=1 -fptrauth-function-pointer-type-discrimination -triple arm64-apple-ios -fptrauth-calls -fptrauth-intrinsics -emit-pch %s -o %t.ast
// RUN: %clang_cc1 -mllvm -ptrauth-emit-wrapper-globals=1 -fptrauth-function-pointer-type-discrimination -triple arm64-apple-ios -fptrauth-calls -fptrauth-intrinsics -emit-llvm -x ast -o - %t.ast | FileCheck -check-prefix=CHECK --check-prefix=CHECKC %s

#ifdef __cplusplus
extern "C" {
#endif

void f(void);
void f2(int);
void (*fnptr)(void);
void *opaque;
unsigned long uintptr;

// CHECK: @test_constant_null = global ptr null
void (*test_constant_null)(int) = 0;

// CHECK: @f.ptrauth = private constant { {{.*}} } { ptr @f, i32 0, i64 0, i64 2712 }
// CHECK: @test_constant_cast = global ptr @f.ptrauth
void (*test_constant_cast)(int) = (void (*)(int))f;

// CHECK: @f.ptrauth.1 = private constant { {{.*}} } { ptr @f, i32 0, i64 0, i64 0 }
// CHECK: @test_opaque = global ptr @f.ptrauth.1
void *test_opaque =
#ifdef __cplusplus
    (void *)
#endif
    (void (*)(int))(double (*)(double))f;

// CHECK: @test_intptr_t = global i64 ptrtoint (ptr @f.ptrauth.1 to i64)
unsigned long test_intptr_t = (unsigned long)f;

// CHECK: @test_through_long = global ptr @f.ptrauth
void (*test_through_long)(int) = (void (*)(int))(long)f;

// CHECK: @test_to_long = global i64 ptrtoint (ptr @f.ptrauth.1 to i64)
long test_to_long = (long)(double (*)())f;

extern void external_function(void);
// CHECK: @fptr1 = global ptr @external_function.ptrauth
void (*fptr1)(void) = external_function;
// CHECK: @fptr2 = global ptr @external_function.ptrauth
void (*fptr2)(void) = &external_function;

// CHECK: @external_function.ptrauth.2 = private constant { ptr, i32, i64, i64 } { ptr @external_function, i32 2, i64 0, i64 26 }, section "llvm.ptrauth"
// CHECK: @fptr3 = global ptr @external_function.ptrauth.2
void (*fptr3)(void) = __builtin_ptrauth_sign_constant(&external_function, 2, 26);

// CHECK: @fptr4 = global ptr @external_function.ptrauth.3
// CHECK: @external_function.ptrauth.3 = private constant { ptr, i32, i64, i64 } { ptr @external_function, i32 2, i64 ptrtoint (ptr @fptr4 to i64), i64 26 }, section "llvm.ptrauth"
void (*fptr4)(void) = __builtin_ptrauth_sign_constant(&external_function, 2, __builtin_ptrauth_blend_discriminator(&fptr4, 26));

// CHECK: @returns_initially_incomplete.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @returns_initially_incomplete, i32 0, i64 0, i64 25106 }, section "llvm.ptrauth"
// CHECKC: @knr.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @knr, i32 0, i64 0, i64 18983 }, section "llvm.ptrauth"
// CHECKC: @redecl.ptrauth = private constant { ptr, i32, i64, i64 } { ptr @redecl, i32 0, i64 0, i64 18983 }, section "llvm.ptrauth"
// CHECKC: @redecl.ptrauth.4 = private constant { ptr, i32, i64, i64 } { ptr @redecl, i32 0, i64 0, i64 2712 }, section "llvm.ptrauth"

// CHECK-LABEL: define void @test_call()
void test_call() {
  // CHECK:      [[T0:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: call void [[T0]]() [ "ptrauth"(i32 0, i64 18983) ]
  fnptr();
}

// CHECK-LABEL: define ptr @test_function_pointer()
// CHECK:  ret ptr @external_function.ptrauth
void (*test_function_pointer())(void) {
  return external_function;
}

struct InitiallyIncomplete;
extern struct InitiallyIncomplete returns_initially_incomplete(void);
// CHECK-LABEL: define void @use_while_incomplete()
void use_while_incomplete() {
  // CHECK:      [[VAR:%.*]] = alloca ptr,
  // CHECK-NEXT: store ptr @returns_initially_incomplete.ptrauth, ptr [[VAR]]
  struct InitiallyIncomplete (*fnptr)(void) = &returns_initially_incomplete;
}
struct InitiallyIncomplete { int x; };
// CHECK-LABEL: define void @use_while_complete()
void use_while_complete() {
  // CHECK:      [[VAR:%.*]] = alloca ptr,
  // CHECK-NEXT: store ptr @returns_initially_incomplete.ptrauth, ptr [[VAR]]
  // CHECK-NEXT: ret void
  struct InitiallyIncomplete (*fnptr)(void) = &returns_initially_incomplete;
}


#ifndef __cplusplus

void knr(param)
  int param;
{}

// CHECKC-LABEL: define void @test_knr
void test_knr() {
  void (*p)() = knr;
  p(0);

  // CHECKC: [[P:%.*]] = alloca ptr
  // CHECKC: store ptr @knr.ptrauth, ptr [[P]]
  // CHECKC: [[LOAD:%.*]] = load ptr, ptr [[P]]
  // CHECKC: call void [[LOAD]](i32 noundef 0) [ "ptrauth"(i32 0, i64 18983) ]
}

// CHECKC-LABEL: define void @test_redeclaration
void test_redeclaration() {
  void redecl();
  void (*ptr)() = redecl;
  void redecl(int);
  void (*ptr2)(int) = redecl;
  ptr();
  ptr2(0);

  // CHECKC-NOT: call i64 @llvm.ptrauth.resign
  // CHECKC: call void {{.*}}() [ "ptrauth"(i32 0, i64 18983) ]
  // CHECKC: call void {{.*}}(i32 noundef 0) [ "ptrauth"(i32 0, i64 2712) ]
}

void knr2(param)
     int param;
{}

// CHECKC-LABEL: define void @test_redecl_knr
void test_redecl_knr() {
  void (*p)() = knr2;
  p();

  void knr2(int);

  void (*p2)(int) = knr2;
  p2(0);

  // CHECKC-NOT: call i64 @llvm.ptrauth.resign
  // CHECKC: call void {{.*}}() [ "ptrauth"(i32 0, i64 18983) ]
  // CHECKC: call void {{.*}}(i32 noundef 0) [ "ptrauth"(i32 0, i64 2712) ]
}

#endif

#ifdef __cplusplus
}
#endif