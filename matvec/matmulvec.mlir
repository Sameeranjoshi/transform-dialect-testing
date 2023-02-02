// <9x512> vs <512> -> <9>
// matrix  vs vector -> vector
!type_vector_out = tensor<9xf32>
!type_matrix = tensor<9x512xf32>
!type_vector = tensor<512xf32>

#trait = { indexing_maps  = [affine_map<(d0, d1) -> (d0, d1)>],
           iterator_types = ["parallel", "parallel"] }

#trait2 = { indexing_maps  = [affine_map<(d0, d1) -> (d0, d1)>,
                              affine_map<(d0, d1) -> (d1)>,
                              affine_map<(d0, d1) -> (d0)>],
           iterator_types = ["parallel", "reduction"] }

util.global private @"out" {noinline} = dense<0.0> : !type_vector_out
util.global private @"lhs" {noinline} = dense<1.0> : !type_matrix
util.global private @"rhs" {noinline} = dense<1.0> : !type_vector
// The output matrix will be all 512

func.func @matmulvec() -> (!type_vector) {
  %cst1 = arith.constant 1.000000e+00 : f32
  
  %x_ptr = util.global.address @"rhs" : !util.ptr<!type_vector>  
  %x = util.global.load.indirect %x_ptr : !util.ptr<!type_vector> -> !type_vector 
  %y_ptr = util.global.address @"lhs" : !util.ptr<!type_matrix>  
  %y = util.global.load.indirect %y_ptr : !util.ptr<!type_matrix> -> !type_matrix

  %out_ptr = util.global.address @"out" : !util.ptr<!type_vector_out>  
  %out = util.global.load.indirect %out_ptr : !util.ptr<!type_vector_out> -> !type_vector_out
  // Note: Two linalg.generics to fill the tensors will make IREE generate two
  // separate kernels for the above and the below. It is important to validate
  // the results.
  %2 = linalg.generic #trait2 ins(%y : !type_matrix, %x : !type_vector) outs(%out : !type_vector_out) {
  ^bb0(%arg3: f32, %arg4: f32, %arg5: f32):
    %3 = arith.mulf %arg3, %arg4 : f32
    %4 = arith.addf %3, %arg5 : f32
    linalg.yield %4 : f32
  } -> !type_vector_out

  return %2 : !type_vector_out
}

// RUN: iree-opt %s --iree-hal-target-backends=cuda \
// RUN:     --iree-abi-transformation-pipeline \
// RUN:     --iree-flow-transformation-pipeline  \
// RUN:     --iree-stream-transformation-pipeline \
// RUN:     --iree-hal-configuration-pipeline | \
// RUN: iree-opt --pass-pipeline='builtin.module(hal.executable(hal.executable.variant(iree-llvmgpu-lower-executable-target)))' \
// RUN:     --iree-codegen-llvmgpu-use-transform-dialect=%p/vecadd2d_codegen_spec.mlir | \
// RUN: FileCheck %s --check-prefix=CHECK

// RUN: iree-opt %s --iree-hal-target-backends=cuda \
// RUN:     --iree-abi-transformation-pipeline \
// RUN:     --iree-flow-transformation-pipeline  \
// RUN:     --iree-stream-transformation-pipeline \
// RUN:     --iree-hal-configuration-pipeline | \
// RUN: iree-opt --pass-pipeline='builtin.module(hal.executable(hal.executable.variant(iree-llvmgpu-lower-executable-target)))' \
// RUN:     --iree-codegen-llvmgpu-use-transform-dialect=%p/vecadd2d_codegen_spec_partial_tile.mlir | \
// RUN: FileCheck %s --check-prefix=CHECK-PARTIAL-TILE

// RUN: iree-compile %s --iree-hal-target-backends=cuda \
// RUN:     --iree-opt-const-expr-hoisting=false --iree-opt-const-eval=false \
/// Constant JIT'ing must be disabled because the transform-dialect debug
/// flags leak to the JIT session, which doesn't know what to do with them.
// RUN:     --iree-codegen-llvmgpu-use-transform-dialect=%p/vecadd2d_codegen_spec.mlir | \
// RUN: iree-run-module --entry_function=vecadd2d --device=cuda |\
// RUN: FileCheck %s --check-prefix=EXEC

//     CHECK:  hal.executable.export
//     CHECK:  bb0(%[[DEV:.*]]: !hal.device, %[[A1:.*]]: index, %[[A2:.*]]: index):
//     CHECK:  %[[Dim2:.*]] = arith.constant 1 : index
//     CHECK:  %[[Dim3:.*]] = affine.apply #map()[%[[A1]]]
//     CHECK:  %[[Dim1:.*]] = affine.apply #map1()[%[[A2]]]
//     CHECK:  hal.return %[[Dim1]], %[[Dim2]], %[[Dim3]] : index, index, index

//     CHECK:  %[[BLKZ:.*]] = hal.interface.workgroup.id[2] : index
//     CHECK:  %[[BLKX:.*]] = hal.interface.workgroup.id[0] : index
//     CHECK:  memref.subview %0[%[[BLKZ:.*]], %[[BLKX:.*]]]

//     CHECK-PARTIAL-TILE:  hal.executable.export 
//     CHECK-PARTIAL-TILE:  bb0(%[[DEV:.*]]: !hal.device, %[[A1:.*]]: index, %[[A2:.*]]: index):
//     CHECK-PARTIAL-TILE:  %[[c1:.*]] = arith.constant 1 : index
//     CHECK-PARTIAL-TILE:  %[[dim:.*]] = affine.apply #map()[%[[A2]]]
//     CHECK-PARTIAL-TILE:  hal.return %[[c1]], %[[c1]], %[[dim]] : index, index, index

//      EXEC: EXEC @vecadd2d
//      EXEC: result[0]: hal.buffer_view
//      EXEC: 512x9xf32=[2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2]
