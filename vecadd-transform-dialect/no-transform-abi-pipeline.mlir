#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1, d0)>
module {
  util.global private @lhs {noinline} = dense<0.000000e+00> : tensor<512x9xf32>
  util.global private @rhs {noinline} = dense<2.000000e+00> : tensor<9x512xf32>
  func.func @vecadd2d() -> !hal.buffer_view attributes {iree.abi.stub} {
    %rhs = util.global.load @rhs : tensor<9x512xf32>
    %lhs = util.global.load @lhs : tensor<512x9xf32>
    %0 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%rhs : tensor<9x512xf32>) outs(%lhs : tensor<512x9xf32>) {
    ^bb0(%in: f32, %out: f32):
      %2 = arith.addf %in, %out : f32
      linalg.yield %2 : f32
    } -> tensor<512x9xf32>
    %1 = hal.tensor.export %0 : tensor<512x9xf32> -> !hal.buffer_view
    return %1 : !hal.buffer_view
  }
}

