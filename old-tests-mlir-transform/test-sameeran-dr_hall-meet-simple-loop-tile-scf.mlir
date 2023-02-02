// XFAIL:*
// RUN: mlir-opt %s -test-transform-dialect-interpreter -split-input-file -verify-diagnostics | FileCheck %s

// -----

func.func @simple_loop_addition() {
  %c0 = arith.constant 0 : index
  %c42 = arith.constant 42 : index
  %c5 = arith.constant 5 : index
  scf.for %i = %c0 to %c42 step %c5 {
    arith.addi %i, %i : index
  }
  return
}

transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  %0 = transform.structured.match ops{["scf.for"]} in %arg1
//  transform.test_print_number_of_associated_payload_ir_ops %0
  transform.structured.tile_to_scf_for %0 [2]
}

//  %1 = transform.loop.get_parent_for %0 : (!pdl.operation) -> !transform.op<"scf.for">
//  %1 = transform.loop.get_parent_for %0 : (!pdl.operation) -> !transform.op<"scf.for">
//transform.loop.peel %1 : (!transform.op<"scf.for">) -> !pdl.operation
