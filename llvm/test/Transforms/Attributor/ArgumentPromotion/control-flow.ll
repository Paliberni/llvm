; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes='attributor' -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=2 < %s | FileCheck %s

; Don't promote around control flow.
define internal i32 @callee(i1 %C, i32* %P) {
; CHECK-LABEL: define {{[^@]+}}@callee
; CHECK-SAME: (i1 [[C:%.*]], i32* noalias nocapture nofree readnone [[P:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 true, label [[T:%.*]], label [[F:%.*]]
; CHECK:       T:
; CHECK-NEXT:    ret i32 17
; CHECK:       F:
; CHECK-NEXT:    unreachable
;
entry:
  br i1 %C, label %T, label %F

T:
  ret i32 17

F:
  %X = load i32, i32* %P
  ret i32 %X
}

define i32 @foo() {
; CHECK-LABEL: define {{[^@]+}}@foo()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = call i32 @callee(i1 true, i32* noalias nofree undef)
; CHECK-NEXT:    ret i32 17
;
entry:
  %X = call i32 @callee(i1 true, i32* null)
  ret i32 %X
}

