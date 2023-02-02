// RUN: mlir-opt %s --test-transform-dialect-interpreter -allow-unregistered-dialect --split-input-file --verify-diagnostics

func.func @dynamic_pad_tensor_3_4(%input_tensor: tensor<1x1xf32>,
                         %pad_value: f32) -> tensor<2x2xf32> {
  %0 = tensor.pad %input_tensor low[0, 0] high[1, 1] {
    ^bb0(%arg1: index, %arg2: index):
      tensor.yield %pad_value : f32
    } : tensor<1x1xf32> to tensor<2x2xf32>
  return %0 : tensor<2x2xf32>
}

transform.sequence failures(propagate) {
  ^bb0(%arg1: !pdl.operation):
    %0 = transform.structured.match ops{["tensor.pad"]} in %arg1
    %1, %loops:2 = transform.structured.tile_to_scf_for %0 [2, 2]
}

