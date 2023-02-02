// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect --split-input-file --verify-diagnostics


// INPUT TEST CASE - dummy extracted from test-interpret*.mlir 

// PAYLOAD IR
func.func @get_parent_for_op_no_loop(%arg0: index, %arg1: index) {
  // expected-remark @below {{found muli}}
  %0 = arith.muli %arg0, %arg1 : index
  arith.addi %0, %arg1 : index
  return
}


// TRANSFORM IR
transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  %addi = transform.structured.match ops{["arith.addi"]} in %arg1
  %muli = get_producer_of_operand %addi[0] : (!pdl.operation) -> !pdl.operation
  transform.test_print_remark_at_operand %muli, "found muli" : !pdl.operation
}

