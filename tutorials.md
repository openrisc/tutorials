---
layout: page
title: On the Web
---

This tutorial section contains guides and information that helps new
OpenRISC users to get started more easily.

The Official openrisc tutorials and docs:

-   [Debugging OpenRISC][] running on a platform with gdb
-   [Building Linux][] for OpenRISC
-   [De0 Nano][] running barebone software
-   [Or1ksim][] simulating OpenRISC programs on the simulator
-   [Building a musl toolchain](https://github.com/openrisc/musl-cross/wiki)
    which includes `or1k-linux-musl-gcc`.
-   [Building a newlib toolchain](https://openrisc.io/newlib/building.html)
    which includes `or1k-elf-gcc` and `or1k-elf-gdb`.

Material for beginners to soft cores on FPGA:

-   [Sven-Åke Andersson][] has written a comprehensive [blog on OpenRISC
    for newbies][], which offers a guide to the complete design flow.

Guides to the toolchain:

-   [Jeremy Bennett][]. [Embecosm Application Note 2][]. *The OpenCores
    OpenRISC 1000 Simulator and Tool Chain: Installation Guide*. Issue
    3, November 2008.
-   Robert Guenzel. [Embecosm Application Notes 1 and 2 and MacOS
    10.4][]

SystemC interfaces:

-   [Jeremy Bennett][]. [Embecosm Application Note 1][]. *Building a
    Loosely Timed SoC Model with OSCI TLM 2.0: A Case Study Using an
    Open Source ISS and Linux 2.6 Kernel.* Issue 2, May 2010.
-   Robert Guenzel. [Embecosm Application Notes 1 and 2 and MacOS
    10.4][]

Tutorials on how to implement OR1200 on Altera FPGA and Xilinx FPGA.
Credits go to [Resarch Group Digital Techniques][], Hogeschool voor
Wetenschap & Kunst, Campus de Nayer

-   Altera HW tutorial [local copy][] of the PDF and possibly [updated
    version][] at the original site.
-   Xilinx HW tutorial [local copy][1] of the PDF and possibly [updated
    version][2] at the original site.

Tutorials on how to implement OR1200 on Xilinx Spartan-6 FPGA.

-   OpenRISC implemented on the Digilent Atlys board [blog on
    OpenRISC for newbies][1]

Tutorials on how to implement OR1200 on Xilinx and Altera FPGAs using
MinSoC.

-   MinSoC Tutorials [openrisc on xilinx][2], [minsoc.com start][3]

Tutorials on compiling and running software in or1ksim:

-   Simple C program compilation and execution from rte.se: [Writing an
    application program][]

A Dynamic Reconfigurable OpenRISC Framework called Proteus : [Proteus
Framework][]

  [Debugging OpenRISC]: https://github.com/openrisc/tutorials/blob/master/docs/Debugging.md
  [Building Linux]:https://github.com/openrisc/tutorials/blob/master/docs/Linux.md
  [De0 Nano]:https://github.com/openrisc/tutorials/tree/master/de0_nano
  [Or1ksim]:https://github.com/openrisc/tutorials/tree/master/or1ksim
  [Sven-Åke Andersson]: User:svenand "wikilink"
  [blog on OpenRISC for newbies]: http://www.rte.se/blog/blogg-modesty-corex/openrisc-1200-soft-processor
  [Jeremy Bennett]: User:Jeremybennett "wikilink"
  [Embecosm Application Note 2]: http://www.embecosm.com/download/ean2.html
  [Embecosm Application Notes 1 and 2 and MacOS 10.4]: http://chschroeder.gamiro.de/rg/or1ksim_macOS10.4.pdf
  [Embecosm Application Note 1]: http://www.embecosm.com/download/ean1.html
  [Resarch Group Digital Techniques]: http://emsys.denayer.wenk.be/
  [local copy]: http://cdn.opencores.org/pdf/openrisc-HW-tutorial-Altera.pdf
  [updated version]: http://emsys.denayer.wenk.be/empro/openrisc-HW-tutorial-Altera.pdf
  [1]: http://cdn.opencores.org/pdf/openrisc-HW-tutorial-Xilinx.pdf
  [2]: http://emsys.denayer.wenk.be/empro/openrisc-HW-tutorial-Xilinx.pdf
  [3]: http://www.minsoc.com/1_0:start
  [Writing an application program]: http://www.rte.se/blog/blogg-modesty-corex/writing-application-program
  [Proteus Framework]: http://proteus-project.org/
