#map = affine_map<(d0, d1) -> (d0, d1)>
#map1 = affine_map<(d0, d1) -> (d1, d0)>
module {
  util.global private mutable @lhs__timepoint = #stream.timepoint<immediate> : !stream.timepoint
  util.global private @lhs : !stream.resource<constant>
  util.initializer {
    %c0 = arith.constant 0 : index
    %c18432 = arith.constant 18432 : index
    %c1073741824_i32 = arith.constant 1073741824 : i32
    %c0_i8 = arith.constant 0 : i8
    %c36864 = arith.constant 36864 : index
    %0 = stream.resource.alloc uninitialized : !stream.resource<constant>{%c36864}
    %1 = stream.cmd.execute with(%0 as %arg0: !stream.resource<constant>{%c36864}) {
      stream.cmd.concurrent {
        stream.cmd.fill %c0_i8, %arg0[%c0 for %c18432] : i8 -> !stream.resource<constant>{%c36864}
        stream.cmd.fill %c1073741824_i32, %arg0[%c18432 for %c18432] : i32 -> !stream.resource<constant>{%c36864}
      }
    } => !stream.timepoint
    util.global.store %0, @lhs : !stream.resource<constant>
    util.global.store %1, @lhs__timepoint : !stream.timepoint
    util.initializer.return
  }
  stream.executable private @vecadd2d_dispatch_0 {
    stream.executable.export public @vecadd2d_dispatch_0_generic_9x512 workgroups(%arg0: index, %arg1: index) -> (index, index, index) {
      %x, %y, %z = flow.dispatch.workgroup_count_from_dag_root %arg0, %arg1
      stream.return %x, %y, %z : index, index, index
    }
    builtin.module {
      func.func @vecadd2d_dispatch_0_generic_9x512(%arg0: !stream.binding {stream.alignment = 64 : index}, %arg1: !stream.binding {stream.alignment = 64 : index}) {
        %c18432 = arith.constant 18432 : index
        %c0 = arith.constant 0 : index
        %0 = stream.binding.subspan %arg0[%c18432] : !stream.binding -> !flow.dispatch.tensor<readonly:tensor<9x512xf32>>
        %1 = stream.binding.subspan %arg0[%c0] : !stream.binding -> !flow.dispatch.tensor<readonly:tensor<512x9xf32>>
        %2 = stream.binding.subspan %arg1[%c0] : !stream.binding -> !flow.dispatch.tensor<writeonly:tensor<512x9xf32>>
        %3 = flow.dispatch.tensor.load %0, offsets = [0, 0], sizes = [9, 512], strides = [1, 1] : !flow.dispatch.tensor<readonly:tensor<9x512xf32>> -> tensor<9x512xf32>
        %4 = flow.dispatch.tensor.load %1, offsets = [0, 0], sizes = [512, 9], strides = [1, 1] : !flow.dispatch.tensor<readonly:tensor<512x9xf32>> -> tensor<512x9xf32>
        %5 = tensor.empty() : tensor<512x9xf32>
        %6 = linalg.generic {indexing_maps = [#map, #map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%3, %4 : tensor<9x512xf32>, tensor<512x9xf32>) outs(%5 : tensor<512x9xf32>) {
        ^bb0(%in: f32, %in_0: f32, %out: f32):
          %7 = arith.addf %in, %in_0 : f32
          linalg.yield %7 : f32
        } -> tensor<512x9xf32>
        flow.dispatch.tensor.store %6, %2, offsets = [0, 0], sizes = [512, 9], strides = [1, 1] : tensor<512x9xf32> -> !flow.dispatch.tensor<writeonly:tensor<512x9xf32>>
        return
      }
    }
  }
  func.func @vecadd2d() -> !hal.buffer_view attributes {iree.abi.stub} {
    %c36864 = arith.constant 36864 : index
    %c512 = arith.constant 512 : index
    %c9 = arith.constant 9 : index
    %c18432 = arith.constant 18432 : index
    %c0 = arith.constant 0 : index
    %lhs__timepoint = util.global.load @lhs__timepoint : !stream.timepoint
    %lhs = util.global.load @lhs : !stream.resource<constant>
    %0 = stream.resource.alloc uninitialized : !stream.resource<external>{%c18432}
    %1 = stream.cmd.execute await(%lhs__timepoint) => with(%lhs as %arg0: !stream.resource<constant>{%c36864}, %0 as %arg1: !stream.resource<external>{%c18432}) {
      stream.cmd.dispatch @vecadd2d_dispatch_0::@vecadd2d_dispatch_0_generic_9x512[%c9, %c512] {
        ro %arg0[%c0 for %c36864] : !stream.resource<constant>{%c36864},
        wo %arg1[%c0 for %c18432] : !stream.resource<external>{%c18432}
      }
    } => !stream.timepoint
    %2 = stream.timepoint.await %1 => %0 : !stream.resource<external>{%c18432}
    %3 = stream.tensor.export %2 : tensor<512x9xf32> in !stream.resource<external>{%c18432} -> !hal.buffer_view
    return %3 : !hal.buffer_view
  }
}

