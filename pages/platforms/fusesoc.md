---
title: FuseSoC
layout: page
nav_order: 3
parent: Platforms
---

The FuseSoC build system, dependency manager and fpga integration platform
allows for easy creation of OpenRISC systems.  If is featured in our
[Quick Start with Docker Images](../quick_start.html) as our main fpga development
platform.  For in depth documentation see:

 * [FuseSoC Manual](https://fusesoc.readthedocs.io/en/stable/index.html) - Full documentation.
 * [olofk/fusesoc](https://github.com/olofk/fusesoc) - The github project

## Installing FuseSoC

FuseSoC is a python program and can be installed using `pip`.  The easiest way to get started is
simplly:

```
pip3 install --upgrade --user fusesoc
```

## Available SoCs

In our tutorials we will mainly use the `mor1kx-generic` fusesoc
SoC but there are a few more out there.  Also available are:

  * [stffrdhrn/mor1kx-generic](https://github.com/stffrdhrn/mor1kx-generic) - A generic SoC that can be used as a starting point.
    It supports both [mor1kx](https://github.com/openrisc/mor1kx) and [marocchino](https://github.com/openrisc/or1k_marocchino) CPU cores
    with both [iverilog](https://bleyer.org/icarus/) and [verilator](https://www.veripool.org/verilator/) simulation backends.
  * [olofk/de0_nano](https://github.com/olofk/de0_nano) - An SoC for the [Terasic De0 Nano](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=593) FPGA development board.
  * [stffrdhrn/de0_nano-multicore](https://github.com/stffrdhrn/de0_nano-multicore) - A De0 Nano SoC supporting multiple mor1kx cores used to test SMP Linux.
  * [orpsoc-cores](https://github.com/openrisc/orpsoc-cores/tree/master/systems) - There are also several SoC's that have not yet been converted from the orpsoc-cores to fusesoc stand alone cores structure.  These include support for de1, de2 and atlys FPGA boards.

If you have developed fusesoc support for a board not mentioned here please mail the [OpenRISC mailing](mailto:linux-openrisc@vger.kernel.org)
list or create a PR for this tutorial and we can add it here.

