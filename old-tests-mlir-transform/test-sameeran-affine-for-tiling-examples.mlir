// RUN: mlir-opt %s -split-input-file -affine-loop-tile="tile-size=32" | FileCheck %s

// -----

// CHECK-DAG: [[$UB:#map[0-9]+]] = affine_map<(d0) -> (d0 + 32)>
// CHECK-DAG: [[$UB_MIN:#map[0-9]+]] = affine_map<(d0) -> (d0 + 32, 50)>
// CHECK-DAG: [[$ID:#map[0-9]+]] = affine_map<(d0) -> (d0)>
// CHECK-DAG: [[$ID_PLUS_21:#map[0-9]+]] = affine_map<(d0) -> (d0 + 21)>

// CHECK-LABEL: func @loop_tiling()
// CHECK-NEXT:   affine.for %{{.*}} = 0 to 256 step 32 {
// CHECK-NEXT:     affine.for %{{.*}} = 0 to 512 step 32 {
// CHECK-NEXT:       affine.for %{{.*}} = 0 to 1024 step 32 {
// CHECK-NEXT:         affine.for %[[I:.*]] = [[$ID]](%{{.*}}) to [[$UB]](%{{.*}}) {
// CHECK-NEXT:           affine.for %[[J:.*]] = [[$ID]](%{{.*}}) to [[$UB]](%{{.*}}) {
// CHECK-NEXT:             affine.for %[[K:.*]] = [[$ID]](%{{.*}}) to [[$UB]](%{{.*}}) {
// CHECK-NEXT:               "test.foo"(%[[I]], %[[J]], %[[K]])
// CHECK-NEXT:             }
// CHECK-NEXT:           }
// CHECK-NEXT:         }
// CHECK-NEXT:       }
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT:   affine.for %{{.*}} = 0 to 50 step 32 {
// CHECK-NEXT:     affine.for %[[X:.*]] = [[$ID]](%{{.*}}) to min [[$UB_MIN]](%{{.*}}) {
// CHECK-NEXT:       "test.bar"(%[[X]], %[[X]])
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: affine.for %[[I:.*]] = 0 to 21 step 32 {
// CHECK-NEXT:   affine.for %[[Y:.*]] = [[$ID]](%[[I]]) to [[$ID_PLUS_21]](%[[I]])  {
// CHECK-NEXT:     "test.foobar"(%[[Y]])
// CHECK-NEXT:   }
// CHECK-NEXT: }
// CHECK-NEXT:  return


func.func @loop_tiling() {
  affine.for %i = 0 to 256 {
    affine.for %j = 0 to 512 {
      affine.for %k = 0 to 1024 {
        "test.foo"(%i, %j, %k) : (index, index, index) -> ()
      }
    }
  }

  affine.for %x = 0 to 50 {
    "test.bar"(%x, %x) : (index, index) -> ()
  }

  // Intra-tile loop won't need a min expression.
  affine.for %y = 0 to 21 {
    "test.foobar"(%y) : (index) -> ()
  }

  return
}

// -----

