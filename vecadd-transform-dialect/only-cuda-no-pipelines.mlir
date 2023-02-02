#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1, d0)>
module {
  util.global private @lhs {noinline} = dense<0.000000e+00> : tensor<512x9xf32>
  util.global private @rhs {noinline} = dense<2.000000e+00> : tensor<9x512xf32>
  func.func @vecadd2d() -> tensor<512x9xf32> {
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant 2.000000e+00 : f32
    %ptr_rhs = util.global.address @rhs : !util.ptr<tensor<9x512xf32>>
    %0 = util.global.load.indirect %ptr_rhs : !util.ptr<tensor<9x512xf32>> -> tensor<9x512xf32>
    %ptr_lhs = util.global.address @lhs : !util.ptr<tensor<512x9xf32>>
    %1 = util.global.load.indirect %ptr_lhs : !util.ptr<tensor<512x9xf32>> -> tensor<512x9xf32>
    %2 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel"]} ins(%0 : tensor<9x512xf32>) outs(%1 : tensor<512x9xf32>) {
    ^bb0(%in: f32, %out: f32):
      %3 = arith.addf %in, %out : f32
      linalg.yield %3 : f32
    } -> tensor<512x9xf32>
    return %2 : tensor<512x9xf32>
  }
}

