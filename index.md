---
title: Home
layout: home
nav_order: 1
permalink: /
---

# OpenRISC Tutorials

These are tutorials for the OpenRISC processor. The simulations run on
different FPGA boards and simulators. Hence, the different tutorials
have different requirements, which you can find in the list below. If
you have downloaded the tutorials and are new to OpenRISC, you
probably want the real [quick start](#quick-start).

## Quick Start

This is the real quick start if you have downloaded and extracted the
tutorials. The output files are already part of what you have
downloaded, but you still need some tools. You can install prebuilt
versions of them:

    ./bootstrap-quick-start.sh

This downloads all free and open tools. Unfortunately, you will still
need to install closed (but free) tools from the FPGA vendors:

* [Altera Quartus Prime](#altera-quartus-prime) for Altera FPGAs
  ([DE0 nano](de0_nano/)).

You can now start with the [tutorials](#tutorials).

## Set Environment

Once you have installed the dependencies, you can do the following
tutorials. For convenience, you can set the environment variables for
all tools downloaded and installed automatically:

    source environment.sh

## Tutorials

There are simulations and FPGA boards supported, and some general
tutorials help you working with the OpenRISC ecosystem.

### Simulations

* [or1ksim](or1ksim/README.md), dependencies:
  * For running: [or1ksim](#or1ksim)
  * For building own software: [toolchain](#toolchain)

### FPGA Boards

* [Terasic DE0 nano board](de0_nano/README.md), dependencies:
  * For running: [OpenOCD](#openocd), [toolchain](#toolchain),
    [Altera Quartus Prime](#altera-quartus-prime)
  * For building hardware: [FuseSoC](#fusesoc)

### Debug Environment

The OpenRISC cpu, simulator and toolchain provide a full debugging
environment with gdb and OpenOCD.  At a low level this is provided with
[adv_debug_sys](https://github.com/olofk/adv_debug_sys) which provides
jtag interface for OpenOCD to talk to.  Much debugging can be done
directly in OpenOCD.  GDB communicates with OpenOCD to provide a familiar
debugging environment for programmers.  For more details see:

 * [Debugging OpenRISCi FPGAs with OpenOCD](docs/Debugging.html)

## Tools (partially required)

### OpenOCD

The [OpenOCD](http://www.openocd.org) version delivered with the Linux
distributions is most probably outdated. Hence, you can quickly
install a current version inside the tutorials:

	make openocd-download

In case you cannot start openocd, you may rebuilt it also:

    make openocd-build

### Toolchain

The OpenRISC software tool chain consists of all the tools require to
compile and manipulate software for the platform. Specifically, the
tool chain which is considered the development version will be used to
compile code to run on the "bare metal" system. That is, with no
underlying operating system.

You will need the toolchain if you want to compile software. The quick
way just to play around with this tutorials is to run from the base
path:

	make toolchain-baremetal

### FuseSoC

FuseSoC is an automated build environment and package manager for
OpenRISC. You can install it as described
[here](https://github.com/olofk/fusesoc) (recommended) or use the
prebuilt binaries:

	make fusesoc-download

You can also built it in this tutorial path:

    make fusesoc-build

### or1ksim

or1ksim is the OpenRISC instruction set simulator. You can download
the prebuilt binary:

    make or1ksim-download

or build it here:

    make or1ksim-build

### Linux

There is a prebuilt Linux image you can simply download:

    make linux-download

### Altera Quartus Prime

This is the software which compiles RTL and ultimately generates an
FPGA programming file. Unfortunately this software is closed source,
extremely large, and requires registration to download. However, it is
required.

For downloading the free version, visit the
[Altera website](http://dl.altera.com/?edition=lite) and
[download the latest version of Quartus Prime Lite](http://download.altera.com/akdlm/software/acdsinst/15.1/185/ib_tar/Quartus-lite-15.1.0.185-linux.tar). It
is 4.5GB in size and will obviously take a while to download. Once it
is downloaded, extract it and run the setup.sh file in there. Install
it to any location (e.g. `/opt/altera/lite`).

After installation add the following path (corrected for your
installation) to the search path:

	export PATH=/opt/altera/lite/15.1/quartus/bin/:$PATH

*Note:* Make sure you select to include the Cyclone IV E device
 families during installation.
