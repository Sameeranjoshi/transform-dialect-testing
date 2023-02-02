// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect

//PAYLOAD IR
module {
  func.func @main() {
    %arr_a = arith.constant dense<[[1, 2, 3, 0], [4, 5, 6, 0], [7, 8, 9, 0], [10, 11, 12, 0]]> : tensor<4x4xi64>
    %arr_b = arith.constant dense<[[1, 2, 3, 9], [4, 5, 6, 0], [7, 8, 9, 0], [10, 11, 12, 0]]> : tensor<4x4xi64>
    %arr_c = arith.constant dense<0> : tensor<4x4xi64>
    %0 = linalg.matmul ins(%arr_a, %arr_b : tensor<4x4xi64>, tensor<4x4xi64>) outs(%arr_c : tensor<4x4xi64>) -> tensor<4x4xi64> 
    %cast = tensor.cast %0 : tensor<4x4xi64> to tensor<*xi64>
    call @printMemrefi64(%cast) : (tensor<*xi64>) -> ()
    return
  }


// TRANSFORM IR
  transform.sequence failures(propagate) {
  ^bb0(%arg0: !pdl.operation):
    %0 = transform.structured.match ops{["linalg.matmul"]} in %arg0
                                                          // target dynamic_sizes {static}
    // interchange = loop interchange/permutation optimization vector.
    // convention - 
    // outermost = 0
    // middle = 1
    // innermost = 2
    %tiled_linalg_op, %loops:3 = transform.structured.tile %0 [2,3,4] // {static_size="", interchange=[1,2,0]}
  }
  func.func private @printMemrefi64(tensor<*xi64>)
}


// mlir-opt ../SOURCES/llvm-project/mlir/test/Dialect/Transform/test-sameeran-tensor-matmul-copied.mlir -test-transform-dialect-interpreter --linalg-bufferize | mlir-opt --convert-linalg-to-loops

