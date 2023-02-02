// RUN: mlir-opt %s -test-transform-dialect-interpreter --verify-diagnostics | FileCheck %s

// Payload IR
func.func @add_2_numbers() {
    // Declare 2 integer variables with a=100 and b=200
    %a    = arith.constant 100 : i32
    %b    = arith.constant 200 : i32
    // again declare 3 more variables zero=0, n=10, in_steps_of=1
    %zero = arith.constant 0 : index
    %n    = arith.constant 20 : index
    %in_steps_of = arith.constant 1 : index
    // expected-remark @below {{1st loop from top}}
    scf.for %i =  %zero to %n step %in_steps_of {
      // expected-remark @below {{2nd loop from top}}
        scf.for %j =  %zero to %n step %in_steps_of {
          // expected-remark @below {{3rd loop from top}}
            scf.for %k =  %zero to %n step %in_steps_of {
                arith.addi %a, %b : i32
            }
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
    %middle_for = transform.loop.get_parent_for %innermost_for : (!transform.op<"scf.for">) -> !transform.op<"scf.for">
    %outer_most = transform.loop.get_parent_for %middle_for : (!transform.op<"scf.for">) -> !transform.op<"scf.for">    
    // Verify if all good
    transform.test_print_remark_at_operand %outer_most, "1st loop from top" : !transform.op<"scf.for">
    transform.test_print_remark_at_operand %middle_for, "2nd loop from top" : !transform.op<"scf.for">
    transform.test_print_remark_at_operand %innermost_for, "3rd loop from top" : !transform.op<"scf.for">

    // Way B)
    // num_loops is an attribute, 3 is top most    
    %mid_for_using_child = transform.loop.get_child_for %outer_most : (!transform.op<"scf.for">) -> !transform.op<"scf.for">
    %inner_for_using_child = transform.loop.get_child_for %mid_for_using_child : (!transform.op<"scf.for">) -> !transform.op<"scf.for">
    // This should fail as of now as the block - getChildOp() is not well checked, this might give segfault.
    // %nullptr = transform.loop.get_child_for %inner_for_using_child : (!transform.op<"scf.for">) -> !transform.op<"scf.for">
  
    // Verify if all good
    transform.test_print_remark_at_operand %mid_for_using_child, "2nd loop from top" : !transform.op<"scf.for">
    transform.test_print_remark_at_operand %inner_for_using_child, "3rd loop from top" : !transform.op<"scf.for">
    transform.loop.unroll %inner_for_using_child { factor = 3 } : !transform.op<"scf.for">
}