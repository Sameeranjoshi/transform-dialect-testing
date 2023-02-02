#executable_target_embedded_elf_x86_64_ = #hal.executable.target<"llvm-cpu", "embedded-elf-x86_64", {cpu = "generic", cpu_features = "", data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", native_vector_size = 16 : index, target_triple = "x86_64-unknown-unknown-eabi-elf"}>
#map = affine_map<()[s0] -> (s0 ceildiv 2)>
#map1 = affine_map<(d0) -> (d0 * -2 + 3, 2)>
#map2 = affine_map<(d0) -> (d0 * 2)>
#pipeline_layout = #hal.pipeline.layout<push_constants = 0, sets = [<0, bindings = [<0, storage_buffer, ReadOnly>, <1, storage_buffer, ReadOnly>, <2, storage_buffer>]>]>
#translation = #iree_codegen.translation_info<TransformDialectCodegen>
#device_target_llvm_cpu = #hal.device.target<"llvm-cpu", {executable_targets = [#executable_target_embedded_elf_x86_64_]}>
module attributes {hal.device.targets = [#device_target_llvm_cpu]} {
  hal.executable private @matmul_static_dispatch_0 {
    hal.executable.variant public @embedded_elf_x86_64, target = #executable_target_embedded_elf_x86_64_ {
      hal.executable.export public @matmul_static_dispatch_0_matmul_3x3x5 ordinal(0) layout(#pipeline_layout) attributes {translation_info = #translation} {
      ^bb0(%arg0: !hal.device, %arg1: index, %arg2: index, %arg3: index):
        %c1 = arith.constant 1 : index
        %0 = affine.apply #map()[%arg1]
        hal.return %0, %c1, %c1 : index, index, index
      }
      builtin.module {
        func.func @matmul_static_dispatch_0_matmul_3x3x5() {
          %c2 = arith.constant 2 : index
          %c0 = arith.constant 0 : index
          %0 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<3x5xf32, #hal.descriptor_type<storage_buffer>>
          memref.assume_alignment %0, 64 : memref<3x5xf32, #hal.descriptor_type<storage_buffer>>
          %1 = hal.interface.binding.subspan set(0) binding(1) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<5x3xf32, #hal.descriptor_type<storage_buffer>>
          memref.assume_alignment %1, 64 : memref<5x3xf32, #hal.descriptor_type<storage_buffer>>
          %2 = hal.interface.binding.subspan set(0) binding(2) type(storage_buffer) alignment(64) offset(%c0) : memref<3x3xf32, #hal.descriptor_type<storage_buffer>>
          memref.assume_alignment %2, 64 : memref<3x3xf32, #hal.descriptor_type<storage_buffer>>
          scf.foreach_thread (%arg0) in (%c2) {
            %3 = affine.min #map1(%arg0)
            %4 = affine.apply #map2(%arg0)
            %subview = memref.subview %0[%4, 0] [%3, 5] [1, 1] : memref<3x5xf32, #hal.descriptor_type<storage_buffer>> to memref<?x5xf32, strided<[5, 1], offset: ?>, #hal.descriptor_type<storage_buffer>>
            %subview_0 = memref.subview %2[%4, 0] [%3, 3] [1, 1] : memref<3x3xf32, #hal.descriptor_type<storage_buffer>> to memref<?x3xf32, strided<[3, 1], offset: ?>, #hal.descriptor_type<storage_buffer>>
            linalg.matmul ins(%subview, %1 : memref<?x5xf32, strided<[5, 1], offset: ?>, #hal.descriptor_type<storage_buffer>>, memref<5x3xf32, #hal.descriptor_type<storage_buffer>>) outs(%subview_0 : memref<?x3xf32, strided<[3, 1], offset: ?>, #hal.descriptor_type<storage_buffer>>)
          } {mapping = [#gpu.block<x>]}
          return
        }
      }
    }
  }
  func.func @matmul_static(%arg0: !hal.buffer_view, %arg1: !hal.buffer_view, %arg2: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub} {
    %c0 = arith.constant 0 : index
    %c60 = arith.constant 60 : index
    %c36 = arith.constant 36 : index
    %c3 = arith.constant 3 : index
    %c1 = arith.constant 1 : index
    %c553648160_i32 = arith.constant 553648160 : i32
    %c1_i32 = arith.constant 1 : i32
    %c5 = arith.constant 5 : index
    hal.buffer_view.assert<%arg0 : !hal.buffer_view> message("tensor") shape([%c3, %c5]) type(%c553648160_i32) encoding(%c1_i32)
    %0 = stream.tensor.import %arg0 : !hal.buffer_view -> tensor<3x5xf32> in !stream.resource<external>{%c60}
    hal.buffer_view.assert<%arg1 : !hal.buffer_view> message("tensor") shape([%c5, %c3]) type(%c553648160_i32) encoding(%c1_i32)
    %1 = stream.tensor.import %arg1 : !hal.buffer_view -> tensor<5x3xf32> in !stream.resource<external>{%c60}
    hal.buffer_view.assert<%arg2 : !hal.buffer_view> message("tensor") shape([%c3, %c3]) type(%c553648160_i32) encoding(%c1_i32)
    %2 = stream.tensor.import %arg2 : !hal.buffer_view -> tensor<3x3xf32> in !stream.resource<external>{%c36}
    %3 = stream.cmd.execute with(%0 as %arg3: !stream.resource<external>{%c60}, %1 as %arg4: !stream.resource<external>{%c60}, %2 as %arg5: !stream.resource<external>{%c36}) {
      stream.cmd.dispatch @matmul_static_dispatch_0::@matmul_static_dispatch_0_matmul_3x3x5[%c3, %c3, %c1] {
        ro %arg3[%c0 for %c60] : !stream.resource<external>{%c60},
        ro %arg4[%c0 for %c60] : !stream.resource<external>{%c60},
        rw %arg5[%c0 for %c36] : !stream.resource<external>{%c36}
      } attributes {hal.interface.bindings = [#hal.interface.binding<0, 0>, #hal.interface.binding<0, 1>, #hal.interface.binding<0, 2>]}
    } => !stream.timepoint
    %4 = stream.timepoint.await %3 => %2 : !stream.resource<external>{%c36}
    %5 = stream.tensor.export %4 : tensor<3x3xf32> in !stream.resource<external>{%c36} -> !hal.buffer_view
    return %5 : !hal.buffer_view
  }
}

