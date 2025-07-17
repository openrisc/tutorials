---
title: Linux on or1ksim
layout: page
parent: Linux
nav_order: 2
---

# Prerequisites

#### System

 - An x86 Linux workstation
 - The `curl` and `telnet` command line utilities
 - 2.5 GB of disk space

#### Files

We will download these below.

 - [or1ksim.cfg](https://github.com/stffrdhrn/or1k-utils/raw/refs/heads/master/or1ksim.cfg) - config needed for or1ksim
 - [or1ksim-2025-04-27.tar.gz](https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz) - The OpenRISC simulator source code
 - [or1k-none-linux-musl-15.1.0-20250621.tar.xz](https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-none-linux-musl-15.1.0-20250621.tar.xz) - OpenRISC musl linux userspace toolchain
 - [linux-6.15.5.tar.xz](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.5.tar.xz) - Linux kernel source code
 - [busybox-small-rootfs-20250708.tar.xz](https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/busybox-small-rootfs-20250708.tar.xz) - Linux rootfs for userspace programs

# Linux on or1ksim Tutorial

In this tutorial we will cover building a Linux kernel and booting it on or1ksim
with a [busybox](https://busybox.net) root filesystem.  This is a typical environment which can be used
to test and develop userspace binaries or do Linux Kernel development.

QEMU is also a good alternative simulator, QEMU provides SMP support and runs much faster.  However,
or1ksim is an [instruction set simulator](https://en.wikipedia.org/wiki/Instruction_set_simulator) which
provides more accurate tracing.

We break this tutorial down into parts:

 - Downloading the pieces
 - Compiling the kernel
 - Running the kernel
 - Interacting with the simulator
 - Adding custom userspace programs

## Downloading the Pieces

To get started we will create a temporary directly and setup our environment, if
you plan to do a lot of OpenRISC development consider adding these tools to your
`PATH` permanently.

To get everything you need run:

```bash
mkdir /tmp/linux-on-or1ksim/
cd /tmp/linux-on-or1ksim/

# Download linux source, or1ksim, a busybox rootfs and our toolchain
curl -L -O https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.5.tar.xz
curl -L -O https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz
curl -L -O https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/busybox-small-rootfs-20250708.tar.xz
curl -L -O https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-none-linux-musl-15.1.0-20250621.tar.xz

# Download an example config for or1ksim
curl -L -O https://github.com/stffrdhrn/or1k-utils/raw/refs/heads/master/or1ksim.cfg

# Extract everything
tar -xf linux-6.15.5.tar.xz
tar -xf or1ksim-2025-04-27.tar.gz
tar -xf busybox-small-rootfs-20250708.tar.xz
tar -xf or1k-none-linux-musl-15.1.0-20250621.tar.xz

export PATH=$PATH:$PWD/or1k/bin:$PWD/or1k-none-linux-musl/bin
```

## Building Linux

To build a Linux kernel we use the toolchain, kernel source code and rootfs just downloaded
in the following make commands:

```bash
make -C linux-6.15.5 \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-none-linux-musl- \
  defconfig
make -C linux-6.15.5 \
  -j12 \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-none-linux-musl- \
  CONFIG_INITRAMFS_SOURCE="$PWD/busybox-small-rootfs-20250708/initramfs/ $PWD/busybox-small-rootfs-20250708/initramfs.devnodes"
```

The first command configures the kernel with the default configuration `defconfig` which is the `or1ksim` configuration. The `make`
arguments are as follows:

 * `-C linux-6.15.5` - This saves us from having to change directory, `make` will run from within the Linux source code directory.
 * `ARCH=openrisc` - This passes the `ARCH` variable to the build system selecting the OpenRISC architecture.
 * `CROSS_COMPILE=or1k-none-linux-musl-` - This passes the `CROSS_COMPILE` variable to the build system selecting our toolchain.
 * `defconfig` - The make target, configures the linux kernel for the build.

The second command builds the kernel.  The new argument is:

 * `CONFIG_INITRAMFS_SOURCE=...` - This configures the built in root filesystem.

When running on machines with no disk capabilities such as `or1ksim` we can use an [initfamfs](https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.txt)
that is build directly into our kernel ELF binary.  This is one of the most simple ways to boot Linux
but it means that our data will be lost after reset.  Also, it means that updating userspace utilties
requires rebuilding the kernel.

## Booting the System

To start Linux on `or1ksim` we run `or1k-elf-sim` passing the kernel as an argument.
This will:

 # Initialize the OpenRISC simulator
 # Load the kernel image, including the embedded rootfs, into RAM memory
 # Reset the simulator CPU to PC 0x100 kicking off the kernel boot process

The `or1ksim` starts a console on port `10084` which we can connect to to access
the system.

#### Terminal 1

```bash
or1l-elf-sim -f or1ksim.cfg linux-6.15.5/vmlinux
```

In a second terminal while or1ksim is running login to the simulator
using `telnet`.

#### Terminal 2

```bash
telnet localhost 10084
```

To exit `or1ksim` press: `Ctrl+c`

To exit `telnet` press: `Ctrl+]`

## Adding User Space Programs

To add your own programs to the rootfs you can use the [musl](https://musl.libc.org)
toolchain to build executables as follows:

```
or1k-none-linux-musl-gcc hello.c -o busybox-small-rootfs-20250708/initramfs/hello
```

This compiles the `hello.c` program and outputs the binary directly into our rootfs
root directory.  The toolchain and rootfs runtime support c and c++ programs.

Once programs are added we must recompile the kernel as done in step 2 above of
*Building Linux*.

## Example Boot Sequence

#### Terminal 1

```
$ or1l-elf-sim -f or1ksim.cfg linux-6.15.5/vmlinux
Seeding random generator with value 0xb89aeeb2
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
Warning: Failed to set TAP device tap0: Operation not permitted
Or1ksim: Console listening for telnet on port 10084
UART at 0x90000000
Resetting Tick Timer.
Resetting Power Management.
Resetting PIC.
Starting at 0x00000000
loadcode: filename linux-6.15.5/vmlinux  startaddr=00000000  virtphy_transl=00000000
...
IP idents hash table entries: 2048 (order: 1, 16384 bytes, linear)
tcp_listen_portaddr_hash hash table entries: 2048 (order: 0, 8192 bytes, linear)
Table-perturb hash table entries: 65536 (order: 5, 262144 bytes, linear)
TCP established hash table entries: 2048 (order: 0, 8192 bytes, linear)
TCP bind hash table entries: 2048 (order: 1, 16384 bytes, linear)
TCP: Hash tables configured (established 2048 bind 2048)
UDP hash table entries: 256 (order: 0, 8192 bytes, linear)
UDP-Lite hash table entries: 256 (order: 0, 8192 bytes, linear)
NET: Registered PF_UNIX/PF_LOCAL protocol family
RPC: Registered named UNIX socket transport module.
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp-with-tls transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
workingset: timestamp_bits=30 max_order=12 bucket_order=0
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
printk: legacy console [ttyS0] disabled
90000000.serial: ttyS0 at MMIO 0x90000000 (irq = 2, base_baud = 1250000) is a 16550A
printk: legacy console [ttyS0] enabled 
printk: legacy console [ttyS0] enabled 
printk: legacy bootconsole [ns16550a0] disabled
printk: legacy bootconsole [ns16550a0] disabled
-- dcache disabled
-- icache disabled
NET: Registered PF_PACKET protocol family
clk: Disabling unused clocks
Freeing unused kernel image (initmem) memory: 5368K
This architecture does not have kernel memory protection.
Run /init as init process
ethoc 92000000.ethoc eth0: Link is Up - 10Mbps/Full - flow control off

Please press Enter to activate this console.
```

#### Terminal 2

```
$ telnet localhost 10084
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.

~ # uname -a
uname -a
Linux openrisc 6.15.5 #2 Tue Jul  8 21:43:25 BST 2025 openrisc GNU/Linux
~ # exit
exit

Please press Enter to activate this console.
```

## Further Reading

 - [openrisc/or1ksim](https://github.com/openrisc/or1ksim) - The or1ksim home page and git repo
 - [or1ksim Releases](https://github.com/openrisc/or1ksim/releases) - Nightly build and point release
 - [Linux Releases](https://kernel.org) - Linux release tarballs
 - [OpenRISC toolchain Releases](https://github.com/stffrdhrn/or1k-toolchain-build/releases) - Toolchain point releases
 - [OpenRISC rootfs Releases](https://github.com/stffrdhrn/or1k-rootfs-build/releases) - Rootfs point release
