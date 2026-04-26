package main

import "core:fmt"
import "core:os"
import "core:slice"

the_basics :: proc() {
	fmt.println("\n# The Basics")

	// os.args
	if len(os.args) > 1 {
		fmt.printfln("Argument detected: %v", os.args[1])
	}

	// multiple vars like python
	a, b := 10, 20
	fmt.printfln("%v + %v = %v", a, b, a + b)

	// remainder operation?
	fmt.printfln("%d %% %d = %d", 15, 4, 15 % 4)
	fmt.printfln("%d %%%% %d = %d", 15, 4, 15 %% 4)
	fmt.printfln("%d %% %d = %d", -15, 4, -15 % 4)
	fmt.printfln("%d %%%% %d = %d", -15, 4, -15 %% 4)
	// x %% y is always >=0 !!
	// Cool.
}

control_flow :: proc() {
	fmt.println("\n# Control Flow")

	// Looping over string
	str := "Hello"
	for ch, i in str {
		fmt.printfln("%d: %c", i, ch)
	}
}

procedures :: proc() {
	fmt.println("\n# Procedures")

	// Named return
	// +) You can nest procedures which is cool
	calc :: proc() -> (ret: int) {
		// MISTAKE! ret := 10 XXX, ret is already defined
		ret = 10
		ret *= 10
		ret -= 10
		return
	}
	fmt.printfln("calc() = %d", calc())

	// Variadic input
	sum :: proc(args: ..int) -> (ret: int) {
		// MISTAKE! unfamiliar syntax
		// XXX ...args: int
		// ==> args: ..int
		ret = 0
		for arg in args {
			ret += arg
		}
		return
	}
	// You can print multiple things python-like
	fmt.println("sum(()) =", sum())
	fmt.println("sum(1, 2) =", sum(1, 2))
	fmt.println("sum(1, 2, 3, 4, 5) =", sum(1, 2, 3, 4, 5))

	// MISTAKE! use int instead of int
	// https://odin-lang.org/docs/overview/#basic-types
	// int is 'natural' register size
	// - easy on CPU
	// - pointer safe
	slice := []int{1, 3, 5, 7}
	fmt.println("sum(..slice) =", sum(..slice))

	// Explicit Overloading
	add_int :: proc(a: int, b: int) -> int {
		return a + b
	}
	add_f32 :: proc(a: f32, b: f32) -> f32 {
		return a + b
	}
	add :: proc {
		add_int,
		add_f32,
	}

	fmt.println("add(1, 3) =", add(1, 3))
	fmt.println("add(1.0, 3.0) =", add(1.0, 3.0))
}

struct_and_union :: proc() {
	fmt.println("\n# Struct And Union")

	Vector3 :: struct {
		// Cool syntax right there.
		// MISTAKE! use comma instead of semicolon.
		x, y, z: f32,
	}

	v: Vector3
	// You can just do this wow
	fmt.println(v)

	v2 := Vector3{1, 2, 3}
	fmt.println(v2)

	v3: Vector3
	v3 = {4, 5, 6}
	fmt.println(v3)

	v4: Vector3
	// v4 = {10, 20} <-- ERROR! too few values
	v4 = {
		x = 10,
		z = 30,
	}
	fmt.println(v4)

	/*
    a :: struct #align(4) {}
    b :: struct #packed {}
    c :: struct #raw_union {}
    */

	Number :: union {
		int,
		f32,
	}
	n1: Number = 10
	if i, ok := n1.(int); ok {
		fmt.println("n1.(int) =", i)
	}

	n2: Number = 20.0
	// MISTAKE! n2 XXX ==> n in n2
	// separates actual variable and type-casted variable.
	switch n in n2 {
	case int:
		fmt.println("n2.(int) =", n)
	case f32:
		fmt.println("n2.(f32) =", n)
	}
}

using_statement :: proc() {
	Vector3 :: struct {
		x, y, z: f32,
	}
	// Entity :: struct {
	// 	position: Vector3,
	// 	orientation: quaternion128,
	// }

	// foo1 :: proc(entity: ^Entity) {
	// 	using entity
	// 	fmt.println(position)
	// }

	Entity :: struct {
		using position: Vector3,
	}

	foo1 :: proc(entity: ^Entity) {
		fmt.println(entity.x)
	}
}

advanced_types :: proc() {
	fmt.println("\n# Advanced Types")

	// Type Alias
	My_Int :: int
	#assert(My_Int == int)

	// distinct type
	Vector3 :: distinct [3]int
	#assert(Vector3 != [3]int)

	// Fixed Array
	farr1 := [3]int{1, 2, 3}
	farr2 := [?]int{1, 3, 5, 7, 9}
	#assert(type_of(farr2) == [5]int)

	// ArrayPrograming!!
	arr1 := [?]int{1, 3, 5, 6, 8, 9}
	fmt.println("arr1 =", arr1)
	fmt.println("arr1 + 5 =", arr1 + 5)
	fmt.println("arr1 + arr1 =", arr1 + arr1)

	// Slice
	farr3 := [5]int{1, 2, 3, 4, 5}
	sli1 := farr3[1:3] // start & end
	sli2 := farr3[1:][:2] // offset & length
	fmt.println("farr3 =", farr3)
	fmt.println("sli1 =", sli1)
	fmt.println("sli2 =", sli2)
	sli3: []int // => sli3 == nil.
	// MISTAKE! #assert can only be used with constant expression.

	// Sorting slice
	farr4 := [5]int{5, 2, 4, 3, 1}
	slice.sort(farr4[:]) // Fixed array is not a valid input.
	fmt.println("farr4 =", farr4)

	// Dynamic Array (Like C's vector<>?)
	darr1: [dynamic]int
	// https://forum.odin-lang.org/t/does-dynamic-array-literal-must-be-deleted-using-delete-proc/1763?u=spaupa
	defer delete(darr1)
	append(&darr1, 10)
	append(&darr1, 20)
	fmt.println("darr1 =", darr1)

	// Make function (a great example of explicit override.)
	darr2 := make([dynamic]int, 0, 16) // len = 0, cap = 16
	defer delete(darr2)
	// IMPORTANT!
	// make(returns value) -> delete
	// new(returns pointer) -> free
	append(&darr2, 10)
	append(&darr2, 20)
	fmt.println("darr2 =", darr2)
	inject_at(&darr2, 1, 30) // injection
	fmt.println("darr2 =", darr2)
	inject_at(&darr2, 6, 40)
	fmt.println("darr2 =", darr2)
	assign_at(&darr2, 3, 50, 60, 70) // assignment
	fmt.println("darr2 =", darr2)
	pop(&darr2) // removing
	pop(&darr2)
	fmt.println("darr2 =", darr2)
	ordered_remove(&darr2, 0)
	fmt.println("darr2 =", darr2)
	unordered_remove(&darr2, 0) // Cool
	fmt.println("darr2 =", darr2)

	// +)
	// clear: removes all element, len -> 0
	// resize: changes len (and cap)
	// reserve: changes cap
	// shrink: sets cap to len(arr)

	darr3: [dynamic; 8]int
	// ^^^Fixed cap dynamic array.
	// no delete needed
	// remains on stack
}

main :: proc() {
	the_basics()
	control_flow()
	procedures()
	struct_and_union()
	// using_statement()
	advanced_types()
}
