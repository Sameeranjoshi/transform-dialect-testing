// RUN: mlir-opt %s -pass-pipeline='func.func(scf-parallel-loop-tiling{parallel-loop-tile-sizes=1,4})' -split-input-file | FileCheck %s
// -----

func.func @tile_nested_in_non_ploop() {
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  scf.for %i = %c0 to %c2 step %c1 {
    scf.for %j = %c0 to %c2 step %c1 {
      scf.parallel (%k, %l) = (%c0, %c0) to (%c2, %c2) step (%c1, %c1) {
      }
    }
  }
  return
}

// CHECK-LABEL: func @tile_nested_in_non_ploop
// CHECK:         scf.for
// CHECK:           scf.for
// CHECK:             scf.parallel
// CHECK:               scf.parallel
// CHECK:               }
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
