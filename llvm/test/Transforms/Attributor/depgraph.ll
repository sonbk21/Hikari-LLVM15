; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -passes=attributor-cgscc -S < %s 2>&1 | FileCheck %s --check-prefixes=CHECK
; RUN: opt -passes=attributor-cgscc -disable-output -attributor-print-dep < %s 2>&1 | FileCheck %s --check-prefixes=GRAPH
; RUN: opt -passes=attributor-cgscc -disable-output -attributor-dump-dep-graph -attributor-depgraph-dot-filename-prefix=%t < %s 2>/dev/null
; RUN: FileCheck %s -input-file=%t_0.dot --check-prefix=DOT

; Test 0
;
; test copied from the attributor introduction video: checkAndAdvance(), and the C code is:
; int *checkAndAdvance(int * __attribute__((aligned(16))) p) {
;   if (*p == 0)
;     return checkAndAdvance(p + 4);
;   return p;
; }
;
define ptr @checkAndAdvance(ptr align 16 %0) {
; CHECK: Function Attrs: nofree nosync nounwind memory(argmem: read)
; CHECK-LABEL: define {{[^@]+}}@checkAndAdvance
; CHECK-SAME: (ptr nofree noundef nonnull readonly align 16 dereferenceable(4) [[TMP0:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, ptr [[TMP0]], align 16
; CHECK-NEXT:    [[TMP3:%.*]] = icmp eq i32 [[TMP2]], 0
; CHECK-NEXT:    br i1 [[TMP3]], label [[TMP4:%.*]], label [[TMP7:%.*]]
; CHECK:       4:
; CHECK-NEXT:    [[TMP5:%.*]] = getelementptr inbounds i32, ptr [[TMP0]], i64 4
; CHECK-NEXT:    [[TMP6:%.*]] = call ptr @checkAndAdvance(ptr nofree noundef nonnull readonly align 16 [[TMP5]]) #[[ATTR1:[0-9]+]]
; CHECK-NEXT:    br label [[TMP8:%.*]]
; CHECK:       7:
; CHECK-NEXT:    br label [[TMP8]]
; CHECK:       8:
; CHECK-NEXT:    [[DOT0:%.*]] = phi ptr [ [[TMP5]], [[TMP4]] ], [ [[TMP0]], [[TMP7]] ]
; CHECK-NEXT:    ret ptr [[DOT0]]
;
  %2 = load i32, ptr %0, align 4
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %4, label %7

4:                                                ; preds = %1
  %5 = getelementptr inbounds i32, ptr %0, i64 4
  %6 = call ptr @checkAndAdvance(ptr %5)
  br label %8

7:                                                ; preds = %1
  br label %8

8:                                                ; preds = %7, %4
  %.0 = phi ptr [ %6, %4 ], [ %0, %7 ]
  ret ptr %.0
}

;
; Check for graph
;


; GRAPH-NOT: update

;
; Check for .dot file
;
; DOT-DAG: Node[[Node0:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node1:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node2:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node3:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node4:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node5:0x[a-z0-9]+]] [shape=record,label="{[AANoReturn]
; DOT-DAG: Node[[Node6:0x[a-z0-9]+]] [shape=record,label="{[AANoReturn]
; DOT-DAG: Node[[Node7:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node8:0x[a-z0-9]+]] [shape=record,label="{[AAWillReturn]
; DOT-DAG: Node[[Node9:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node10:0x[a-z0-9]+]] [shape=record,label="{[AANoUnwind]
; DOT-DAG: Node[[Node11:0x[a-z0-9]+]] [shape=record,label="{[AANoUnwind]
; DOT-DAG: Node[[Node12:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryLocation]
; DOT-DAG: Node[[Node13:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryLocation]
; DOT-DAG: Node[[Node14:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryBehavior]
; DOT-DAG: Node[[Node15:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node16:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node17:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node18:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryBehavior]
; DOT-DAG: Node[[Node19:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node20:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node22:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node23:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node24:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node25:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node26:0x[a-z0-9]+]] [shape=record,label="{[AAPotentialValues]
; DOT-DAG: Node[[Node27:0x[a-z0-9]+]] [shape=record,label="{[AAInstanceInfo]
; DOT-DAG: Node[[Node28:0x[a-z0-9]+]] [shape=record,label="{[AANoRecurse]
; DOT-DAG: Node[[Node29:0x[a-z0-9]+]] [shape=record,label="{[AAInterFnReachability]
; DOT-DAG: Node[[Node30:0x[a-z0-9]+]] [shape=record,label="{[AAIntraFnReachability]
; DOT-DAG: Node[[Node31:0x[a-z0-9]+]] [shape=record,label="{[AACallEdges]
; DOT-DAG: Node[[Node32:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node33:0x[a-z0-9]+]] [shape=record,label="{[AAWillReturn]
; DOT-DAG: Node[[Node34:0x[a-z0-9]+]] [shape=record,label="{[AANoRecurse]
; DOT-DAG: Node[[Node35:0x[a-z0-9]+]] [shape=record,label="{[AAUndefinedBehavior]
; DOT-DAG: Node[[Node36:0x[a-z0-9]+]] [shape=record,label="{[AANoUndef]
; DOT-DAG: Node[[Node37:0x[a-z0-9]+]] [shape=record,label="{[AANoUndef]
; DOT-DAG: Node[[Node38:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node39:0x[a-z0-9]+]] [shape=record,label="{[AANoUndef]
; DOT-DAG: Node[[Node41:0x[a-z0-9]+]] [shape=record,label="{[AANoSync]
; DOT-DAG: Node[[Node42:0x[a-z0-9]+]] [shape=record,label="{[AANoSync]
; DOT-DAG: Node[[Node43:0x[a-z0-9]+]] [shape=record,label="{[AANoFree]
; DOT-DAG: Node[[Node44:0x[a-z0-9]+]] [shape=record,label="{[AANoFree]
; DOT-DAG: Node[[Node45:0x[a-z0-9]+]] [shape=record,label="{[AAAssumptionInfo]
; DOT-DAG: Node[[Node46:0x[a-z0-9]+]] [shape=record,label="{[AAHeapToStack]
; DOT-DAG: Node[[Node47:0x[a-z0-9]+]] [shape=record,label="{[AAAlign]
; DOT-DAG: Node[[Node48:0x[a-z0-9]+]] [shape=record,label="{[AAAlign]
; DOT-DAG: Node[[Node49:0x[a-z0-9]+]] [shape=record,label="{[AAAlign]
; DOT-DAG: Node[[Node50:0x[a-z0-9]+]] [shape=record,label="{[AAAlign]
; DOT-DAG: Node[[Node51:0x[a-z0-9]+]] [shape=record,label="{[AANonNull]
; DOT-DAG: Node[[Node52:0x[a-z0-9]+]] [shape=record,label="{[AANonNull]
; DOT-DAG: Node[[Node53:0x[a-z0-9]+]] [shape=record,label="{[AANoAlias]
; DOT-DAG: Node[[Node54:0x[a-z0-9]+]] [shape=record,label="{[AADereferenceable]
; DOT-DAG: Node[[Node55:0x[a-z0-9]+]] [shape=record,label="{[AADereferenceable]
; DOT-DAG: Node[[Node56:0x[a-z0-9]+]] [shape=record,label="{[AADereferenceable]
; DOT-DAG: Node[[Node59:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node60:0x[a-z0-9]+]] [shape=record,label="{[AANoAlias]
; DOT-DAG: Node[[Node61:0x[a-z0-9]+]] [shape=record,label="{[AANoCapture]
; DOT-DAG: Node[[Node62:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node63:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node64:0x[a-z0-9]+]] [shape=record,label="{[AANoCapture]
; DOT-DAG: Node[[Node65:0x[a-z0-9]+]] [shape=record,label="{[AAIsDead]
; DOT-DAG: Node[[Node66:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryBehavior]
; DOT-DAG: Node[[Node67:0x[a-z0-9]+]] [shape=record,label="{[AAMemoryBehavior]
; DOT-DAG: Node[[Node68:0x[a-z0-9]+]] [shape=record,label="{[AANoFree]
; DOT-DAG: Node[[Node69:0x[a-z0-9]+]] [shape=record,label="{[AAPrivatizablePtr]
; DOT-DAG: Node[[Node70:0x[a-z0-9]+]] [shape=record,label="{[AAAssumptionInfo]
; DOT-DAG: Node[[Node71:0x[a-z0-9]+]] [shape=record,label="{[AANoAlias]
; DOT-DAG: Node[[Node73:0x[a-z0-9]+]] [shape=record,label="{[AANoFree]
; DOT-DAG: Node[[Node75:0x[a-z0-9]+]] [shape=record,label="{[AAAddressSpace]
; DOT-DAG: Node[[Node74:0x[a-z0-9]+]] [shape=record,label="{[AADereferenceable]

; DOT-DAG: Node[[Node20]] -> Node[[Node19]];
; DOT-DAG: Node[[Node13]] -> Node[[Node12]];
; DOT-DAG: Node[[Node55]] -> Node[[Node56]];
; DOT-DAG: Node[[Node68]] -> Node[[Node73]];
; DOT-DAG: Node[[Node64]] -> Node[[Node61]];
; DOT-DAG: Node[[Node61]] -> Node[[Node64]];
; DOT-DAG: Node[[Node12]] -> Node[[Node13]];
; DOT-DAG: Node[[Node11]] -> Node[[Node61]];
; DOT-DAG: Node[[Node14]] -> Node[[Node18]];
; DOT-DAG: Node[[Node43]] -> Node[[Node68]];
; DOT-DAG: Node[[Node19]] -> Node[[Node22]];
; DOT-DAG: Node[[Node10]] -> Node[[Node11]];
; DOT-DAG: Node[[Node41]] -> Node[[Node42]];
; DOT-DAG: Node[[Node42]] -> Node[[Node41]];
; DOT-DAG: Node[[Node11]] -> Node[[Node10]];
; DOT-DAG: Node[[Node67]] -> Node[[Node66]];
; DOT-DAG: Node[[Node18]] -> Node[[Node14]];
; DOT-DAG: Node[[Node66]] -> Node[[Node67]];
; DOT-DAG: Node[[Node44]] -> Node[[Node43]];
; DOT-DAG: Node[[Node43]] -> Node[[Node44]];
;.
; CHECK: attributes #[[ATTR0]] = { nofree nosync nounwind memory(argmem: read) }
; CHECK: attributes #[[ATTR1]] = { nofree nosync nounwind memory(read) }
;.
;; NOTE: These prefixes are unused and the list is autogenerated. Do not add tests below this line:
; GRAPH: {{.*}}