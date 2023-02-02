#matmul_accesses = [
  affine_map<(m, n) -> (m, n)>,
  affine_map<(m, n) -> (n)>,
  affine_map<(m, n) -> (m)>
]
#matmul_trait = {
  indexing_maps = #matmul_accesses,
  iterator_types = ["parallel",  "reduction"]
}


!type_vector_out = tensor<3xf32>
!type_matrix = tensor<3x5xf32>
!type_vector = tensor<5xf32>


func.func @my_matvec(%A: !type_matrix,  %B: !type_vector, %C: !type_vector_out ) -> !type_vector_out  {
 %3 = linalg.generic #matmul_trait
ins(%A,  %B: !type_matrix, !type_vector)
  outs(%C : !type_vector_out) {
  ^bb0(%a: f32, %b: f32, %c: f32) :
    %d = arith.mulf %a, %b: f32
    %e = arith.addf %c, %d: f32
    linalg.yield %e : f32
} -> !type_vector_out 
return %3 : !type_vector_out 
}

