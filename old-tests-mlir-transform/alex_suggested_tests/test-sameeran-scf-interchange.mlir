// RUN: mlir-opt %s -test-transform-dialect-interpreter --verify-diagnostics | FileCheck %s

// Payload IR
func.func @loop_interchange(){
    // Declare 2 integer variables with a=100 and b=200
    %a    = arith.constant 100 : i32
    %b    = arith.constant 200 : i32
    // again declare 3 more variables zero=0, n=10, in_steps_of=1
    %zero = arith.constant 0 : index
    %n    = arith.constant 100 : index
    %m    = arith.constant 200 : index
    %in_steps_of = arith.constant 1 : index
    
    // Loops start.
    // expected-remark @below {{outermost loop}}
    scf.for %i =  %zero to %n step %in_steps_of {
      // expected-remark @below {{innermost loop}}
        scf.for %j =  %zero to %m step %in_steps_of {
            arith.addi %a, %b : i32
        }
    }
    return 
}

// Transform IR
transform.sequence failures(propagate) {
  ^bb1(%arg1 : !pdl.operation):
    %matched_op = transform.structured.match ops{["arith.addi"]} in %arg1
    // 2 ways to get top most loop
    // Way A)
    %innermost_for = transform.loop.get_parent_for %matched_op : (!pdl.operation) -> !transform.op<"scf.for">
    %outermost_for = transform.loop.get_parent_for %innermost_for : (!transform.op<"scf.for">) -> !transform.op<"scf.for">    
    // Verify if all good
    transform.test_print_remark_at_operand %outermost_for, "outermost loop" : !transform.op<"scf.for">    
    transform.test_print_remark_at_operand %innermost_for, "innermost loop" : !transform.op<"scf.for">

    // This should return a global handle.
    // transform.loop.interchange %innermost_for %outermost_for

    // Verify if all good
    // transform.test_print_remark_at_operand %innermost_for, "outermost loop" : !transform.op<"scf.for">    
    // transform.test_print_remark_at_operand %outermost_for, "innermost loop" : !transform.op<"scf.for">

    // Try some already present optimizations to reverify.
    // transform.loop.unroll %innermost_for { factor = 3 } : !transform.op<"scf.for">
}