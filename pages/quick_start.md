---
title: Quickstart Images
layout: page
nav_order: 2
---

# Quick Start with Docker Images

## Prerequisites

 - An x86 Linux workstation with support for `docker` or `podman`

The fastest way to get started with OpenRISC is to use our pre-build [docker](https://www.docker.com)
container images.  These provide a base development environment to see how things work.  Other tutorials
assume you are running and installing software on your own workstation, but they could be adapted to run
in these docker images.

## About Editors

As the images have no editor installed by default you can create a simple
program using `cat` as below.  If needed you can install an editor with `apt-get`
or by extending the docker image.

Create a `hello.c`

```bash
cat <<EOF >hello.c
#include <stdio.h>

int main() {
    puts("Hello\n");
    return 0;
}
EOF
```

## Simulator Environment

### Hello World

The below example shows how you can download the docker image
and run the image using `podman`.  You could also use `docker` if you like.

This then uses the or1k simulator to simulate our Hello World program.

To pull and run the image run:

```bash
podman pull stffrdhrn/or1k-sim-env
podman run -it --rm stffrdhrn/or1k-sim-env
```

This will bring you to the container prompt which
has access to the simulator development environment.

Create the `hello.c` file as described above, then to compile our program run
`gcc` from the OpenRISC toolchain as below:

```bash
or1k-elf-gcc hello.c -o hello
```

After the program is compiled we can run the program in the simulator with the
following:

```bash
or1k-elf-sim -f /opt/or1k/sim.cfg hello
```

Putting it all together:

```
$ podman pull stffrdhrn/or1k-sim-env
$ podman run -it --rm stffrdhrn/or1k-sim-env

root@011a54cf7988:/tmp# cat <<EOF >hello.c
> #include <stdio.h>
>
> int main() {
>     puts("Hello\n");
>     return 0;
> }
> EOF
root@011a54cf7988:/tmp# or1k-elf-gcc hello.c -o hello
root@011a54cf7988:/tmp# or1k-elf-sim -f /opt/or1k/sim.cfg hello

Seeding random generator with value 0xcf48d5be
Insn MMU 0KB: 1 ways, 64 sets, entry size 1 bytes
Data MMU 0KB: 1 ways, 64 sets, entry size 1 bytes
Ethernet TAP type
Verbose on, simdebug off, interactive prompt off
Machine initialization...
Clock cycle: 10ns
No data cache.
No instruction cache.
BPB simulation off.
BTIC simulation off.
Or1ksim 2025-04-27
Building automata... done, num uncovered: 0/215.
Parsing operands data... done.
Warning: Failed to open TUN/TAP device: No such file or directory
Or1ksim: Console listening for telnet on port 10084
UART at 0x90000000
Resetting Tick Timer.
Resetting Power Management.
Resetting PIC.
Starting at 0x00000000
loadcode: filename hello  startaddr=00000000  virtphy_transl=00000000
Not COFF file format
ELF type: 0x0002 
ELF machine: 0x005c
ELF version: 0x00000001
ELF sec = 13
Program Header: PT_LOAD, vaddr: 0x00000000, paddr: 0x0 offset: 0x00002000, filesz: 0x000069a8, memsz: 0x000069a8
Program Header: PT_LOAD, vaddr: 0x000089a8, paddr: 0x89a8 offset: 0x000089a8, filesz: 0x000006b4, memsz: 0x00000b88
WARNING: sim_init: Debug module not enabled, cannot start remote service to GDB
Hello
```

## FuseSoC Environment

We also have an FPGA development environment for OpenRISC available.  The below
example shows how to build and run a simple program.  The program runs on a [iverlog](https://bleyer.org/icarus/)
verilog simulator but you can also use the FuseSoC backend to generate a bitstream.

To pull and run the image run:

```bash
podman pull stffrdhrn/or1k-verilog-env
podman run -it --rm stffrdhrn/or1k-verilog-env
```

This will bring you to the container prompt which
has access to the verilog development environment.

Create the `hello.c` file as described above, then to compile our program run
`gcc` from the OpenRISC toolchain as below:

```bash
or1k-elf-gcc hello.c -o hello
```

This will compile our Hello World program using the OpenRISC baremetal toolchain
and output an ELF file to `hello`.

After our program is compiled we want to prepare to run the program, check that the
fusesoc environment is setup correctly using the following commands:

```bash
cd cores
fusesoc core-info mor1kx-generic
```

Changing directories to `/tmp/src/cores` is needed as fusesoc looks
for verilog IP cores starting in the current directory.  The `fusesoc core-info`
command checks if our `mor1kx-generic` SoC is available as expected.

To compile and run the verilog SoC we use:

```bash
fusesoc run --target mor1kx_tb mor1kx-generic --elf_load ../hello
```

This runs `mor1kx-generic` `mor1kx_tb` (mor1kx test bench target), which is the
simulator that allows loading elf executables to memory and run them.  Please
explore the other arguments such as `--help` and `--trace_enable --trace_to_screen`.

Putting it all together:

```
$ podman pull stffrdhrn/or1k-verilog-env
$ podman run -it --rm stffrdhrn/or1k-verilog-env

or1kuser@fb306c0dc35e:/tmp/src$ cat <<EOF >hello.c
> #include <stdio.h>
>
> int main() {
>     puts("Hello\n");
>     return 0;
> }
> EOF
or1kuser@fb306c0dc35e:/tmp/src$ or1k-elf-gcc hello.c -o hello
or1kuser@fb306c0dc35e:/tmp/src$ cd cores
or1kuser@fb306c0dc35e:/tmp/src/cores$ fusesoc core-info mor1kx-generic
or1kuser@fb306c0dc35e:/tmp/src/cores$ fusesoc run --target mor1kx_tb mor1kx-generic --elf_load ../hello

INFO: Preparing ::adv_debug_sys:3.1.0-r1
INFO: Downloading olofk/adv_debug_sys from github
INFO: Preparing ::cdc_utils:0.1-r1
INFO: Downloading fusesoc/cdc_utils from github
INFO: Preparing ::elf-loader:1.0.3
INFO: Preparing ::intgen:1.0
INFO: Preparing ::jtag_tap:1.13-r1
INFO: Downloading olofk/jtag from github
INFO: Preparing ::jtag_vpi:0-r5
INFO: Downloading fjullien/jtag_vpi from github
INFO: Preparing ::mor1kx:5.2
INFO: Preparing ::uart16550:1.5.5-r1
INFO: Downloading olofk/uart16550 from github
INFO: Preparing ::verilog-arbiter:0-r3
INFO: Downloading bmartini/verilog-arbiter from github
INFO: Preparing ::vlog_tb_utils:1.1-r1
INFO: Downloading fusesoc/vlog_tb_utils from github
INFO: Preparing ::wb_common:1.0.3
INFO: Downloading fusesoc/wb_common from github
INFO: Preparing ::wb_intercon:1.4.1
INFO: Downloading olofk/wb_intercon from github
INFO: Preparing ::wb_ram:1.1-r1
INFO: Downloading fusesoc/wb_ram from github
INFO: Preparing ::mor1kx-generic:1.1
INFO: Setting up project
WARNING: This backend is deprecated and will eventually be removed. Please migrate to the flow API instead.  See https://edalize.readthedocs.io/en/latest/ref/migrations.html#migrating-from-the-tool-api-to-the-flow-api for more details.
WARNING: src/jtag_vpi_0-r5/jtag_common.c has unknown file type 'cSource'
WARNING: src/jtag_vpi_0-r5/jtag_vpi.c has unknown file type 'cSource'
INFO: Running pre_build script check_libelf
INFO: Building
INFO: Running
vvp -n -M. -l icarus.log -melf_loader_vpi -mjtag_vpi  mor1kx-generic_1.1 -fst +elf_load=/tmp/src/hello
Program header 0: addr 0x00000000, size 0x000069A8
Program header 1: addr 0x000089A8, size 0x000006B4
elf-loader: /tmp/src/hello was loaded
Loading        9239 words
                   0 : Illegal Wishbone B3 cycle type (xxx)
Hello

src/mor1kx_5.2/bench/verilog/mor1kx_monitor.v:140: $finish called at 171635 (1s)
```

## Further Reading

 - [stffrdhrn/or1k-docker-images](https://github.com/stffrdhrn/or1k-docker-images) - OpenRISC docker images home page
