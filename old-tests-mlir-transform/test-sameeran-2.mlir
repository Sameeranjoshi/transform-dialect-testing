// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect --split-input-file --verify-diagnostics


// INPUT TEST CASE - dummy extracted from test-interpret*.mlir 

// PAYLOAD IR
func.func @bar() {
  // expected-remark @below {{transform applied}}
  %0 = arith.constant 0 : i32
  // expected-remark @below {{transform applied}}
  %1 = arith.constant 1 : i32
  return
}


// TRANSFORM IR
transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  pdl.pattern @const : benefit(1) {
    %r = pdl.types
    %0 = pdl.operation "arith.constant" -> (%r : !pdl.range<type>)
    pdl.rewrite %0 with "transform.dialect"
  }

  transform.sequence %arg0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    %f = pdl_match @const in %arg1 : (!pdl.operation) -> !pdl.operation
    transform.foreach %f : !pdl.operation {
    ^bb2(%arg2: !pdl.operation):
      // expected-remark @below {{1}}
      transform.test_print_number_of_associated_payload_ir_ops %arg2
      transform.test_print_remark_at_operand %arg2, "transform applied" : !pdl.operation
    }
  }
}

