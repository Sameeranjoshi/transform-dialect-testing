// iree-opt matvec_linalg.mlir --iree-hal-target-backends=llvm-cpu  --iree-abi-transformation-pipeline --iree-flow-transformation-pipeline  --iree-stream-transformation-pipeline    --iree-hal-configuration-pipeline | iree-opt --pass-pipeline='builtin.module(hal.executable(hal.executable.variant(iree-llvmcpu-lower-executable-target)))' --iree-codegen-llvmcpu-use-transform-dialect=matvec_linalg_tiling_spec.mlir

//iree-compile matvec_linalg.mlir  --iree-hal-target-backends=llvm-cpu --iree-codegen-llvmcpu-use-transform-dialect=matvec_linalg_tiling_spec.mlir |  iree-run-module --entry_function=matvec_static --function_input="3x5xf32=1" --function_input="5xf32=1" --function_input="3xf32=0"


transform.sequence failures(propagate) {
  ^bb0(%arg1: !pdl.operation):
    %0 = transform.structured.match ops{["linalg.matvec"]} in %arg1
    %1, %loop = transform.structured.tile %0 [2]


//  // Step 2. Bufferize and drop HAL decriptor from memref ops.
//  // =========================================================
//  %variant_op_2 = transform.iree.eliminate_empty_tensors %arg1
//  %variant_op_3 = transform.iree.bufferize %variant_op_2
//   %memref_func = transform.structured.match ops{["func.func"]} in %variant_op_3
//   transform.iree.erase_hal_descriptor_type_from_memref %memref_func
}

