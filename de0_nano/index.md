---
title: De0 Nano
layout: page
parent: FuseSoC
---

## Prerequisites

#### System

 * An x86 Linux workstation
 * The `curl` command line utilities
 * OpenOCD
 * The quartus FPGA design software
 * `fusesoc` - The [FuseSoC build system](../fusesoc.html).
 * `or1k-elf-` Toolchain as installed in our [newlib tutorial](../newlib.html).

#### Files

 * [hello.c](../sw/hello/hello.c) - A Hello World test program.
 * [timer.c](../sw/timer/timer.c) - A baremetal example using the OpenRISC timer api's provided by newlib.

## DE0 Nano

To confirm you have all of the required tools installed check with the following:

To run the demo you need:

* `quartus_pgm` in your `PATH`, check with

        which quartus_pgm

* `openocd` in your `PATH` and `OPENOCD` set, check with

        openocd --version
        echo $OPENOCD

* `or1k-elf-gdb` in your `PATH`, check with

        or1k-elf-gdb --version

### Setup the board

First you need to setup the board, by connecting the USB cable to your
computer. If you want to use UART, an extra dongle is needed. Any
USB-UART adapter can be used. You need to connect it to the header on
the bottom of the board as depicted below.

![uart](doc/uart.png "Connect UART to board")

### Setup the Environment

To get started we will want to have a directory with all
of our build files in one place.

```bash
mkdir /tmp/or1k-de0nano
cd /tmp/or1k-de0nano

curl -L -O https://openrisc.io/tutorials/sw/hello/hello.c
curl -L -O https://openrisc.io/tutorials/sw/timer/timer.c

fusesoc library add de0_nano https://github.com/olofk/de0_nano.git
```

### Build the FPGA bitstream

```bash
fusesoc build de0_nano
```

### Program the FPGA bitstream

Once the board is setup, you can download the FPGA bitstream by
running

```bash
fusesoc pgm de0_nano
```

### Start the OpenOCD daemon

In one terminal execute the following command:

	openocd -s ${OPENOCD}/share/openocd/scripts/ -f interface/altera-usb-blaster.cfg -f ../or1k-dev.tcl 

### Run software with gdb

From a second terminal you can now run gdb, for example to run the
timer example:

	or1k-elf-gdb timer.elf

In gdb execute the following steps:

	target remote :50001
	load
	set $npc=0x100
	continue

You should see the LEDs counting and UART output once a second.

## (Re-)build the hardware

You can rebuilt the hardware by running:

```bash
fusesoc build de0_nano
```

## (Re-)build the software

Some example software is available, that you can (re-)build for the
DE0 nano board by running

```bash
CFLAGS=-mboard=de0_nano -DDE0_NANO

or1k-elf-gcc -g -o hello.elf ${CFLAGS} ../sw/hello/hello.c
or1k-elf-gcc -g -o timer.elf ${CFLAGS} ../sw/timer/timer.c
```
