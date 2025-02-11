; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt %s -S -passes='simplifycfg<switch-to-lookup>' -simplifycfg-require-and-preserve-domtree=1 -switch-range-to-icmp | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
declare void @foo(i32)

define void @test(i1 %a) {
; CHECK-LABEL: define void @test(
; CHECK-SAME: i1 [[A:%.*]]) {
; CHECK-NEXT:    [[A_OFF:%.*]] = add i1 [[A]], true
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i1 [[A_OFF]], true
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  switch i1 %a, label %default [i1 1, label %true
  i1 0, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

define void @test2(i2 %a) {
; CHECK-LABEL: define void @test2(
; CHECK-SAME: i2 [[A:%.*]]) {
; CHECK-NEXT:    switch i2 [[A]], label [[DOTUNREACHABLEDEFAULT:%.*]] [
; CHECK-NEXT:      i2 0, label [[CASE0:%.*]]
; CHECK-NEXT:      i2 1, label [[CASE1:%.*]]
; CHECK-NEXT:      i2 -2, label [[CASE2:%.*]]
; CHECK-NEXT:      i2 -1, label [[CASE3:%.*]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       case2:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       case3:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       .unreachabledefault:
; CHECK-NEXT:    unreachable
;
  switch i2 %a, label %default [i2 0, label %case0
  i2 1, label %case1
  i2 2, label %case2
  i2 3, label %case3]
case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
case2:
  call void @foo(i32 2)
  ret void
case3:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 4)
  ret void
}

; We can replace the default branch with case 3 since it is the only case that is missing.
define void @test3(i2 %a) {
; CHECK-LABEL: define void @test3(
; CHECK-SAME: i2 [[A:%.*]]) {
; CHECK-NEXT:    switch i2 [[A]], label [[DOTUNREACHABLEDEFAULT:%.*]] [
; CHECK-NEXT:      i2 0, label [[CASE0:%.*]]
; CHECK-NEXT:      i2 1, label [[CASE1:%.*]]
; CHECK-NEXT:      i2 -2, label [[CASE2:%.*]]
; CHECK-NEXT:      i2 -1, label [[DEFAULT:%.*]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       case2:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       .unreachabledefault:
; CHECK-NEXT:    unreachable
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  switch i2 %a, label %default [i2 0, label %case0
  i2 1, label %case1
  i2 2, label %case2]

case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
case2:
  call void @foo(i32 2)
  ret void
default:
  call void @foo(i32 3)
  ret void
}

define void @test3_prof(i2 %a) {
; CHECK-LABEL: define void @test3_prof(
; CHECK-SAME: i2 [[A:%.*]]) {
; CHECK-NEXT:    switch i2 [[A]], label [[DOTUNREACHABLEDEFAULT:%.*]] [
; CHECK-NEXT:      i2 0, label [[CASE0:%.*]]
; CHECK-NEXT:      i2 1, label [[CASE1:%.*]]
; CHECK-NEXT:      i2 -2, label [[CASE2:%.*]]
; CHECK-NEXT:      i2 -1, label [[DEFAULT:%.*]]
; CHECK-NEXT:    ], !prof [[PROF0:![0-9]+]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       case2:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       .unreachabledefault:
; CHECK-NEXT:    unreachable
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  switch i2 %a, label %default [i2 0, label %case0
  i2 1, label %case1
  i2 2, label %case2], !prof !0

case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
case2:
  call void @foo(i32 2)
  ret void
default:
  call void @foo(i32 3)
  ret void
}

; Negative test - check for possible overflow when computing
; number of possible cases.
define void @test4(i128 %a) {
; CHECK-LABEL: define void @test4(
; CHECK-SAME: i128 [[A:%.*]]) {
; CHECK-NEXT:    switch i128 [[A]], label [[DEFAULT:%.*]] [
; CHECK-NEXT:      i128 0, label [[CASE0:%.*]]
; CHECK-NEXT:      i128 1, label [[CASE1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       case0:
; CHECK-NEXT:    call void @foo(i32 0)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       case1:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET]]
; CHECK:       default:
; CHECK-NEXT:    call void @foo(i32 2)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  switch i128 %a, label %default [i128 0, label %case0
  i128 1, label %case1]

case0:
  call void @foo(i32 0)
  ret void
case1:
  call void @foo(i32 1)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

; All but one bit known zero
define void @test5(i8 %a) {
; CHECK-LABEL: define void @test5(
; CHECK-SAME: i8 [[A:%.*]]) {
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i8 [[A]], 2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], -1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %cmp = icmp ult i8 %a, 2
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 1, label %true
  i8 0, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

;; All but one bit known one
define void @test6(i8 %a) {
; CHECK-LABEL: define void @test6(
; CHECK-SAME: i8 [[A:%.*]]) {
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[A]], -2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[AND]], -2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], 1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = and i8 %a, 254
  %cmp = icmp eq i8 %and, 254
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 255, label %true
  i8 254, label %false]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

; Check that we can eliminate both dead cases and dead defaults
; within a single run of simplifycfg
define void @test7(i8 %a) {
; CHECK-LABEL: define void @test7(
; CHECK-SAME: i8 [[A:%.*]]) {
; CHECK-NEXT:    [[AND:%.*]] = and i8 [[A]], -2
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i8 [[AND]], -2
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[A_OFF:%.*]] = add i8 [[A]], 1
; CHECK-NEXT:    [[SWITCH:%.*]] = icmp ult i8 [[A_OFF]], 1
; CHECK-NEXT:    br i1 [[SWITCH]], label [[TRUE:%.*]], label [[FALSE:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       true:
; CHECK-NEXT:    call void @foo(i32 1)
; CHECK-NEXT:    br label [[COMMON_RET:%.*]]
; CHECK:       false:
; CHECK-NEXT:    call void @foo(i32 3)
; CHECK-NEXT:    br label [[COMMON_RET]]
;
  %and = and i8 %a, 254
  %cmp = icmp eq i8 %and, 254
  call void @llvm.assume(i1 %cmp)
  switch i8 %a, label %default [i8 255, label %true
  i8 254, label %false
  i8 0, label %also_dead]
true:
  call void @foo(i32 1)
  ret void
false:
  call void @foo(i32 3)
  ret void
also_dead:
  call void @foo(i32 5)
  ret void
default:
  call void @foo(i32 2)
  ret void
}

declare void @llvm.assume(i1)

!0 = !{!"branch_weights", i32 8, i32 4, i32 2, i32 1}
;.
; CHECK: [[PROF0]] = !{!"branch_weights", i32 0, i32 4, i32 2, i32 1, i32 8}
;.
