// RUN: mlir-opt -allow-unregistered-dialect %s -pass-pipeline='func.func(scf-parallel-loop-fusion)' -split-input-file | FileCheck %s

func.func @fuse_empty_loops() {
  %c2 = arith.constant 2 : index
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  scf.parallel (%i, %j) = (%c0, %c0) to (%c2, %c2) step (%c1, %c1) {
    scf.yield
  }
  scf.parallel (%i, %j) = (%c0, %c0) to (%c2, %c2) step (%c1, %c1) {
    scf.yield
  }
  return
}
// CHECK-LABEL: func @fuse_empty_loops
// CHECK:        [[C2:%.*]] = arith.constant 2 : index
// CHECK:        [[C0:%.*]] = arith.constant 0 : index
// CHECK:        [[C1:%.*]] = arith.constant 1 : index
// CHECK:        scf.parallel ([[I:%.*]], [[J:%.*]]) = ([[C0]], [[C0]])
// CHECK-SAME:       to ([[C2]], [[C2]]) step ([[C1]], [[C1]]) {
// CHECK:          scf.yield
// CHECK:        }
// CHECK-NOT:    scf.parallel

// -----
