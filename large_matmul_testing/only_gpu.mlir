// -----// IR Dump After LLVMGPULowerExecutableTarget (iree-llvmgpu-lower-executable-target) //----- //
hal.executable.variant public @cuda_nvptx_fb, target = <"cuda", "cuda-nvptx-fb", {target_arch = "sm_80"}> {
  hal.executable.export public @_matmul_2048x512x1024_f32_f32_dispatch_0_matmul_2048x512x1024 ordinal(0) layout(#hal.pipeline.layout<push_constants = 0, sets = [<0, bindings = [<0, storage_buffer, ReadOnly>, <1, storage_buffer, ReadOnly>, <2, storage_buffer>]>]>) attributes {translation_info = #iree_codegen.translation_info<LLVMGPUMatmulTensorCore pipeline_depth = 4>, workgroup_size = [64 : index, 2 : index, 1 : index]} {
  ^bb0(%arg0: !hal.device, %arg1: index, %arg2: index, %arg3: index):
    %c16 = arith.constant 16 : index
    %c64 = arith.constant 64 : index
    %c1 = arith.constant 1 : index
    hal.return %c16, %c64, %c1 : index, index, index
  }
  builtin.module {
    func.func @_matmul_2048x512x1024_f32_f32_dispatch_0_matmul_2048x512x1024() {
      %c0 = arith.constant 0 : index
      %c16 = arith.constant 16 : index
      %c1 = arith.constant 1 : index
      %c32 = arith.constant 32 : index
      %c2 = arith.constant 2 : index
      %c48 = arith.constant 48 : index
      %c3 = arith.constant 3 : index
      %c960 = arith.constant 960 : index
      %c64 = arith.constant 64 : index
      %c4 = arith.constant 4 : index
      %c1024 = arith.constant 1024 : index
      %c8 = arith.constant 8 : index
      %cst = arith.constant 0.000000e+00 : f32
      %0 = gpu.subgroup_mma_constant_matrix %cst : !gpu.mma_matrix<16x16xf32, "COp">
      %1 = gpu.thread_id  x
      %2 = gpu.thread_id  y
      %3 = gpu.thread_id  z
      %alloc = memref.alloc() : memref<32x36xf32, #gpu.address_space<workgroup>>
      %alloc_0 = memref.alloc() : memref<4x32x20xf32, #gpu.address_space<workgroup>>
      %alloc_1 = memref.alloc() : memref<4x16x36xf32, #gpu.address_space<workgroup>>
      %4 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<2048x1024xf32>
      memref.assume_alignment %4, 64 : memref<2048x1024xf32>
      %5 = hal.interface.binding.subspan set(0) binding(1) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<1024x512xf32>
      memref.assume_alignment %5, 64 : memref<1024x512xf32>
      %6 = hal.interface.binding.subspan set(0) binding(2) type(storage_buffer) alignment(64) offset(%c0) : memref<2048x512xf32>
      memref.assume_alignment %6, 64 : memref<2048x512xf32>
      %workgroup_id_x = hal.interface.workgroup.id[0] : index
      %workgroup_id_y = hal.interface.workgroup.id[1] : index
      gpu.barrier {__pipelining_first_stage__}
      %7 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 4 - (s1 floordiv 4) * 16)>()[%c0, %1]
      %8 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %9 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %10 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 4) * 16)>()[%1]
      %11 = nvgpu.device_async_copy %4[%8, %7], %alloc_0[%c0, %9, %10], 4 {__pipelining_first_stage__} : memref<2048x1024xf32> to memref<4x32x20xf32, #gpu.address_space<workgroup>>
      %12 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 8 + s3 * 16 + s1 floordiv 8)>()[%c0, %1, %2, %3]
      %13 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
      %14 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
      %15 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
      %16 = nvgpu.device_async_copy %5[%12, %13], %alloc_1[%c0, %14, %15], 4 {__pipelining_first_stage__} : memref<1024x512xf32> to memref<4x16x36xf32, #gpu.address_space<workgroup>>
      %17 = nvgpu.device_async_create_group %11, %16 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %18 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 4 - (s1 floordiv 4) * 16)>()[%c16, %1]
      %19 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %20 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %21 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 4) * 16)>()[%1]
      %22 = nvgpu.device_async_copy %4[%19, %18], %alloc_0[%c1, %20, %21], 4 {__pipelining_first_stage__} : memref<2048x1024xf32> to memref<4x32x20xf32, #gpu.address_space<workgroup>>
      %23 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 8 + s3 * 16 + s1 floordiv 8)>()[%c16, %1, %2, %3]
      %24 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
      %25 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
      %26 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
      %27 = nvgpu.device_async_copy %5[%23, %24], %alloc_1[%c1, %25, %26], 4 {__pipelining_first_stage__} : memref<1024x512xf32> to memref<4x16x36xf32, #gpu.address_space<workgroup>>
      %28 = nvgpu.device_async_create_group %22, %27 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %29 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 4 - (s1 floordiv 4) * 16)>()[%c32, %1]
      %30 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %31 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %32 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 4) * 16)>()[%1]
      %33 = nvgpu.device_async_copy %4[%30, %29], %alloc_0[%c2, %31, %32], 4 {__pipelining_first_stage__} : memref<2048x1024xf32> to memref<4x32x20xf32, #gpu.address_space<workgroup>>
      %34 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 8 + s3 * 16 + s1 floordiv 8)>()[%c32, %1, %2, %3]
      %35 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
      %36 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
      %37 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
      %38 = nvgpu.device_async_copy %5[%34, %35], %alloc_1[%c2, %36, %37], 4 {__pipelining_first_stage__} : memref<1024x512xf32> to memref<4x16x36xf32, #gpu.address_space<workgroup>>
      %39 = nvgpu.device_async_create_group %33, %38 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %40 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 4 - (s1 floordiv 4) * 16)>()[%c48, %1]
      %41 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %42 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %43 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 4) * 16)>()[%1]
      %44 = nvgpu.device_async_copy %4[%41, %40], %alloc_0[%c3, %42, %43], 4 {__pipelining_first_stage__} : memref<2048x1024xf32> to memref<4x32x20xf32, #gpu.address_space<workgroup>>
      %45 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 8 + s3 * 16 + s1 floordiv 8)>()[%c48, %1, %2, %3]
      %46 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
      %47 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
      %48 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
      %49 = nvgpu.device_async_copy %5[%45, %46], %alloc_1[%c3, %47, %48], 4 {__pipelining_first_stage__} : memref<1024x512xf32> to memref<4x16x36xf32, #gpu.address_space<workgroup>>
      %50 = nvgpu.device_async_create_group %44, %49 {__pipelining_first_stage__}
      %51:9 = scf.for %arg0 = %c0 to %c1024 step %c16 iter_args(%arg1 = %0, %arg2 = %17, %arg3 = %28, %arg4 = %39, %arg5 = %50, %arg6 = %c0, %arg7 = %c1, %arg8 = %c2, %arg9 = %c3) -> (!gpu.mma_matrix<16x16xf32, "COp">, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, index, index, index, index) {
        %62 = arith.cmpi slt, %arg0, %c960 : index
        nvgpu.device_async_wait %arg2 {numGroups = 3 : i32}
        gpu.barrier
        %63 = affine.apply affine_map<()[s0] -> (s0 * 16)>()[%2]
        %64 = gpu.subgroup_mma_load_matrix %alloc_0[%arg6, %63, %c0] {leadDimension = 20 : index} : memref<4x32x20xf32, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x8xf32, "AOp">
        %65 = gpu.subgroup_mma_load_matrix %alloc_0[%arg6, %63, %c8] {leadDimension = 20 : index} : memref<4x32x20xf32, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x8xf32, "AOp">
        %66 = affine.apply affine_map<()[s0] -> ((s0 floordiv 32) * 16)>()[%1]
        %67 = gpu.subgroup_mma_load_matrix %alloc_1[%arg6, %c0, %66] {leadDimension = 36 : index} : memref<4x16x36xf32, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<8x16xf32, "BOp">
        %68 = gpu.subgroup_mma_load_matrix %alloc_1[%arg6, %c8, %66] {leadDimension = 36 : index} : memref<4x16x36xf32, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<8x16xf32, "BOp">
        %69 = gpu.subgroup_mma_compute %64, %67, %arg1 : !gpu.mma_matrix<16x8xf32, "AOp">, !gpu.mma_matrix<8x16xf32, "BOp"> -> !gpu.mma_matrix<16x16xf32, "COp">
        %70 = gpu.subgroup_mma_compute %65, %68, %69 : !gpu.mma_matrix<16x8xf32, "AOp">, !gpu.mma_matrix<8x16xf32, "BOp"> -> !gpu.mma_matrix<16x16xf32, "COp">
        gpu.barrier {__pipelining_first_stage__}
        %71 = arith.addi %arg0, %c64 : index
        %72 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 4 - (s1 floordiv 4) * 16)>()[%71, %1]
        %73 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
        %74 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
        %75 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 4) * 16)>()[%1]
        %76 = arith.addi %arg0, %c64 : index
        %77 = affine.apply affine_map<(d0) -> ((d0 floordiv 16) mod 4)>(%76)
        %78 = arith.select %62, %c4, %c0 : index
        %79 = nvgpu.device_async_copy %4[%73, %72], %alloc_0[%77, %74, %75], 4, %78 : memref<2048x1024xf32> to memref<4x32x20xf32, #gpu.address_space<workgroup>>
        %80 = arith.addi %arg0, %c64 : index
        %81 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 8 + s3 * 16 + s1 floordiv 8)>()[%80, %1, %2, %3]
        %82 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
        %83 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
        %84 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
        %85 = arith.select %62, %c4, %c0 : index
        %86 = nvgpu.device_async_copy %5[%81, %82], %alloc_1[%77, %83, %84], 4, %85 : memref<1024x512xf32> to memref<4x16x36xf32, #gpu.address_space<workgroup>>
        %87 = nvgpu.device_async_create_group %79, %86 {__pipelining_first_stage__}
        scf.yield %70, %arg3, %arg4, %arg5, %87, %arg7, %arg8, %arg9, %77 : !gpu.mma_matrix<16x16xf32, "COp">, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, index, index, index, index
      }
      %52 = affine.apply affine_map<()[s0] -> (s0 * 16)>()[%2]
      %53 = affine.apply affine_map<()[s0] -> ((s0 floordiv 32) * 16)>()[%1]
      gpu.subgroup_mma_store_matrix %51#0, %alloc[%52, %53] {leadDimension = 36 : index} : !gpu.mma_matrix<16x16xf32, "COp">, memref<32x36xf32, #gpu.address_space<workgroup>>
      gpu.barrier
      %54 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8)>()[%1, %2, %3]
      %55 = affine.apply affine_map<()[s0] -> (s0 * 4 - (s0 floordiv 8) * 32)>()[%1]
      %56 = vector.transfer_read %alloc[%54, %55], %cst {in_bounds = [true]} : memref<32x36xf32, #gpu.address_space<workgroup>>, vector<4xf32>
      %57 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 8 + s2 * 16 + s3 * 32 + s0 floordiv 8)>()[%1, %2, %3, %workgroup_id_y]
      %58 = affine.apply affine_map<()[s0, s1] -> (s0 * 4 + s1 * 32 - (s0 floordiv 8) * 32)>()[%1, %workgroup_id_x]
      vector.transfer_write %56, %6[%57, %58] {in_bounds = [true]} : vector<4xf32>, memref<2048x512xf32>
      %59 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 8 + s2 * 16 + s0 floordiv 8 + 16)>()[%1, %2, %3]
      %60 = vector.transfer_read %alloc[%59, %55], %cst {in_bounds = [true]} : memref<32x36xf32, #gpu.address_space<workgroup>>, vector<4xf32>
      %61 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 8 + s2 * 16 + s3 * 32 + s0 floordiv 8 + 16)>()[%1, %2, %3, %workgroup_id_y]
      vector.transfer_write %60, %6[%61, %58] {in_bounds = [true]} : vector<4xf32>, memref<2048x512xf32>
      gpu.barrier
      return
    }
  }
}

// -----// IR Dump After LLVMGPULowerExecutableTarget (iree-llvmgpu-lower-executable-target) //----- //
hal.executable.variant public @cuda_nvptx_fb, target = <"cuda", "cuda-nvptx-fb", {target_arch = "sm_80"}> {
  hal.executable.export public @_matmul_3456x1024x2048_f16_f16_dispatch_0_matmul_3456x1024x2048 ordinal(0) layout(#hal.pipeline.layout<push_constants = 0, sets = [<0, bindings = [<0, storage_buffer, ReadOnly>, <1, storage_buffer, ReadOnly>, <2, storage_buffer>]>]>) attributes {translation_info = #iree_codegen.translation_info<LLVMGPUMatmulTensorCore pipeline_depth = 4>, workgroup_size = [64 : index, 2 : index, 1 : index]} {
  ^bb0(%arg0: !hal.device, %arg1: index, %arg2: index, %arg3: index):
    %c32 = arith.constant 32 : index
    %c108 = arith.constant 108 : index
    %c1 = arith.constant 1 : index
    hal.return %c32, %c108, %c1 : index, index, index
  }
  builtin.module {
    func.func @_matmul_3456x1024x2048_f16_f16_dispatch_0_matmul_3456x1024x2048() {
      %c0 = arith.constant 0 : index
      %c32 = arith.constant 32 : index
      %c1 = arith.constant 1 : index
      %c64 = arith.constant 64 : index
      %c2 = arith.constant 2 : index
      %c96 = arith.constant 96 : index
      %c3 = arith.constant 3 : index
      %c1920 = arith.constant 1920 : index
      %c128 = arith.constant 128 : index
      %c8 = arith.constant 8 : index
      %c2048 = arith.constant 2048 : index
      %c16 = arith.constant 16 : index
      %cst = arith.constant 0.000000e+00 : f16
      %0 = gpu.subgroup_mma_constant_matrix %cst : !gpu.mma_matrix<16x16xf16, "COp">
      %1 = gpu.thread_id  x
      %2 = gpu.thread_id  y
      %3 = gpu.thread_id  z
      %alloc = memref.alloc() : memref<32x40xf16, #gpu.address_space<workgroup>>
      %alloc_0 = memref.alloc() : memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %alloc_1 = memref.alloc() : memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %4 = hal.interface.binding.subspan set(0) binding(0) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<3456x2048xf16>
      memref.assume_alignment %4, 64 : memref<3456x2048xf16>
      %5 = hal.interface.binding.subspan set(0) binding(1) type(storage_buffer) alignment(64) offset(%c0) flags(ReadOnly) : memref<2048x1024xf16>
      memref.assume_alignment %5, 64 : memref<2048x1024xf16>
      %6 = hal.interface.binding.subspan set(0) binding(2) type(storage_buffer) alignment(64) offset(%c0) : memref<3456x1024xf16>
      memref.assume_alignment %6, 64 : memref<3456x1024xf16>
      %workgroup_id_x = hal.interface.workgroup.id[0] : index
      %workgroup_id_y = hal.interface.workgroup.id[1] : index
      gpu.barrier {__pipelining_first_stage__}
      %7 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 8 - (s1 floordiv 4) * 32)>()[%c0, %1]
      %8 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %9 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %10 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
      %11 = nvgpu.device_async_copy %4[%8, %7], %alloc_0[%c0, %9, %10], 8 {__pipelining_first_stage__} : memref<3456x2048xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %12 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 16 + s3 * 32 + s1 floordiv 4)>()[%c0, %1, %2, %3]
      %13 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
      %14 = nvgpu.device_async_copy %5[%12, %13], %alloc_1[%c0, %9, %10], 8 {__pipelining_first_stage__} : memref<2048x1024xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %15 = nvgpu.device_async_create_group %11, %14 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %16 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 8 - (s1 floordiv 4) * 32)>()[%c32, %1]
      %17 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %18 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %19 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
      %20 = nvgpu.device_async_copy %4[%17, %16], %alloc_0[%c1, %18, %19], 8 {__pipelining_first_stage__} : memref<3456x2048xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %21 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 16 + s3 * 32 + s1 floordiv 4)>()[%c32, %1, %2, %3]
      %22 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
      %23 = nvgpu.device_async_copy %5[%21, %22], %alloc_1[%c1, %18, %19], 8 {__pipelining_first_stage__} : memref<2048x1024xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %24 = nvgpu.device_async_create_group %20, %23 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %25 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 8 - (s1 floordiv 4) * 32)>()[%c64, %1]
      %26 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %27 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %28 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
      %29 = nvgpu.device_async_copy %4[%26, %25], %alloc_0[%c2, %27, %28], 8 {__pipelining_first_stage__} : memref<3456x2048xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %30 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 16 + s3 * 32 + s1 floordiv 4)>()[%c64, %1, %2, %3]
      %31 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
      %32 = nvgpu.device_async_copy %5[%30, %31], %alloc_1[%c2, %27, %28], 8 {__pipelining_first_stage__} : memref<2048x1024xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %33 = nvgpu.device_async_create_group %29, %32 {__pipelining_first_stage__}
      gpu.barrier {__pipelining_first_stage__}
      %34 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 8 - (s1 floordiv 4) * 32)>()[%c96, %1]
      %35 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %36 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %37 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
      %38 = nvgpu.device_async_copy %4[%35, %34], %alloc_0[%c3, %36, %37], 8 {__pipelining_first_stage__} : memref<3456x2048xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %39 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 16 + s3 * 32 + s1 floordiv 4)>()[%c96, %1, %2, %3]
      %40 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
      %41 = nvgpu.device_async_copy %5[%39, %40], %alloc_1[%c3, %36, %37], 8 {__pipelining_first_stage__} : memref<2048x1024xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
      %42 = nvgpu.device_async_create_group %38, %41 {__pipelining_first_stage__}
      %43:9 = scf.for %arg0 = %c0 to %c2048 step %c32 iter_args(%arg1 = %0, %arg2 = %15, %arg3 = %24, %arg4 = %33, %arg5 = %42, %arg6 = %c0, %arg7 = %c1, %arg8 = %c2, %arg9 = %c3) -> (!gpu.mma_matrix<16x16xf16, "COp">, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, index, index, index, index) {
        %51 = arith.cmpi slt, %arg0, %c1920 : index
        nvgpu.device_async_wait %arg2 {numGroups = 3 : i32}
        gpu.barrier
        %52 = affine.apply affine_map<()[s0] -> (s0 * 16)>()[%2]
        %53 = gpu.subgroup_mma_load_matrix %alloc_0[%arg6, %52, %c0] {leadDimension = 40 : index} : memref<4x32x40xf16, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x16xf16, "AOp">
        %54 = gpu.subgroup_mma_load_matrix %alloc_0[%arg6, %52, %c16] {leadDimension = 40 : index} : memref<4x32x40xf16, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x16xf16, "AOp">
        %55 = affine.apply affine_map<()[s0] -> ((s0 floordiv 32) * 16)>()[%1]
        %56 = gpu.subgroup_mma_load_matrix %alloc_1[%arg6, %c0, %55] {leadDimension = 40 : index} : memref<4x32x40xf16, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x16xf16, "BOp">
        %57 = gpu.subgroup_mma_load_matrix %alloc_1[%arg6, %c16, %55] {leadDimension = 40 : index} : memref<4x32x40xf16, #gpu.address_space<workgroup>> -> !gpu.mma_matrix<16x16xf16, "BOp">
        %58 = gpu.subgroup_mma_compute %53, %56, %arg1 : !gpu.mma_matrix<16x16xf16, "AOp">, !gpu.mma_matrix<16x16xf16, "BOp"> -> !gpu.mma_matrix<16x16xf16, "COp">
        %59 = gpu.subgroup_mma_compute %54, %57, %58 : !gpu.mma_matrix<16x16xf16, "AOp">, !gpu.mma_matrix<16x16xf16, "BOp"> -> !gpu.mma_matrix<16x16xf16, "COp">
        gpu.barrier {__pipelining_first_stage__}
        %60 = arith.addi %arg0, %c128 : index
        %61 = affine.apply affine_map<()[s0, s1] -> (s0 + s1 * 8 - (s1 floordiv 4) * 32)>()[%60, %1]
        %62 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
        %63 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
        %64 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
        %65 = arith.addi %arg0, %c128 : index
        %66 = affine.apply affine_map<(d0) -> ((d0 floordiv 32) mod 4)>(%65)
        %67 = arith.select %51, %c8, %c0 : index
        %68 = nvgpu.device_async_copy %4[%62, %61], %alloc_0[%66, %63, %64], 8, %67 : memref<3456x2048xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
        %69 = arith.addi %arg0, %c128 : index
        %70 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s0 + s2 * 16 + s3 * 32 + s1 floordiv 4)>()[%69, %1, %2, %3]
        %71 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
        %72 = arith.select %51, %c8, %c0 : index
        %73 = nvgpu.device_async_copy %5[%70, %71], %alloc_1[%66, %63, %64], 8, %72 : memref<2048x1024xf16> to memref<4x32x40xf16, #gpu.address_space<workgroup>>
        %74 = nvgpu.device_async_create_group %68, %73 {__pipelining_first_stage__}
        scf.yield %59, %arg3, %arg4, %arg5, %74, %arg7, %arg8, %arg9, %66 : !gpu.mma_matrix<16x16xf16, "COp">, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, !nvgpu.device.async.token, index, index, index, index
      }
      %44 = affine.apply affine_map<()[s0] -> (s0 * 16)>()[%2]
      %45 = affine.apply affine_map<()[s0] -> ((s0 floordiv 32) * 16)>()[%1]
      gpu.subgroup_mma_store_matrix %43#0, %alloc[%44, %45] {leadDimension = 40 : index} : !gpu.mma_matrix<16x16xf16, "COp">, memref<32x40xf16, #gpu.address_space<workgroup>>
      gpu.barrier
      %46 = affine.apply affine_map<()[s0, s1, s2] -> (s1 * 16 + s2 * 32 + s0 floordiv 4)>()[%1, %2, %3]
      %47 = affine.apply affine_map<()[s0] -> (s0 * 8 - (s0 floordiv 4) * 32)>()[%1]
      %48 = vector.transfer_read %alloc[%46, %47], %cst {in_bounds = [true]} : memref<32x40xf16, #gpu.address_space<workgroup>>, vector<8xf16>
      %49 = affine.apply affine_map<()[s0, s1, s2, s3] -> (s1 * 16 + s2 * 32 + s3 * 32 + s0 floordiv 4)>()[%1, %2, %3, %workgroup_id_y]
      %50 = affine.apply affine_map<()[s0, s1] -> (s0 * 8 + s1 * 32 - (s0 floordiv 4) * 32)>()[%1, %workgroup_id_x]
      vector.transfer_write %48, %6[%49, %50] {in_bounds = [true]} : vector<8xf16>, memref<3456x1024xf16>
      gpu.barrier
      return
    }
  }
}

