#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1, d0)>
module {
  util.global private @lhs {noinline} = dense<0.000000e+00> : tensor<512x9xf32>
  util.global private @rhs {noinline} = dense<2.000000e+00> : tensor<9x512xf32>
  flow.executable private @vecadd2d_dispatch_0 {
    flow.executable.export public @vecadd2d_dispatch_0_generic_9x512 workgroups(%arg0: index, %arg1: index) -> (index, index, index) {
      %x, %y, %z = flow.dispatch.workgroup_count_from_dag_root %arg0, %arg1
      flow.return %x, %y, %z : index, index, index
    }
    builtin.module {
      func.func @vecadd2d_dispatch_0_generic_9x512(%arg0: !flow.dispatch.tensor<readonly:tensor<9x512xf32>>, %arg1: !flow.dispatch.tensor<readonly:tensor<512x9xf32>>, %arg2: !flow.dispatch.tensor<writeonly:tensor<512x9xf32>>) {
        %0 = flow.dispatch.tensor.load %arg0, offsets = [0, 0], sizes = [9, 512], strides = [1, 1] : !flow.dispatch.tensor<readonly:tensor<9x512xf32>> -> tensor<9x512xf32>
        %1 = flow.dispatch.tensor.load %arg1, offsets = [0, 0], sizes = [512, 9], strides = [1, 1] : !flow.dispatch.tensor<readonly:tensor<512x9xf32>> -> tensor<512x9xf32>
        %2 = tensor.empty() : tensor<512x9xf32>
        %3 = linalg.generic {indexing_maps = [#map, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%0, %1 : tensor<9x512xf32>, tensor<512x9xf32>) outs(%2 : tensor<512x9xf32>) {
        ^bb0(%in: f32, %in_0: f32, %out: f32):
          %4 = arith.addf %in, %in_0 : f32
          linalg.yield %4 : f32
        } -> tensor<512x9xf32>
        flow.dispatch.tensor.store %3, %arg2, offsets = [0, 0], sizes = [512, 9], strides = [1, 1] : tensor<512x9xf32> -> !flow.dispatch.tensor<writeonly:tensor<512x9xf32>>
        return
      }
    }
  }
  func.func @vecadd2d() -> !hal.buffer_view attributes {iree.abi.stub} {
    %c9 = arith.constant 9 : index
    %c512 = arith.constant 512 : index
    %rhs = util.global.load @rhs : tensor<9x512xf32>
    %lhs = util.global.load @lhs : tensor<512x9xf32>
    %0 = flow.dispatch @vecadd2d_dispatch_0::@vecadd2d_dispatch_0_generic_9x512[%c9, %c512](%rhs, %lhs) : (tensor<9x512xf32>, tensor<512x9xf32>) -> tensor<512x9xf32>
    %1 = hal.tensor.export %0 : tensor<512x9xf32> -> !hal.buffer_view
    return %1 : !hal.buffer_view
  }
}

