; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt < %s -passes=newgvn -S | FileCheck %s

declare i32 @foo(i32) readnone

define i1 @bar() {
; CHECK-LABEL: define i1 @bar() {
; CHECK-NEXT:    [[A:%.*]] = call i32 @foo(i32 0) #[[ATTR0:[0-9]+]]
; CHECK-NEXT:    [[X:%.*]] = call i32 @foo(i32 [[A]]) #[[ATTR0]]
; CHECK-NEXT:    ret i1 true
;
  %a = call i32 @foo (i32 0) readnone
  %b = call i32 @foo (i32 0) readnone
  %c = and i32 %a, %b
  %x = call i32 @foo (i32 %a) readnone
  %y = call i32 @foo (i32 %c) readnone
  %z = icmp eq i32 %x, %y
  ret i1 %z
}