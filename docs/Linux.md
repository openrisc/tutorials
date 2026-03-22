---
title: Linux
layout: page
nav_order: 5
---

## OpenRISC Linux

Linux on OpenRISC is the essence of [embedded Linux](https://elinux.org/Main_Page).
From the FPGA based SoC's, simulators, toolchains, kernel and software it provides a complete
open-source software and hardware stack.

In this tutorial we cover the basics of OpenRISC embedded Linux before diving
into our Linux on OpenRISC tutorials.  We will cover:

 * Memory layout - we will explain how devices, Linux and our user processes
   share memory space
 * Boot loaders - we need to get Linux onto the system, we will explain how this
   is done.
 * Device tree - how does Linux know what hardware is available in the system
 * Toolchains - We covered this before, but a quick refresher on linux
   specific toolchains
 * Rootfs - Applications

If you wish to skip this you can continue directly with our tutorials:

 * [Linux on or1ksim](linux-on-or1ksim.html) - Our instruction level simulator
 * [Linux on QEMU](linux-on-qemu.html) - The QEMU emulator
 * [Linux on De0 Nano](linux-on-de0nano.html) - An FPGA Development Board
 * And more (see left panel).

### Memory Layout

Before diving into Linux, boot loaders, the device tree a basic understanding of
the memory layout is helpful.

The OpenRISC is able to address up to 32-bits of address space giving us up
to 4GB of addressable memory.

#### Physical Addresses

In Linux SoC's our data caches are configured with a 31-bit addresses width.
This means only the first 2GB of memory addresses are cached.  This is useful
as it guarantees that all operations on addresses above `0x80000000` are not cached.
We use these upper address ranges for IO devices which we do not want to be
cached.

```
Address Range      | Description
-------------------+---------------------------
0x80000000 ~ (2GB) | IO space, not cached
-------------------+---------------------------
0x00000000 ~ (2GB) | Memory space, cached
```

#### Virtual Memory

Virtual memory in Linux is split between kernel space and user space as below.
There is 1GB reserved for the kernel, 2GB reserved for userspace and a 1GB hole
which we reserver for other purposes.

OpenRISC uses 8kb pages.

```
Address |
+---
| 0xffffffff - Top of address space
|               ^
|      1GB kernel space (30-bits)
|               V
| 0xc0000000 - Linux kernel base       (KERNELBASE 0xc0000000)
+--
| 0xbc000000 - 0xbfffffff (VMALLOC_START - VMALLOC_END) 64MB vmalloc/ioremap (64MB)
| 0x80000000 - 0xbbffffff
+--
| 0x7fffffff - Top of user space (stack)
!
|       1GB User space                 (TASK_SIZE  0x80000000)
|
| 0x00002000 - Bottom of address space
| 0x00000000 - Unmapped page (NULL)
+----
```

If we look at the Linux kernel ELF binary we see the following.

```
~ # cat /proc/1/maps
00002000-00168000 r-xp 00000000 00:03 7          /bin/busybox
00168000-0016a000 r--p 00164000 00:03 7          /bin/busybox
0016a000-0016c000 rw-p 00166000 00:03 7          /bin/busybox
0016e000-00170000 ---p 00000000 00:00 0          [heap]
00170000-00172000 rwxp 00000000 00:00 0          [heap]
30000000-300de000 r-xp 00000000 00:03 114        /lib/libc.so
300de000-300e0000 r--p 000dc000 00:03 114        /lib/libc.so
300e0000-300e2000 rw-p 000de000 00:03 114        /lib/libc.so
300e2000-300e4000 rwxp 00000000 00:00 0
7ff84000-7ffa6000 rw-p 00000000 00:00 0          [stack]
```

```
readelf -S vmlinux
There are 26 section headers, starting at offset 0x677ef20:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        c0000000 002000 549344 00  AX  0   0 4096
  [ 2] .rodata           PROGBITS        c054a000 54c000 0c1098 00  WA  0   0 32
  [ 3] .eh_frame         PROGBITS        c060b098 60d098 00005c 00   A  0   0  4
  [ 4] __param           PROGBITS        c060b0f4 60d0f4 000744 00   A  0   0  4
  [ 5] __modver          PROGBITS        c060b838 60d838 000024 00   A  0   0  4
  [ 6] .notes            NOTE            c060b85c 60d85c 000054 00   A  0   0  4
  [ 7] .data             PROGBITS        c060c000 60e000 029240 00  WA  0   0 8192
  [ 8] __ex_table        PROGBITS        c0635240 637240 0009f0 00   A  0   0  2
  [ 9] .init.text        PROGBITS        c0636000 638000 02a808 00  AX  0   0 8192
  [10] .init.data        PROGBITS        c0660820 662820 36b68c 00  WA  0   0 32
  [11] .data..percpu     PROGBITS        c09cc000 9ce000 003ea0 00  WA  0   0 16
  [12] .bss              NOBITS          c09cfea0 9d1ea0 013d80 00  WA  0   0 16
  [13] .debug_aranges    PROGBITS        00000000 9d1ea0 009078 00      0   0  1
  [14] .debug_info       PROGBITS        00000000 9daf18 3e546ac 00      0   0  1
  [15] .debug_abbrev     PROGBITS        00000000 482f5c4 201846 00      0   0  1
  [16] .debug_line       PROGBITS        00000000 4a30e0a f3cf27 00      0   0  1
  [17] .debug_frame      PROGBITS        00000000 596dd34 0c020c 00      0   0  4
  [18] .debug_str        PROGBITS        00000000 5a2df40 16d574 01  MS  0   0  1
  [19] .debug_line_str   PROGBITS        00000000 5b9b4b4 007811 01  MS  0   0  1
  [20] .debug_loclists   PROGBITS        00000000 5ba2cc5 9d990a 00      0   0  1
  [21] .debug_rnglists   PROGBITS        00000000 657c5cf 132676 00      0   0  1
  [22] .comment          PROGBITS        00000000 66aec45 000012 01  MS  0   0  1
  [23] .symtab           SYMTAB          00000000 66aec58 066db0 10     24 14480  4
  [24] .strtab           STRTAB          00000000 6715a08 069418 00      0   0  1
  [25] .shstrtab         STRTAB          00000000 677ee20 0000ff 00      0   0  1
```

For fat kernels the rootfs is built into `.data` section.  As we can see below.

```
$ nm vmlinux | grep __irf_
c09cbea4 d __irf_end
c06654a4 d __irf_start

$ printf "%d\n" $(((0xc09cbea4 - 0xc06654a4) / 1024))
3482
```

The `__irf_*` symbols mark the start and end of the Initramfs which we
include using the `CONFIG_INITRAMFS_SOURCE` kernel configuration option.
In the above example, we can see the included data is about 3.4 MB in size.
The rootfs is included into the kernel image using the Makefile and tools
in the `usr/` directory of kernel source tree.

```
Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x002000 0xc0000000 0x00000000 0x549344 0x549344 R E 0x2000
  LOAD           0x54c000 0xc054a000 0x0054a000 0x485ea0 0x499c20 RWE 0x2000
  NOTE           0x60d85c 0xc060b85c 0x0060b85c 0x00054 0x00054 R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x4
```

```
f0000000  - devices
c0000000  - kernel space
b0000000  - user space
```


### Device tree

Rootfs loaded to memory for embedded systems / no sd card

The device tree file (.dts) is used to specify hardware configuration settings, such as base addresses and interrupt numbers
for peripherals, memory sizes, the numbers of CPUs in the system and other things. If no custom device tree is used, a default one
is enabled that contains a UART at address 0x90000000, 32MB RAM and one CPU. These parameters should be available for any
OpenRISC system and can therefore be safely used. To enable more options, a separate device tree must be used

### Boot loaders

The job of the [boot loader](https://en.wikipedia.org/wiki/Bootloader) is to prepare the operating system to boot
and then boot it.  In the most simple sense this means loading the operating system kernel into memory and then
jumping to the entry point.  Traditionally the popular Linux boot loader is [GRUB](https://www.gnu.org/software/grub/).
However, on embedded Linux platforms like OpenRISC Linux more simple loaders are used.  These include:

 - For Simulators - or1ksim and QEMU provide built in boot loaders
 - FPGA Boards - For larger FPGA boards with litex support we use the litex bios
 - Tiny FPGA Boards - For tiny FPGA boards we use GDB as a simple boot loader

Simulators like `or1ksim` and `QEMU` have the ability to be passed a kernel ELF image from the command
line.  When the simulator is initialized they can read the ELF binary and load the bits directly into the simulator memory.
In `QEMU` it will additionally generate and load a device tree to describe to the kernel what hardware
is available, dynamically.  After the system and memory are initialized the simulator CPU will jump to `0x100`
the entry point of the OpenRISC platform.

On typical FPGA boards there is storage available to store a bootloader and devices available to store the operating system.
For example on the [Digilent Arty](https://digilent.com/shop/arty-a7-100t-artix-7-fpga-development-board/) when
the FPGA bitstream is programmed a ROM is programmed with the [litex bios](https://github.com/enjoy-digital/litex/blob/master/litex/soc/software/bios/main.c).
This firmware plus boot loader will train DDR3 RAM before loading and jumping to the kernel entry point.
The litex bios can load the operating system from an SD-card or from TFTP over a network connection.

On very Tiny FPGA boards like a base De0 Nano lacking non-volatile storage,
there is no means to load an OS via SD-card or network.  We use GDB, a debugger
typically used to read and write CPU and memory state.  We can leverage this to
load ELF kernel images into memory over the JTAG debug interface.  Once, memory
is loaded we can reset the CPU to have it jump to `0x100` and boot the kernel.

### Toolchains

Linux toolchain vs baremetal toolchains.

 Libc - musl
 libc - glibc


### Rootfs

The rootfs is like the Linux distribution for an embedded linux.

We provide some prebuilt rootfs images here https://github.com/stffrdhrn/or1k-rootfs-build

  buildroot
  busybox

