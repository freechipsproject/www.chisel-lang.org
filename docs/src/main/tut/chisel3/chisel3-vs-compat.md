---
layout: docs
title:  "chisel3 vs. compatibility mode"
section: "chisel3"
---

Chisel 3 supports "compatibility mode" which serves the purpose of bridging
the semantic gap between Chisel 2 and Chisel 3 with Chisel2-like semantics.
Chisel code using this mode depends on Chisel 3, yet the Scala code has
`import Chisel._` instead of the normal `import chisel3._`. This page serves
to document the differences for helping migrate from compatibility mode to the
safer and more modern Chisel 3 semantics.

### Connections

#### Compatibility mode

In compatibility mode, both connection operators `:=` and `<>` are actually the same.
They both are bidirectional and noncommutative--the right side will be treated as
the source and the left side will be treated as the sink.

```scala
import Chisel._
class MyModule extends Module {
  val io = new Bundle {
    val in = Decoupled(UInt(width = 4)).flip
    val out = Decoupled(UInt(width = 4))
  }
  io.out <> io.in // This works
  io.out := io.in // This is equivalent
  io.in <> io.out // This will error
}
```
For Bundles, elements with matching names will be connected and unmatching elements
will be ignored. For example:
```scala
import Chisel._
class BundleA extends Bundle {
  val foo = UInt(width = 8)
}
class BundleB extends Bundle {
  val foo = UInt(width = 8)
  val bar = UInt(width = 8)
}
class MyModule extends Module {
  val io = new Bundle {
    val in = (new BundleA).asInput
    val out = (new BundleB).asOutput
  }
  io.out <> io.in
  // Equivalent to
  io.out.foo := io.in.foo
  // bar is ignored because it doesn't match
} 
```

Furthermore, error detection and reporting is defered to FIRRTL compilation.

#### Chisel 3

In Chisel 3, `:=` is refered to as "monoconnect" and `<>` is called "biconnect".

* Monoconnect
`:=` treats everything on the left-hand side as a sink, even if the type is
bidirectional. This means it cannot be used to drive bidirectional output ports,
but can be used to drive wires from bidirectional inputs or outputs to "monitor"
the the full aggregate, ignoring directions.

* Biconnect
`<>` performs bidirectional connections and is commutative. At least one of the
arguments must be a port.
It will determine the correct leaf-level connections based on the directions of
its port arguments.
It cannot be used to connect two components _inside_ of a module.

```scala
import chisel3._
import chisel3.util._
class MyModule extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Decoupled(UInt(4.W)))
    val out = Decoupled(UInt(4.W))
    val x = Output(UInt(8.W))
  })
  io.out <> io.in // This works
  io.in <> io.out // So does this
  io.out := io.in // Error, cannot drive io.out.ready

  val w = Wire(Decoupled(UInt(4.W)))
  w := io.in  // This works, w can be seen as "monitoring" io.in
  4.U <> io.x // This also works but is stylistically suspect
}
```
In contrast to compatibility mode, every field of two connected Bundles must match.
For example:
```scala
import chisel3._
class BundleA extends Bundle {
  val foo = UInt(8.W)
}
class BundleB extends Bundle {
  val foo = UInt(8.W)
  val bar = UInt(8.W)
}
class MyModule extends Module {
  val io = new Bundle {
    val in = Input(new BundleA)
    val out = Output(new BundleB)
  }
  io.out <> io.in // This is an error because io.in.bar doesn't match
} 
```
Additionally, errors are caught during Chisel elaboration.

### Width Declaration

#### Compatibility mode
```scala
val x = UInt(width = 8)
```
#### Chisel 3
```scala
val x = UInt(8.W)
```
Notably, widths are now a type rather than a byname argument to the `UInt`
constructor.


### Literals

#### Compatibility mode
```scala
val x = UInt(2)
val y = SInt(-1, width = 8)
```
#### Chisel 3
```scala
val x = 2.U
val y = -1.S(8.W)
```

### Direction

#### Compatibility mode
```scala
class MyBundle {
  val foo = UInt(8.W).asInput
  val bar = UInt(8.W) // Default direction is Output
}
val a = UInt(INPUT, 8)
val b = Bool(OUTPUT)
val c = Bool() // Equivalent to above, default direction is OUTPUT
val d = new MyBundle
val e = (new Bundle).flip
```
#### Chisel 3
```scala
// Directions are required
class MyBundle {
  val foo = Input(UInt(8.W))
  val bar = Output(UInt(8.W))
}
val a = Input(UInt(8.W))
val b = Output(Bool())
val c = new MyBundle
val d = Flipped(new MyBundle)
```

### Registers
#### Compatibility mode
```scala
val a = UInt(width = 8)
val x = Reg(a)
```
#### Chisel 3
```scala
val a = UInt(width = 8)
val x = Reg(chiselTypeOf(a))

```

#### Compatibility mode
```scala
val a       = Reg (init = Vec.fill(2) { false.B })
```
#### Chisel 3
```scala
val a       = RegInit(VecInit(Seq.fill(2)(false.B)))

```

### Wires

New in Chisel3 is the need to connect all of your signals to a value, even if
that value is DontCare. Hence you might have to initialize this up front to DontCare

#### Compatibility mode
```scala
val a   = Wire(UInt(32.W))
a(1,0) := 2.U
```
#### Chisel 3
```scala
val a   = WireInit(UInt(32.W), DontCare)
a(1,0) := 2.U
```


### Module IO
#### Compatibility mode
```scala
class MyModule extends Module {
  val io = new Bundle { ... }
}
```
#### Chisel 3

In Chisel 3, all declared ports must be wrapped in `IO(...)`. For `Modules`,
this is just `val io`.
```scala
class MyModule extends Module {
  val io = IO(new Bundle { ... } )
}
```
But in Chisel 3, `MultiIOModules` have the ability to declare multiple "ios". 
While `val io` is not required, the implicit `clock` and `reset` are still there.
```scala
class MyModule2 extends MultiIOModule {
  val foo = IO(Input(UInt(8.W)))
}
```
Chisel 3 also has `RawModule` which allows arbitrary ports and has no implicit
`clock` nor `reset`.
```scala
class MyModule3 extends RawModule {
  val foo = IO(Output(Vec(8, Bool())))
}
```

### Utilities

Many constructs originally available via `import Chisel._` are now located in
`chisel3.util`. They can be imported 
