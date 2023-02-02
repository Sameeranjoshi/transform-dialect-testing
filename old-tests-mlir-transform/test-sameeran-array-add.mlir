// RUN: mlir-opt %s

func.func @main() {
  %a = arith.constant dense<[1.0, 2.0, 3.0]> : tensor<3xf32>
  %b = arith.constant dense<[10.0, 20.0, 30.0]> : tensor<3xf32>

  %addf = arith.addf %a, %b : tensor<3xf32>

  //call @printMemrefF32(%addf) : (tensor<3xf32>) -> ()
  // CHECK: Unranked Memref base@ = {{.*}} rank = 1 offset = 0 sizes = [3] strides = [1] data =
  // CHECK-NEXT: [11,  22,  33]

  return
}

func.func private @printMemrefF32(%ptr : tensor<3xf32>)

