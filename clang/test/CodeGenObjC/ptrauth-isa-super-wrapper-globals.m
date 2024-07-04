// RUN: %clang_cc1 -I %S/Inputs -fptrauth-calls -fptrauth-objc-isa-mode=sign-and-strip -triple arm64-apple-ios -fobjc-runtime=ios-12.2 -emit-llvm -no-enable-noundef-analysis -fblocks -fobjc-arc -fobjc-runtime-has-weak -O2 -disable-llvm-passes -o - %s | FileCheck %s
// RUN: %clang_cc1 -I %S/Inputs -fptrauth-calls -fptrauth-objc-isa-mode=sign-and-auth  -triple arm64-apple-ios -fobjc-runtime=ios-12.2 -emit-llvm -no-enable-noundef-analysis -fblocks -fobjc-arc -fobjc-runtime-has-weak -O2 -disable-llvm-passes -o - %s | FileCheck %s

#include "literal-support.h"

#if __has_feature(objc_bool)
#define YES __objc_yes
#define NO __objc_no
#else
#define YES ((BOOL)1)
#define NO ((BOOL)0)
#endif

@class NSString;

// CHECK: @"OBJC_METACLASS_$_Base" = external global %struct._class_t
// CHECK: @OBJC_CLASS_NAME_ = private unnamed_addr constant [2 x i8] c"C\00", section "__TEXT,__objc_classname,cstring_literals", align 1
// CHECK: @OBJC_METH_VAR_NAME_.1 = private unnamed_addr constant [11 x i8] c"super_test\00", section "__TEXT,__objc_methname,cstring_literals", align 1
// CHECK: @OBJC_METH_VAR_TYPE_ = private unnamed_addr constant [8 x i8] c"v16@0:8\00", section "__TEXT,__objc_methtype,cstring_literals", align 1
// CHECK: @"\01+[C super_test].ptrauth" = private constant { ptr, i32, i64, i64 } { ptr @"\01+[C super_test]", i32 0, i64 ptrtoint (ptr getelementptr inbounds ({ i32, i32, [1 x %struct._objc_method] }, ptr @"_OBJC_$_CLASS_METHODS_C", i32 0, i32 2, i32 0, i32 2) to i64), i64 0 }, section "llvm.ptrauth", align 8
// CHECK: @"_OBJC_$_CLASS_METHODS_C" = internal global { i32, i32, [1 x %struct._objc_method] } { i32 24, i32 1, [1 x %struct._objc_method] [%struct._objc_method { ptr @OBJC_METH_VAR_NAME_.1, ptr @OBJC_METH_VAR_TYPE_, ptr @"\01+[C super_test].ptrauth" }] }, section "__DATA, __objc_const", align 8
// CHECK: @"_OBJC_$_CLASS_METHODS_C.ptrauth" = private constant { ptr, i32, i64, i64 } { ptr @"_OBJC_$_CLASS_METHODS_C", i32 2, i64 ptrtoint (ptr getelementptr inbounds (%struct._class_ro_t, ptr @"_OBJC_METACLASS_RO_$_C", i32 0, i32 5) to i64), i64 49936 }, section "llvm.ptrauth", align 8
// CHECK: @"_OBJC_METACLASS_RO_$_C" = internal global %struct._class_ro_t { i32 129, i32 40, i32 40, ptr null, ptr @OBJC_CLASS_NAME_, ptr @"_OBJC_$_CLASS_METHODS_C.ptrauth", ptr null, ptr null, ptr null, ptr null }, section "__DATA, __objc_const", align 8
// CHECK: @"OBJC_METACLASS_$_Base.ptrauth" = private constant { ptr, i32, i64, i64 } { ptr @"OBJC_METACLASS_$_Base", i32 2, i64 ptrtoint (ptr @"OBJC_METACLASS_$_C" to i64), i64 27361 }, section "llvm.ptrauth", align 8
// CHECK: @"OBJC_METACLASS_$_Base.ptrauth.2" = private constant { ptr, i32, i64, i64 } { ptr @"OBJC_METACLASS_$_Base", i32 2, i64 ptrtoint (ptr getelementptr inbounds (%struct._class_t, ptr @"OBJC_METACLASS_$_C", i32 0, i32 1) to i64), i64 46507 }, section "llvm.ptrauth", align 8
// CHECK: @"OBJC_CLASS_$_Base" = external global %struct._class_t
// CHECK: @"_OBJC_CLASS_RO_$_C" = internal global %struct._class_ro_t { i32 128, i32 0, i32 0, ptr null, ptr @OBJC_CLASS_NAME_, ptr null, ptr null, ptr null, ptr null, ptr null }, section "__DATA, __objc_const", align 8
// CHECK: @"OBJC_METACLASS_$_C.ptrauth" = private constant { ptr, i32, i64, i64 } { ptr @"OBJC_METACLASS_$_C", i32 2, i64 ptrtoint (ptr @"OBJC_CLASS_$_C" to i64), i64 27361 }, section "llvm.ptrauth", align 8
// CHECK: @"OBJC_CLASS_$_Base.ptrauth" = private constant { ptr, i32, i64, i64 } { ptr @"OBJC_CLASS_$_Base", i32 2, i64 ptrtoint (ptr getelementptr inbounds (%struct._class_t, ptr @"OBJC_CLASS_$_C", i32 0, i32 1) to i64), i64 46507 }, section "llvm.ptrauth", align 8
// CHECK: @"OBJC_CLASS_$_C" = global %struct._class_t { ptr @"OBJC_METACLASS_$_C.ptrauth", ptr @"OBJC_CLASS_$_Base.ptrauth", ptr @_objc_empty_cache, ptr null, ptr @"_OBJC_CLASS_RO_$_C" }, section "__DATA, __objc_data", align 8

@interface Base
+ (void)test;
@end

@interface C : Base
@end

@implementation C
// CHECK-LABEL: define internal void @"\01+[C super_test]"(ptr %self, ptr %_cmd) #1 {
+ (void)super_test {
  return [super test];
  // CHECK: [[SELF_ADDR:%.*]] = alloca ptr, align 8
  // CHECK: [[CMD_ADDR:%.*]] = alloca ptr, align 8
  // CHECK: [[SUPER_STRUCT:%.*]] = alloca %struct._objc_super, align 8
  // CHECK: store ptr %self, ptr [[SELF_ADDR]], align 8, !tbaa !{{[0-9]+}}
  // CHECK: store ptr %_cmd, ptr [[CMD_ADDR]], align 8, !tbaa !{{[0-9]+}}
  // CHECK: [[TARGET:%.*]] = load ptr, ptr [[SELF_ADDR]], align 8, !tbaa !{{[0-9]+}}
  // CHECK: [[OBJC_SUPER_TARGET:%.*]] = getelementptr inbounds %struct._objc_super, ptr [[SUPER_STRUCT]], i32 0, i32 0
  // CHECK: store ptr [[TARGET]], ptr [[OBJC_SUPER_TARGET]], align 8
  // CHECK: [[SUPER_REFERENCES:%.*]] = load ptr, ptr @"OBJC_CLASSLIST_SUP_REFS_$_"
  // CHECK: [[OBJC_SUPER_SUPER:%.*]] = getelementptr inbounds %struct._objc_super, ptr [[SUPER_STRUCT]], i32 0, i32 1
  // CHECK: store ptr [[SUPER_REFERENCES]], ptr [[OBJC_SUPER_SUPER:%.*]], align 8
  // CHECK: call void @objc_msgSendSuper2(ptr %objc_super, ptr %4)
}
@end

id str = @"";