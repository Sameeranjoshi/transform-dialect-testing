// XFAIL:*
// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect --split-input-file --verify-diagnostics
// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// -----

func.func private @bar()

func.func @foo() {
  // expected-remark @below {{still here}}
  call @bar() : () -> ()
  return
}

transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  pdl.pattern @match_call : benefit(1) {
    %0 = pdl.operands
    %1 = pdl.types
    %2 = pdl.operation "func.call"(%0 : !pdl.range<value>) -> (%1 : !pdl.range<type>)
    pdl.rewrite %2 with "transform.dialect"
  }

  transform.sequence %arg0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation): 
    %0 = pdl_match @match_call in %arg1 : (!pdl.operation) -> !pdl.operation
    %1 = get_closest_isolated_parent %0 : (!pdl.operation) -> !pdl.operation

    transform.alternatives %1 : !pdl.operation {
    ^bb2(%arg2: !pdl.operation):
      %2 = transform.pdl_match @match_call in %arg2 : (!pdl.operation) -> !pdl.operation
      // expected-remark @below {{applying}}
      transform.test_emit_remark_and_erase_operand %2, "applying" {fail_after_erase}
    }, {
    ^bb2(%arg2: !pdl.operation):
      %2 = transform.pdl_match @match_call in %arg2 : (!pdl.operation) -> !pdl.operation
      transform.test_print_remark_at_operand %2, "still here" : !pdl.operation
      // This alternative succeeds.
    }, {
    ^bb2(%arg2: !pdl.operation):
      // This alternative is never run, so we must not have a remark here.
      %2 = transform.pdl_match @match_call in %arg2 : (!pdl.operation) -> !pdl.operation
      transform.test_emit_remark_and_erase_operand %2, "should not happen" {fail_after_erase}
    }
  }
}

// -----

// Example 2

// -----

func.func @foo() {
  %0 = arith.constant 0 : i32
  return
}

transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  pdl.pattern @match_func : benefit(1) {
    %0 = pdl.operands
    %1 = pdl.types
    %2 = pdl.operation "func.func"(%0 : !pdl.range<value>) -> (%1 : !pdl.range<type>)
    pdl.rewrite %2 with "transform.dialect"
  }

  transform.sequence %arg0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    // This is necessary to run the transformation on something other than the
    // top-level module, "alternatives" cannot be run on that.
    %0 = pdl_match @match_func in %arg1 : (!pdl.operation) -> !pdl.operation
    transform.alternatives %0 : !pdl.operation {
    ^bb2(%arg2: !pdl.operation):
      %1 = transform.test_produce_param_or_forward_operand 42
      // This operation fails, which triggers the next alternative without
      // reporting the error.
      transform.test_consume_operand_if_matches_param_or_fail %1[43]
    }, {
    ^bb2(%arg2: !pdl.operation):
      %1 = transform.test_produce_param_or_forward_operand 42
      // expected-remark @below {{succeeded}}
      transform.test_consume_operand_if_matches_param_or_fail %1[42]
    }
  }
}

// -----
// Example 3
// -----

transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  // expected-error @below {{expects at least one region}}
  transform.alternatives
}


