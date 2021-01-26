---
layout: home
title: "Chisel/FIRRTL"
section: "home"
technologies:
 - first: ["Scala", "Chisel is powered by Scala and brings all the power of object-oriented and functional programming to type-safe hardware design and generation."]
 - second: ["Chisel", "Chisel, the Chisel standard library, and Chisel testing infrastructure enable agile, expressive, and reusable hardware design methodologies."]
 - third: ["FIRRTL", "The FIRRTL circuit compiler starts after Chisel and enables backend (FPGA, ASIC, technology) specialization, automated circuit transformation, and Verilog generation."]
---

Chisel is a **hardware description language** that enables digital designers to work at a *higher level* to write reusable circuit generators that produce synthesizable Verilog HDL.
Chisel enables modern software engineering practices including:

- Object oriented programming
- Functional programming
- Polymorphism
- Parametric polymorphism
- First class function support

This means that Chisel is both "just like Verilog" with expected hardware abstractions of ports, registers, and connections:

<script src="https://scastie.scala-lang.org/seldridge/L1XPzd99Tw2NWjdpYn6t9w/3.js"></script>

Leveraging software engineering, Chisel is also a powerful generator language:

<script src="https://scastie.scala-lang.org/seldridge/D0bO9NryRCK1qNvz566Utg/56.js"></script>
