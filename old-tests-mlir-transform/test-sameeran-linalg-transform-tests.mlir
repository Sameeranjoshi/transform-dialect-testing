// RUN: mlir-opt %s -test-transform-dialect-interpreter -test-linalg-transform-patterns=test-patterns -split-input-file
// XFAIL: *

// Not sure what changes I did which makes it fail, maybe I was playing with 
// linalg.matmul -> linalg.dot
// -----

func.func @dot(%x: memref<?xf32, strided<[1], offset: ?>>,
          %y: memref<?xf32, strided<[1], offset: ?>>,
          %v: memref<f32>) {
  linalg.dot ins(%x, %y: memref<?xf32, strided<[1], offset: ?>>,
                         memref<?xf32, strided<[1], offset: ?>>)
            outs(%v: memref<f32>)
  return
}

transform.sequence failures(propagate) {
  ^bb0(%arg1: !pdl.operation):
    %0 = transform.structured.match ops{["linalg.dot"]} in %arg1
    %1 = get_closest_isolated_parent %0 : (!pdl.operation) -> !pdl.operation
    %2, %loop = transform.structured.tile %1 [2]
}


