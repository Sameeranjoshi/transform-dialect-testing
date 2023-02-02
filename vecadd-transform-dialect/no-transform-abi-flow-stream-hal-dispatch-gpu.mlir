#executable_target_cuda_nvptx_fb = #hal.executable.target<"cuda", "cuda-nvptx-fb", {target_arch = "sm_35"}>
#map = affine_map<()[s0, s1] -> (s0 * 64 + s1)>
#pipeline_layout = #hal.pipeline.layout<push_constants = 0, sets = [<0, bindings = [<0, storage_buffer, ReadOnly>, <1, storage_buffer>]>]>
#translation = #iree_codegen.translation_info<LLVMGPUVectorize>
#device_target_cuda = #hal.device.target<"cuda", {executable_targets = [#executable_target_cuda_nvptx_fb], legacy_sync}>
module attributes {hal.device.targets = [#device_target_cuda]} {
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
  hal.executable private @vecadd2d_dispatch_0 {
    hal.executable.variant public @cuda_nvptx_fb, target = #executable_target_cuda_nvptx_fb {
      hal.executable.export public @vecadd2d_dispatch_0_generic_9x512 ordinal(0) layout(#pipeline_layout) attributes {translation_info = #translation, workgroup_size = [64 : index, 1 : index, 1 : index]} {
      ^bb0(%arg0: !hal.device, %arg1: index, %arg2: index):
        %c8 = arith.constant 8 : index
        %c9 = arith.constant 9 : index
        %c1 = arith.constant 1 : index
        hal.return %c8, %c9, %c1 : index, index, index
      }
      builtin.module {
        func.func @vecadd2d_dispatch_0_generic_9x512() {
          %cst = arith.constant 0.000000e+00 : f32
          %c18432 = arith.constant 18432 : index
          %c0 = arith.constant 0 : index
          %0 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c18432) flags(ReadOnly) : memref<9x512xf32>
          memref.assume_alignment %0, 64 : memref<9x512xf32>
          %1 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<512x9xf32>
          memref.assume_alignment %1, 64 : memref<512x9xf32>
          %2 = hal.interface.binding.subspan set(0) binding(1) type(storage_buffer) alignment(64) offset(%c0) : memref<512x9xf32>
          memref.assume_alignment %2, 64 : memref<512x9xf32>
          %workgroup_id_x = hal.interface.workgroup.id[0] : index
          %workgroup_id_y = hal.interface.workgroup.id[1] : index
          %3 = gpu.thread_id  x
          %4 = affine.apply #map()[%workgroup_id_x, %3]
          %5 = vector.transfer_read %0[%workgroup_id_y, %4], %cst {in_bounds = [true]} : memref<9x512xf32>, vector<1xf32>
          %6 = vector.transfer_read %1[%4, %workgroup_id_y], %cst {in_bounds = [true]} : memref<512x9xf32>, vector<1xf32>
          %7 = arith.addf %5, %6 : vector<1xf32>
          vector.transfer_write %7, %2[%4, %workgroup_id_y] {in_bounds = [true]} : vector<1xf32>, memref<512x9xf32>
          return
        }
      }
    }
  }
  func.func @vecadd2d() -> !hal.buffer_view attributes {iree.abi.stub} {
    %c0 = arith.constant 0 : index
    %c18432 = arith.constant 18432 : index
    %c9 = arith.constant 9 : index
    %c512 = arith.constant 512 : index
    %c36864 = arith.constant 36864 : index
    %lhs__timepoint = util.global.load @lhs__timepoint : !stream.timepoint
    %lhs = util.global.load @lhs : !stream.resource<constant>
    %0 = stream.resource.alloc uninitialized : !stream.resource<external>{%c18432}
    %1 = stream.cmd.execute await(%lhs__timepoint) => with(%lhs as %arg0: !stream.resource<constant>{%c36864}, %0 as %arg1: !stream.resource<external>{%c18432}) {
      stream.cmd.dispatch @vecadd2d_dispatch_0::@vecadd2d_dispatch_0_generic_9x512[%c9, %c512] {
        ro %arg0[%c0 for %c36864] : !stream.resource<constant>{%c36864},
        wo %arg1[%c0 for %c18432] : !stream.resource<external>{%c18432}
      } attributes {hal.interface.bindings = [#hal.interface.binding<0, 0>, #hal.interface.binding<0, 1>]}
    } => !stream.timepoint
    %2 = stream.timepoint.await %1 => %0 : !stream.resource<external>{%c18432}
    %3 = stream.tensor.export %2 : tensor<512x9xf32> in !stream.resource<external>{%c18432} -> !hal.buffer_view
    return %3 : !hal.buffer_view
  }
}

