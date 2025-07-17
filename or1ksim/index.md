---
title: or1ksim
layout: page
parent: Platforms
nav_order: 2
---

# Prerequisites

#### System

 - An x86 Linux workstation
 - The `curl` and `telnet` command line utilities

#### Files

We will download these below.

 - [or1ksim.cfg](or1ksim.cfg) - config needed for or1ksim
 - [or1ksim-2025-04-27.tar.gz](https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz) - The OpenRISC simulator source code
 - [timer.c](./sw/timer/timer.c) - timer program

# or1ksim Tutorial

The or1ksim program is the OpenRISC [instruction set simulator](https://en.wikipedia.org/wiki/Instruction_set_simulator) which
provides accurate tracing. A simulator is a fast way to debug and ensure
your software works before deploying it to real hardware.

In this tutorial we will cover getting and building or1ksim, and building simple
programs to run on or1ksim.

We break this tutorial down into parts:

 - Downloading the pieces
 - Compiling a program
 - Running a program
 - Interacting with the simulator

## Downloading the Pieces

To get started we will create a temporary directly and setup our environment, if
you plan to do a lot of OpenRISC development consider adding these tools to your
`PATH` permanently.

To get everything you need run:

```bash
mkdir /tmp/or1ksim/
cd /tmp/or1ksim/

# Download or1ksim, toolchain and a test project
curl -L -O https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz
curl -L -O https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-elf-15.1.0-20250621.tar.xz

# Download example programs
curl -L -O https://openrisc.io/tutorials/sw/hello/hello.c
curl -L -O https://openrisc.io/tutorials/sw/timer/timer.c

# Download an example config for or1ksim
curl -L -O https://github.com/stffrdhrn/or1k-utils/raw/refs/heads/master/or1ksim.cfg

# Extract everything
tar -xf or1ksim-2025-04-27.tar.gz
tar -xf or1k-elf-15.1.0-20250621.tar.xz

export PATH=$PATH:$PWD/or1k/bin:$PWD/or1k-elf/bin
```

## Compiling a program

To compile programs for or1ksim we use the newlib baremetal toolchain. Binaries
produced by this can run directly on systems with no Operating System.  We use
the `-mboard=` option to provide newlib with the proper options needed to target
or1ksim.  This includes RAM size, address loctions for UART and UART baud rates.

```bash
CFLAGS="-mboard=or1ksim-uart"
or1k-elf-gcc -g -Og $CFLAGS -o hello.elf hello.c
or1k-elf-gcc -g -Og $CFLAGS -o timer.elf timer.c
```

## Run hello world

To run the demo you need `or1k-elf-sim` in your `PATH`, check with:

```bash
or1k-elf-sim --version
```

We can then run our program with the following:

```bash
or1k-elf-sim -f or1ksim.cfg hello.elf
```

You can find that the last output is `Hello World!`. or1ksim can be
much more verbose and give you a full execution trace:

	or1k-elf-sim -f or1ksim.cfg hello.elf -t

This is of course a lot slower and the simulation exits after a
while. You can finish the simulation before with `CTRL+C`, which will
take you to the simulators command line (`(sim) `). You can exit the
command line with `quit`.

## Run the timer example

	or1k-elf-sim -f or1ksim.cfg timer.elf

In the terminal you can see an UART output every *simulated*
second. You can quit this as described before.

## Next steps

Also checkout our tutorial on how to run [Linux on or1ksim](../docs/linux-on-or1ksim.html).

## Further Reading

 - [openrisc/or1ksim](https://github.com/openrisc/or1ksim) - The home page and git repo
 - [Releases](https://github.com/openrisc/or1ksim/releases) - Nightly build and point release
