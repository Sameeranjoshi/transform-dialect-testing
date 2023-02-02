// RUN: mlir-opt %s -test-transform-dialect-interpreter -split-input-file -verify-diagnostics | FileCheck %s


// CHECK-LABEL: @get_parent_for_op
func.func @get_parent_for_op(%arg0: index, %arg1: index, %arg2: index) {
  // expected-remark @below {{first loop}}
  scf.for %i = %arg0 to %arg1 step %arg2 {
    // expected-remark @below {{second loop}}
    scf.for %j = %arg0 to %arg1 step %arg2 {
      // expected-remark @below {{third loop}}
      scf.for %k = %arg0 to %arg1 step %arg2 {
        arith.addi %i, %j : index
      }
    }
  }
  return
}

transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  %0 = transform.structured.match ops{["arith.addi"]} in %arg1
  // CHECK: = transform.loop.get_parent_for
  %1 = transform.loop.get_parent_for %0 : (!pdl.operation) -> !transform.op<"scf.for">
  %2 = transform.loop.get_parent_for %0 { num_loops = 2 } : (!pdl.operation) -> !transform.op<"scf.for">
  %3 = transform.loop.get_parent_for %0 { num_loops = 3 } : (!pdl.operation) -> !transform.op<"scf.for">
  transform.test_print_remark_at_operand %1, "third loop" : !transform.op<"scf.for">
  transform.test_print_remark_at_operand %2, "second loop" : !transform.op<"scf.for">
  transform.test_print_remark_at_operand %3, "first loop" : !transform.op<"scf.for">
}

// -----
