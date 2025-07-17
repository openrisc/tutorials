---
title: or1ksim
layout: page
parent: Platforms
nav_order: 2
---

# Prerequisites

#### System

 - An x86 Linux workstation
 - The `curl` command line utility

#### Files

We will download these below.

 - [or1ksim.cfg](or1ksim.cfg) - config needed for or1ksim
 - [hello.c](../sw/hello/hello.c) - hello world program
 - [timer.c](../sw/timer/timer.c) - timer program
 - [or1ksim-2025-04-27.tar.gz](https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz) - The OpenRISC simulator

# or1ksim Tutorial

The or1ksim program is the OpenRISC [instruction set simulator](https://en.wikipedia.org/wiki/Instruction_set_simulator) which
provides accurate tracing of OpenRISC programs. A simulator is a fast way to debug and ensure
your software works before deploying it to real hardware.

In this tutorial we will cover getting or1ksim, and building simple programs to
run on or1ksim.

We break this tutorial down into parts:

 - Downloading the pieces
 - Compiling programs
 - Running programs
 - Interacting with the simulator

## Downloading the Pieces

To get started we will create a temporary directly and setup our environment, if
you plan to do a lot of OpenRISC development consider adding these tools to your
`PATH` permanently.

To get everything run:

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

## Compiling Programs

To compile programs for or1ksim we use the newlib baremetal toolchain. Binaries
produced by this can run directly on systems with no Operating System.  We use
the `-mboard=` option to provide newlib with the proper options needed to target
or1ksim.  This includes RAM size, address loctions for UART and UART baud rates.

```bash
CFLAGS="-mboard=or1ksim-uart"
or1k-elf-gcc -g -Og $CFLAGS -o hello.elf hello.c
or1k-elf-gcc -g -Og $CFLAGS -o timer.elf timer.c
```

The `-mboard=` option tells the toolchain to link in our board settings, you can see
the available boards by looking in the toolchain native lib directory:

```
/tmp/or1ksim $ ls -l or1k-elf/or1k-elf/lib/libboard-*
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-atlys.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-de0_nano.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-ml501.a
-rw-r--r--. 1 shorne shorne 1482 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-optimsoc.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-or1ksim.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-or1ksim-uart.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-ordb1a3pe1500.a
-rw-r--r--. 1 shorne shorne 1178 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-ordb2a.a
-rw-r--r--. 1 shorne shorne 1258 Jun 21 07:04 or1k-elf/or1k-elf/lib/libboard-orpsocrefdesign.a
```

## Running Programs

To run the demo you need `or1k-elf-sim` in your `PATH`, check with:

```bash
or1k-elf-sim --version
```

We can then run our first *Hello Wolrd* example program with the following:

```bash
or1k-elf-sim -f or1ksim.cfg hello.elf
```

If everything worked we will see the last output is `Hello World!`. or1ksim can be
much more verbose and give you a full execution trace:

	or1k-elf-sim -f or1ksim.cfg hello.elf -t

This is of course a lot slower and the simulation exits after a
while. You can finish the simulation before with `CTRL+C`, which will
take you to the simulators command line (`(sim) `). You can exit the
command line with `quit`.

### Run the timer example

A more advanced example is the timer example which uses `or1k_timer_*` APIs from the
newlib or1k [timer module](https://openrisc.io/newlib/docs/html/group__or1k__timer.html) to setup a 1 second timer.

	or1k-elf-sim -f or1ksim.cfg timer.elf

In the terminal you can see an UART output every *simulated*
second. You can quit the simulation as described before.

## Interacting with the simulator

When we press `CTRL+C` when running the timer example the simulator will
continue to run.  We can interact with the simulator console at this time.

Some example commands to check are:

 - `help` - show help about all commands
 - `r` - show all registers
 - `info` - show all system info
 - `stall` - resumes the program

### Example output

```
(sim) info
VR   : 0x12000001  UPR  : 0x00000619
SR   : 0x00008203
MACLO: 0x00000000  MACHI: 0x00000000
EPCR0: 0x00006688  EPCR1: 0x00000000
EEAR0: 0x00000000  EEAR1: 0x00000000
ESR0 : 0x00008203  ESR1 : 0x00000000
TTMR : 0x600f4240  TTCR : 0x00000081
PICMR: 0x00000003  PICSR: 0x00000000
PPC:   0x00002294  NPC   : 0x00000000

..
SPR_ITLBMR way 0 set 59 =  |  | ITLBMR_VPN = 00000000
SPR_ITLBTR way 0 set 59 = ITLBTR_PPN = 00000000
SPR_ITLBMR way 0 set 60 =  |  | ITLBMR_VPN = 00000000
SPR_ITLBTR way 0 set 60 = ITLBTR_PPN = 00000000
SPR_ITLBMR way 0 set 61 =  |  | ITLBMR_VPN = 00000000
SPR_ITLBTR way 0 set 61 = ITLBTR_PPN = 00000000
SPR_ITLBMR way 0 set 62 =  |  | ITLBMR_VPN = 00000000
SPR_ITLBTR way 0 set 62 = ITLBTR_PPN = 00000000
SPR_ITLBMR way 0 set 63 =  |  | ITLBMR_VPN = 00000000
SPR_ITLBTR way 0 set 63 = ITLBTR_PPN = 00000000

(sim) r
00002294:                13fffffd  l.bf -3 (executed) [cycle 166500035, #149819510]
00002298:                15000000  l.nop 0 (next insn) (delay insn)
GPR00: 00000000  GPR01: 007fdff8  GPR02: 007fe000  GPR03: 00000001
GPR04: 90000000  GPR05: 00009588  GPR06: 00000000  GPR07: 00000000
GPR08: 00008b5c  GPR09: 00002290  GPR10: 00000000  GPR11: 00000042
GPR12: 00000000  GPR13: 000069ec  GPR14: 00000000  GPR15: ffffffff
GPR16: 00000042  GPR17: 00010000  GPR18: 00000000  GPR19: 00008001
GPR20: 00000000  GPR21: 00000011  GPR22: 00000000  GPR23: fffffffd
GPR24: 00000000  GPR25: 000069dc  GPR26: 00000000  GPR27: ffffefff
GPR28: 00000000  GPR29: 00000000  GPR30: 00000000  GPR31: 00009394  flag: 1
(sim) stall
A second elapsed
A second elapsed
A second elapsed
A second elapsed
```

## Next steps

Also checkout our tutorial on how to run [Linux on or1ksim](../docs/linux-on-or1ksim.html).

## Further Reading

 - [openrisc/or1ksim](https://github.com/openrisc/or1ksim) - The home page and git repo
 - [or1ksim Releases](https://github.com/openrisc/or1ksim/releases) - Nightly build and point release
