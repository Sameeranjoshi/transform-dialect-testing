// RUN: mlir-opt %s --split-input-file | FileCheck %s

// A few flags for testing and playing 
// 1. Print Generic form of MLIR = -mlir-print-op-generic
// 2. Print the stacktrace  = -mlir-print-stacktrace-on-diagnostic
// 3. Hides the array constants  = -large-mlir-elide-elementsattrs-if-larger=1
//    for readability of IR.
// 4. Treating same file with seperate compilation units. = --split-input-file
// 5. If using unregistered dialect use  = --allow-unregistered-dialect


// -----
// Calling a function.

// Takes 2 builtin type arguments.
//func.func @test(%arg0:i8, %arg1:i8) -> i8 {
//    ^bb0(%arg0:i8):
//        //arg1.print()
//    ^bb1(%arg1:i8):
//        //arg2.print()
//}

func.func @callme(%0:i32, %1:i32) -> (i32, i32) {
    func.return %0, %1 : i32, i32
}

// takes nothing as argument.
func.func @anothertest() -> () {
^bb0:
    %a = arith.constant 100 : i32
    %b = arith.constant 200 : i32
    %r12:2 = func.call @callme (%a, %b) : (i32, i32) -> (i32, i32)
    %r23:2 = func.call @callme(%r12#0, %r12#1) : (i32, i32) -> (i32, i32)
    cf.br ^bb1
^bb2: 
    cf.br ^bb1
^bb1:
    %c = arith.constant 022 : i32
    cf.br ^bb2
}
// -----
// A end of BB has always a region, region can be break/return/(I guess yeild can also be).
// Doesn't work needs terminator.

func.func @noterminator() {
}

// -----
// Simple main function - ? Is there no main function ? I think no, all top level is module.
// module.

module @someemptymodule {

}

// -----
// A module is defined inside `builtin` dialect.

builtin.module @somebuiltinmodule {
    // This is same as above.
}

// -----
// Module with no name.
builtin.module {
    // This module has no name defined, so there is no implitic name in generated IR.
}

// -----
// A module is nothing but a `builtin` dialect Operation, so 
// syntax - dialect.Op (name)? attribute {sym_name = "", sym_visibility=""} {body}
// This is error because there are 2 `sym_name` for same operation.
builtin.module @what attributes { 
  sym_name = "mynameisempty", 
  builtin.sym_visibility = ""
} {
    // Body
}

// -----
// Not using module name but using the `sym_name` attribute.
builtin.module attributes {
    sym_name = "noname"
} {}

// -----
// Let's move on to Function - Using `Func` dialect.

// Func.func should return at least
builtin.module @modulewithFunc{
    func.func @iamafunction() -> () {
        // I do nothing
    }
}

// -----
builtin.module @modulewithFunc{
    func.func @ireturn() -> () {
        // I do nothing, but return something/ has a terminator at the end.
        func.return
    }
}

// -----
builtin.module @modulewithFunc{
    func.func @funcwitharguments(%ar1 : i32, %ar2 : i64, %ar3 : tensor <10x10xi32> ){
        //`func.func` has attribute called `function_type` this represents the arguments and return types. (arg) -> (ret)
        // This arguments become the arguments of the first Basic Block (BB).
        func.return
    }
}

// -----
// The arguments in `Func.func` should match those of the First Basic Block.(bb0).
builtin.module @modulewithFunc {
    func.func @funcblockwitharguments (){
        ^bb0(%ar1 : i32, %ar2 : i64, %ar3 : tensor <10x10xi32>):
            func.return
    }
}

// -----
// Now let's play with function arguments.
// input argument is returned with changes.
// funcname(a1:d1, a2:d2, a3:d3, ...) -> (d1, d2, d3, ...)
builtin.module @somemodulewithfunc {
   func.func @ihavearguments(%a1 : vector <4x4xf32>) -> (vector<4x4xf32>,  vector<4x4xf32>) {
       func.return %a1, %a1 : vector<4x4xf32> , vector<4x4xf32>
   }
}

// -----
// You can't do this in a block, either write the ^bb0 or skip it and let the system do it's job.
func.func @ff1(%arg0 : i32, %arg1 : ui32, %arg2 : si64) {
^bb0(%arg0 : i32, %arg1 : ui32, %arg2 : si64):
    func.return
}

// -----
// If want to specify block name then use this version, note the function arguments are not named.
func.func @ff2(i32, ui32, si64) {
^bb0(%arg0 : i32, %arg1 : ui32, %arg2 : si64):
    func.return
}

// -----
// All basic types you might need frequently in one argument list.
// integer types
// index type
// function type
// nonetype - ? Not sure how to write this. - %arg - no type specified, there are no test cases as well.
// Opaque type - 
func.func @ff3 (%arg0:i32, %arg1: index, %arg2 : (i32)->(i32)){
    func.return
}


// -----
// opaque types - Using this type you can use data types from other unregistered dialects
// Not sure how to write llvm types.
func.func @opaqtyp (%arg1 : !emitc.opaque<"std::string">) {
    func.return
}

// -----
// RankedTensorType 
func.func @tensortypes (%arg1 : tensor<f32>, %arg2 : tensor<10 x i32>, %arg3 : tensor <10 x 10 x 10 x i32>, %arg33 : tensor<? x ? x ? x i32>) {
    func.return
}

// -----// -----
// RankedTensorType  - remember that X needs to be having space.
func.func @tensortypes1 (%arg2 : tensor<0xi32>) {
    func.return
}


// RankedTensorType  - Tensors can have 2 parameters 
// 1. shape, type 
// 2. encoding - attribute
#SparseVector = #sparse_tensor.encoding<{dimLevelType = ["compressed"]}>
// Looks like the encodings are only on `sparse_tensor` dialect.
func.func @tensortypes2 (%arg2 : tensor<0xi32, #SparseVector>) {
    func.return
}

// -----
// UnrankedTensorType 
func.func @unrankedtensor (%arg1 : tensor<* x i32>){
    func.return
}

// ----- 
// Tupletype. - Can hold different data types.
func.func @tuples(%arg1 : tuple<>, %arg2 : tuple<f32>, %arg3 : tuple<f32, i32, tensor<10 x f32>>) {
    func.return
}

// -----
// VectorType
// arg2 - scalable-length vector
func.func @vectortypes (%arg0 : vector<10 x i32>, %arg1 : vector<100 x 100 x index>, %arg2 : vector<[4] x i64>){
    func.return
}


// -----
// REGIONS
func.func @regionsyntax (){
 // This is a region attached to a Operation.
 // This region's first BB is called entry block. whereas others are called blocks.
 // The `entry block` must not have any predecessors/ it shouldn't be successor of any other block in region.
 ^bb0: 
    func.return
 ^bb1: 
    func.return    
}

// -----
// Ops not allowed in region.
func.func @region1 (){
    ^bb0:
        func.return
    // Adding something apart from blocks in a region is not allowed.
    // block - operation - block  = Not allowed.
    func.return
    ^bb1:
        func.return
}

// -----
// Perfect region
func.func @region2 () {
    ^bb0:
        func.return
    ^bb1:
        func.return
    ^bb2:
        %c100 = arith.constant 100 : index
        func.return
}


// -----
// A BB can't nest another BB, it should be made of operation list itself.
func.func @region3 (){
    ^bb2:
        ^bb3:
            func.return
    func.return
}

// -----
// Type-system
// Type-aliases | Builtin types | dialect types

// 1. Type aliases
// Define alias
!thisismyownaliasfori32 = i32
!thisisvectoralias = vector<4 x i32>
func.func @typealias(%arg1 : !thisisvectoralias) {
    // Use it.
    %10 = arith.constant 10 : !thisismyownaliasfori32
    func.return
}

// -----
// 2. dialect types.
// Define alias to LLVM type system
!llvm_ptr_f32 = !llvm.ptr<i32>
func.func @typealias_dialect_based(%arg1 : !llvm_ptr_f32) {
    // Use it.
    %10 = arith.constant 10 : i32
    func.return
}

// -----
// ATTRIBUTES
// 1. ArrayAttr
func.func @attr1(){
    func.return
}

// -----
// BLOCKS
func.func @simple_block_cf_cfg(i64, i1) -> i64 {
^bb0(%a: i64, %cond: i1):
  cf.cond_br %cond, ^bb1, ^bb2
^bb1:
  cf.br ^bb3(%a: i64)    // Branch passes %a as the argument

^bb2:
  %b = arith.addi %a, %a : i64
  cf.br ^bb3(%b: i64)    // Branch passes %b as the argument

// ^bb3 receives an argument, named %c, from predecessors
// and passes it on to bb4 along with %a. %a is referenced
// directly from its defining operation and is not passed through
// an argument of ^bb3.
^bb3(%c: i64):
  cf.br ^bb4(%c, %a : i64, i64)

^bb4(%d : i64, %e : i64):
  %0 = arith.addi %d, %e : i64
  return %0 : i64   // Return is also a terminator.
}

// -----
// OPERATION basics
// an operation is identified by a unique string (e.g. dim, tf.Conv2d, x86.repmovsb, ppc.eieio, etc),
// return zero or more results,
// take zero or more operands,
// has a dictionary of attributes, 
// has zero or more successors, 
// and zero or more enclosed regions.
func.func @somefuncwithattributes(%arg1 : i32) -> (i32) {
    %addedvalues = arith.addi %arg1, %arg1 : i32
    func.return %addedvalues : i32
}
