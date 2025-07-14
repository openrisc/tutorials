---
title: QEMU
layout: home
nav_order: 2
---

The objective of this tutorial is to run a Hello World program on QEMU. The prerequisite is to have a [cross-compiler](https://openrisc.io/software) for OpenRISC 1000 (or1k). And don't forget to add it to the `PATH` .

# Intro
QEMU is a generic emulator that supports various target architectures. [It can be used to emulate a 32-bit OpenRISC CPU](https://www.qemu.org/docs/master/system/target-openrisc.html).\
QEMU has two different modes of emulation: user mode and system emulation mode. The user mode only allows you to run programs compiled for the target architecture, while the system mode emulates the complete hardware. 

# User Mode
## Install QEMU
Install the pre-built package from your distribution's package manager. On Ubuntu, run\
`sudo apt install qemu-user-static`  
for running statically linked binaries OR\
`sudo apt install qemu-user`  
for running dynamically linked binaries. Personally, I am using the static version for this tutorial.
The way this mode of emulation works is that QEMU captures the target's (or1k in this case) system calls and translates them into your host system's. 

## Cross-compile the Program
`hello.c` is included in this directory. Compile it using the cross-compiler you have. For me, the command is\
`or1k-none-linux-musl-gcc hello.c -static -o hello`.

And check if the output file type looks correct using `file` command.
```
file hello
hello: ELF 32-bit MSB executable, OpenRISC, version 1 (SYSV), statically linked, with debug_info, not stripped
```

Note that `-static` flag was used when compiling. Without this, the output will be a dynamically linked ELF, which will give an error, ```qemu-or1k-static: Could not open '/lib/ld-musl-or1k.so.1': No such file or directory```, if we try to run it using `qemu-or1k-static`.

## Run the Program
```
qemu-or1k-static hello
```
If the output is `Hello World!`, then everything is working correctly.

# System Emulation
The following exercise will make a very simple bare-metal or1k system with our hello.c program as the "kernel". 

## Install QEMU (From Source)
Running QEMU full-system emulation means you need to run a different QEMU binary than what you used for the user mode. On Ubuntu, you can run\
`sudo apt install qemu-system`. **However**, this will download a quite old version of QEMU (likely version 8.2.2) and this does not work with this tutorial. This tutorial was tested to be working on QEMU version 9.2.2.

Because of this, we show how to build QEMU below:
1. Grab a tar ball from https://download.qemu.org/ for the version you like (preferably 9.2.2 or higher)
```
curl -O -L https://download.qemu.org/qemu-9.2.2.tar.xz
```
2. Untar it
```
tar -xf qemu-9.2.2.tar.xz
```
3. Go inside the root directory and run configure
```
cd qemu-9.2.2 && ./configure
```

Note that during this step, you may encounter a lot of issues with [dependencies required for QEMU](https://www.qemu.org/docs/master/devel/build-environment.html#debian-ubuntu).

4. Finally, run `make`. The generated binaries should be found inside `/build`.

## Cross-compile the Program
Since we want to run `hello.c` bare-metal (no OS like linux to handle the execution), we need to use the newlib toolchain. [Download the toolchain](https://openrisc.io/software#newlib-toolchain) and untar it like we did for QEMU.
```
curl -O -L https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-elf-15.1.0-20250621.tar.xz
tar -xf or1k-elf-15.1.0-20250621
export PATH=$PATH:<path of or1k-elf bin folder>
```
> One important thing to note is that compiling a C program using a bare-metal cross-toolchain like `or1k-elf-` results in a binary code that directly runs on the hardware. For example, `printf()` in source code gets translated into writing bytes to the UART by `or1k-elf-`. In contrast, `or1k-none-linux-musl-` will translate it into a `write` system call, which in turns gets further handled by the linux OS. 


Then we compile the code, *but* for a specific board. This is done by passing `-mboard` option. There are two boards that can work: `or1ksim-uart` or `ordb1a3pe1500`. The full list can be found [here](https://github.com/openrisc/newlib/tree/or1k/libgloss/or1k/boards).
```
or1k-elf-gcc -mboard=ordb1a3pe1500 hello.c -o hello.qemu
// OR
or1k-elf-gcc -mboard=or1ksim-uart hello.c -o hello.qemu
```

## Run the Program
```
./qemu-9.2.2/build/qemu-system-or1k -cpu or1200 -serial mon:stdio -kernel hello.qemu -nographic
```
The expected result of the run should be `Hello World!` being printed out and then hanging. 

> If you compiled the program without passing `-mboard=` flag or with something other than 2 boards mentioned above, you may not see any output. [QEMU by default uses or1ksim board](https://www.qemu.org/docs/master/system/target-openrisc.html#choosing-a-board-model) when the board is not specified using `-M` flag like we did above. And it uses specific memory layout and configuration that can be found [here](https://github.com/qemu/qemu/blob/master/hw/openrisc/openrisc_sim.c). In order for serial output to be captured and displayed properly by the QEMU or1ksim, its UART configuration (memory-mapped address, baud rate and IRQ) should match that of the binary. [`or1ksim-uart`](https://github.com/openrisc/newlib/blob/or1k/libgloss/or1k/boards/or1ksim-uart.S) and [`ordb1a3pe1500`](https://github.com/openrisc/newlib/blob/or1k/libgloss/or1k/boards/ordb1a3pe1500.S) happen to have the matching configuration and allow the compiler to generate binaries that can work well with QEMU (if I have to pick the _best_ one for this, I would pick `ordb1a3pe1500`, because it has 20MHz clock frequency just like QEMU or1ksim as opposed to 100MHz). 
