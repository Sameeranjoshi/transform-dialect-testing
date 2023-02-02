// RUN: mlir-opt %s -test-transform-dialect-interpreter -test-linalg-transform-patterns=test-patterns -split-input-file

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
    %1, %loop = transform.structured.tile %0 [8000]
}

