---
layout: docs
title:  "Stage/Phase"
section: "firrtl"
---

# Overview

**Stage/Phase** concerns a large, infrastructural refactor of Chisel, FIRRTL, and related projects.
At a high level, this reorganizes tools in the Chisel/FIRRTL stack as disjoint **Stages** composed of **Phases**.

New *Stages* (e.g., a C++ hardware DSL front end) can then be interfaced with existing *Phases*.
New *Stages* can be composed from existing *Phases*.
Existing *Stages* can be extended with the addition of new *Phases*.

In effect, this changes the overall architecture of Chisel and FIRRTL to:

1. Provide a common means for upstream tools to communicate with downstream tools
1. Remove mutability from tool options
1. Expose a common way for defining dependencies between *Phases*
1. Enable easy scheduling of *Phases*

While this is colloquially known as *Stage/Phase*[^naming], this can more broadly be defined as the *Chisel/FIRRTL Hardware Compiler Framework*.
This can be compared to the efforts and aims of the *LLVM Compiler Infrastructure Project*.

# Background

Chisel is a hardware domain specific language embedded in Scala that generates FIRRTL IR[^ir].
The FIRRTL compiler reads FIRRTL IR and optimizes it, does user-defined custom transformation, and "lowers" the IR to remove complicated structures.
The FIRRTL compiler's Verilog emitter then converts low FIRRTL IR to Verilog.

*In effect, Chisel, FIRRTL, and the Verilog emitter are a classic [3-stage compiler](https://en.wikipedia.org/wiki/Compiler#Three-stage_compiler_structure) applied to Verilog generation.*

Internally, the FIRRTL compiler is organized as a sequence of mathematical transforms on a circuit and its annotations (metadata associated with zero or more circuit components).
A FIRRTL [`Transform`](https://www.chisel-lang.org/api/firrtl/latest/firrtl/Transform.html) is "controlled" by its annotations.

As an example, the operation of the [`InlineInstances` transform](https://www.chisel-lang.org/api/firrtl/latest/firrtl/passes/InlineInstances.html) is modulated by the presence of [`InlineAnnotation`s](https://www.chisel-lang.org/api/firrtl/latest/firrtl/passes/InlineAnnotation.html).
However, `InlineInstances` can also be controlled from FIRRTL's command line via `-fil/--inline <circuit>[.<module>[.<instance>]][,...]`.
**This strongly implies that annotations and command line arguments are fungible.**
More accurately, command line arguments are functions that produce annotations.

Observing annotation/option fungibility, it follows that annotations could serve as the basis for communication of option information to tools in addition to FIRRTL transforms.
*Stage/Phase* is then a generalization of FIRRTL's transforms to operate solely on a sequence of annotations---an [`AnnotationSeq`](https://www.chisel-lang.org/api/firrtl/latest/firrtl/AnnotationSeq.html).

# Stages and Phases

The *Stage/Phase* refactor involves definition of two new packages in FIRRTL:

1. `firrtl.options` which adds *Stage/Phase*
1. `firrtl.stage` which uses `firrtl.options` to implement FIRRTL as a *Stage*

## Phase

```scala
abstract class Phase {
  def transform(a: AnnotationSeq): AnnotationSeq
}
```

## Stage

```scala
abstract class Stage extends Phase {
  val shell: Shell

  def run(a: AnnotationSeq): AnnotationSeq

  final def transform(a: AnnotationSeq): AnnotationSeq = {
    /* Preprocessing, "run", and postprocessing */
  }
}
```

## Type Hierarchy

A *Phase* is a mathematical transformation of an `AnnotationSeq`.
A *Stage* is a *Phase* that also exposes a command line interface.

## Shell

`HasShellOptions`

## Registration

## Type Hierarchy

A `TransformLike[A]` is a mathematical transformation over some type `A`.
A `Translator[A, B]` is a `TransformLike[A]` that internally performs a transform over some other type `B`.

# Dependency API

# References

# Archaeology

The basis for this refactor stemmed from a comment in a Chisel development meeting about the difference between a command line option and an annotation.

[^naming]: The *Stage/Phase* name comes from the structure of the hardware compiler framework: a hardware compiler consists of a number of stages (front-end, middle-end, and back-end) organized into a sequence of phases.
[^ir]: Intermediate Representation
