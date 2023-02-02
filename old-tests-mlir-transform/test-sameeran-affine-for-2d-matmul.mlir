// RUN: mlir-opt %s -split-input-file -test-affine-parametric-tile | FileCheck %s

// -----

// CHECK-DAG: [[LBI0:#map[0-9]+]] = affine_map<(d0)[s0] -> (d0 * s0)>
// CHECK-DAG: [[UBI0:#map[0-9]+]] = affine_map<(d0)[s0, s1] -> (d0 * s1 + s1, s0)>
// CHECK-DAG: [[UBO0:#map[0-9]+]] = affine_map<()[s0, s1] -> (s0 ceildiv s1)>

// CHECK: func @tile_with_symbolic_loop_upper_bounds([[ARG0:%arg[0-9]+]]: index, [[ARG1:%arg[0-9]+]]: index{{.*}}){{.*}}
// CHECK:        affine.for [[ARG2:%arg[0-9]+]] = 0 to [[UBO0]](){{.*}}[[ARG0]]{{.*}}
// CHECK-NEXT:     affine.for [[ARG3:%arg[0-9]+]] = 0 to [[UBO0]](){{.*}}[[ARG1]]{{.*}}
// CHECK-NEXT:       affine.for %[[I0:.*]] = [[LBI0]]{{.*}}[[ARG2]]{{.*}}[[ARG0]]{{.*}} to min [[UBI0]]{{.*}}[[ARG2]]{{.*}}[[ARG0]]{{.*}}
// CHECK-NEXT:         affine.for %[[I1:.*]] = [[LBI0]]{{.*}}[[ARG3]]{{.*}}[[ARG1]]{{.*}} to min [[UBI0]]{{.*}}[[ARG3]]{{.*}}[[ARG1]]{{.*}}
// CHECK-NEXT:           affine.store %{{.*}}, %{{.*}}[%[[I0]], %[[I1]]] : memref<?x?xf32>
// CHECK-NEXT:           affine.for %[[I2:.*]] = 0 to %{{.*}} {
// CHECK-NEXT:             affine.load %{{.*}}%[[I0]], %[[I2]]
// CHECK-NEXT:             affine.load %{{.*}}%[[I2]], %[[I1]]
// CHECK-NEXT:             arith.mulf
// CHECK-NEXT:             affine.load %{{.*}}%[[I0]], %[[I1]]
// CHECK-NEXT:             arith.addf
// CHECK-NEXT:             affine.store %{{.*}}%[[I0]], %[[I1]]



func.func @tile_with_symbolic_loop_upper_bounds(%t9 : index, %t10: index, %arg0: memref<?x?xf32>, %arg1: memref<?x?xf32>, %arg2: memref<?x?xf32>) {
  %cst = arith.constant 0.000000e+00 : f32
  %c0 = arith.constant 0 : index
  %0 = memref.dim %arg0, %c0 : memref<?x?xf32>
  affine.for %i0 = 0 to %0 {
    affine.for %i1 = 0 to %0 {
      affine.store %cst, %arg2[%i0, %i1] : memref<?x?xf32>
      affine.for %i2 = 0 to %0 {
        %1 = affine.load %arg0[%i0, %i2] : memref<?x?xf32>
        %2 = affine.load %arg1[%i2, %i1] : memref<?x?xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = affine.load %arg2[%i0, %i1] : memref<?x?xf32>
        %5 = arith.addf %4, %3 : f32
        affine.store %5, %arg2[%i0, %i1] : memref<?x?xf32>
      }
    }
  }
  return
}

// -----

