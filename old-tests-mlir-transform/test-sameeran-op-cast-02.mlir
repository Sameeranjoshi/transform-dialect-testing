// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect --split-input-file --verify-diagnostics


// Roundtrip
// -----

"test.some_op"() : () -> ()
"other_dialect.other_op"() : () -> ()

transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  pdl.pattern @some : benefit(1) {
    %0 = pdl.operation "test.some_op"
    pdl.rewrite %0 with "transform.dialect"
  }

  sequence %arg0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    %0 = pdl_match @some in %arg1 : (!pdl.operation) -> !pdl.operation
    %2 = transform.cast %0 : !pdl.operation to !transform.op<"test.some_op">
    transform.cast %2 : !transform.op<"test.some_op"> to !pdl.operation
  }
}

// -----

