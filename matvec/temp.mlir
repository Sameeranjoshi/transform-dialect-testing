#executable_target_embedded_elf_x86_64_ = #hal.executable.target<"llvm-cpu", "embedded-elf-x86_64", {cpu = "generic", cpu_features = "", data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", native_vector_size = 16 : index, target_triple = "x86_64-unknown-unknown-eabi-elf"}>
#map = affine_map<(d0) -> (2, -d0 + 3)>
#map1 = affine_map<(d0) -> (d0 - 1)>
#pipeline_layout = #hal.pipeline.layout<push_constants = 0, sets = [<0, bindings = [<0, storage_buffer, ReadOnly>, <1, storage_buffer, ReadOnly>, <2, storage_buffer>]>]>
#translation = #iree_codegen.translation_info<TransformDialectCodegen>
#device_target_llvm_cpu = #hal.device.target<"llvm-cpu", {executable_targets = [#executable_target_embedded_elf_x86_64_]}>
module attributes {hal.device.targets = [#device_target_llvm_cpu]} {
  hal.executable private @matvec_static_dispatch_0 {
    hal.executable.variant public @embedded_elf_x86_64, target = #executable_target_embedded_elf_x86_64_ {
      hal.executable.export public @matvec_static_dispatch_0_matvec_3x5 ordinal(0) layout(#pipeline_layout) attributes {translation_info = #translation} {
      ^bb0(%arg0: !hal.device, %arg1: index, %arg2: index):
        %x, %y, %z = flow.dispatch.workgroup_count_from_dag_root %arg1, %arg2
        hal.return %x, %y, %z : index, index, index
      }
      builtin.module {
        func.func @matvec_static_dispatch_0_matvec_3x5() {
          %c0 = arith.constant 0 : index
          %0 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : !flow.dispatch.tensor<readonly:tensor<3x5xf32>>
          %1 = hal.interface.binding.subspan set(0) binding(1) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : !flow.dispatch.tensor<readonly:tensor<5xf32>>
          %2 = hal.interface.binding.subspan set(0) binding(2) type(storage_buffer) alignment(64) offset(%c0) : !flow.dispatch.tensor<readwrite:tensor<3xf32>>
          %3 = flow.dispatch.tensor.load %0, offsets = [0, 0], sizes = [3, 5], strides = [1, 1] : !flow.dispatch.tensor<readonly:tensor<3x5xf32>> -> tensor<3x5xf32>
          %4 = flow.dispatch.tensor.load %1, offsets = [0], sizes = [5], strides = [1] : !flow.dispatch.tensor<readonly:tensor<5xf32>> -> tensor<5xf32>
          %5 = flow.dispatch.tensor.load %2, offsets = [0], sizes = [3], strides = [1] : !flow.dispatch.tensor<readwrite:tensor<3xf32>> -> tensor<3xf32>
          %c2 = arith.constant 2 : index
          %c0_0 = arith.constant 0 : index
          %c0_1 = arith.constant 0 : index
          %c3 = arith.constant 3 : index
          %6 = scf.for %arg0 = %c0_1 to %c3 step %c2 iter_args(%arg1 = %5) -> (tensor<3xf32>) {
            %c3_2 = arith.constant 3 : index
            %7 = affine.min #map(%arg0)
            %c0_3 = arith.constant 0 : index
            %c5 = arith.constant 5 : index
            %8 = affine.apply #map1(%7)
            %9 = affine.apply #map1(%7)
            %10 = affine.apply #map1(%7)
            %extracted_slice = tensor.extract_slice %3[%arg0, 0] [%7, 5] [1, 1] : tensor<3x5xf32> to tensor<?x5xf32>
            %extracted_slice_4 = tensor.extract_slice %4[0] [5] [1] : tensor<5xf32> to tensor<5xf32>
            %extracted_slice_5 = tensor.extract_slice %arg1[%arg0] [%7] [1] : tensor<3xf32> to tensor<?xf32>
            %11 = linalg.matvec ins(%extracted_slice, %extracted_slice_4 : tensor<?x5xf32>, tensor<5xf32>) outs(%extracted_slice_5 : tensor<?xf32>) -> tensor<?xf32>
            %12 = affine.apply #map1(%7)
            %13 = affine.apply #map1(%7)
            %inserted_slice = tensor.insert_slice %11 into %arg1[%arg0] [%7] [1] : tensor<?xf32> into tensor<3xf32>
            scf.yield %inserted_slice : tensor<3xf32>
          }
          flow.dispatch.tensor.store %6, %2, offsets = [0], sizes = [3], strides = [1] : tensor<3xf32> -> !flow.dispatch.tensor<readwrite:tensor<3xf32>>
          return
        }
      }
    }
  }
  func.func @matvec_static(%arg0: !hal.buffer_view, %arg1: !hal.buffer_view, %arg2: !hal.buffer_view) -> !hal.buffer_view attributes {iree.abi.stub} {
    %c0 = arith.constant 0 : index
    %c60 = arith.constant 60 : index
    %c20 = arith.constant 20 : index
    %c12 = arith.constant 12 : index
    %c3 = arith.constant 3 : index
    %c1 = arith.constant 1 : index
    %c553648160_i32 = arith.constant 553648160 : i32
    %c1_i32 = arith.constant 1 : i32
    %c5 = arith.constant 5 : index
    hal.buffer_view.assert<%arg0 : !hal.buffer_view> message("tensor") shape([%c3, %c5]) type(%c553648160_i32) encoding(%c1_i32)
    %0 = stream.tensor.import %arg0 : !hal.buffer_view -> tensor<3x5xf32> in !stream.resource<external>{%c60}
    hal.buffer_view.assert<%arg1 : !hal.buffer_view> message("tensor") shape([%c5]) type(%c553648160_i32) encoding(%c1_i32)
    %1 = stream.tensor.import %arg1 : !hal.buffer_view -> tensor<5xf32> in !stream.resource<external>{%c20}
    hal.buffer_view.assert<%arg2 : !hal.buffer_view> message("tensor") shape([%c3]) type(%c553648160_i32) encoding(%c1_i32)
    %2 = stream.tensor.import %arg2 : !hal.buffer_view -> tensor<3xf32> in !stream.resource<external>{%c12}
    %3 = stream.cmd.execute with(%0 as %arg3: !stream.resource<external>{%c60}, %1 as %arg4: !stream.resource<external>{%c20}, %2 as %arg5: !stream.resource<external>{%c12}) {
      stream.cmd.dispatch @matvec_static_dispatch_0::@matvec_static_dispatch_0_matvec_3x5[%c3, %c1] {
        ro %arg3[%c0 for %c60] : !stream.resource<external>{%c60},
        ro %arg4[%c0 for %c20] : !stream.resource<external>{%c20},
        rw %arg5[%c0 for %c12] : !stream.resource<external>{%c12}
      } attributes {hal.interface.bindings = [#hal.interface.binding<0, 0>, #hal.interface.binding<0, 1>, #hal.interface.binding<0, 2>]}
    } => !stream.timepoint
    %4 = stream.timepoint.await %3 => %2 : !stream.resource<external>{%c12}
    %5 = stream.tensor.export %4 : tensor<3xf32> in !stream.resource<external>{%c12} -> !hal.buffer_view
    return %5 : !hal.buffer_view
  }
}

