---
title: Linux
layout: page
nav_order: 5
---

## OpenRISC Linux

Linux on OpenRISC is the essence of [embedded Linux](https://elinux.org/Main_Page).
From the FPGA based SoCs, simulators, toolchains, kernel and software it provides a complete
open-source software and hardware stack.

In this tutorial we cover the basics of OpenRISC embedded Linux before diving
into our Linux on OpenRISC tutorials.  We will cover:

 * Boot loaders - we need to get Linux onto the system, we will explain how this
   is done.
 * Device tree - how does Linux know what hardware is available in the system?
 * Toolchains - We covered this before, but a quick refresher on Linux
   specific toolchains.
 * Rootfs - Applications.
 * Memory layout - we explain how devices, Linux and our user processes
   share memory space.

If you wish to skip this you can continue directly with our tutorials:

 * [Linux on or1ksim](linux-on-or1ksim.html) - Our instruction level simulator
 * [Linux on QEMU](linux-on-qemu.html) - The QEMU emulator
 * [Linux on De0 Nano](linux-on-de0nano.html) - An FPGA Development Board
 * And more (see left panel).


### Boot loaders

The job of the [boot loader](https://en.wikipedia.org/wiki/Bootloader) is to
prepare the operating system to boot and then boot it.  In the most simple sense
this means loading the operating system kernel into memory and then jumping to
the entry point.  Traditionally the popular Linux boot loader is
[GRUB](https://www.gnu.org/software/grub/).  However, on embedded Linux
platforms like OpenRISC Linux more simple loaders are used.  These include:

 - For Simulators - or1ksim and QEMU provide built in boot loaders
 - FPGA Boards - For larger FPGA boards with LiteX support we use the LiteX BIOS
 - Tiny FPGA Boards - For tiny FPGA boards we use GDB as a simple boot loader

Simulators like `or1ksim` and `QEMU` have the ability to be passed a kernel ELF
image from the command line.  When the simulator is initialized they will read
the ELF binary and load the binary content directly into the simulator memory.
In `QEMU` it will additionally generate and load a device tree to describe to
the kernel what hardware is available, dynamically.  After the system and memory
are initialized the simulator CPU will jump to `0x100` the entry point of the
OpenRISC platform.

On typical FPGA boards there is storage available to store a bootloader and
devices available to store the operating system.  For example on the [Digilent Arty](https://digilent.com/shop/arty-a7-100t-artix-7-fpga-development-board/)
when the FPGA bitstream is programmed a ROM is programmed with the [litex bios](https://github.com/enjoy-digital/litex/blob/master/litex/soc/software/bios/main.c).
This firmware plus boot loader will train DDR3 RAM before loading and jumping to
the kernel entry point.  The litex bios can load the operating system from an
SD-card or from TFTP over a network connection.

On very tiny FPGA boards like a base De0 Nano lacking non-volatile storage,
there may be no means to load an OS via SD-card or network.  We use GDB, a debugger
typically used to read and write CPU and memory state.  We can leverage this to
load ELF kernel images into memory over a JTAG debug interface.  Once, memory
is loaded we can reset the CPU to have it jump to `0x100` and boot the kernel.
Address `0x100` is the OpenRISC default reset vector.

### Device tree

The device tree file (.dts) is used to specify hardware configuration settings,
such as base addresses and interrupt numbers for peripherals, main memory, the
number of CPUs in the system and other things. OpenRISC Linux always needs a
device tree to boot.  The device tree can be built into the kernel or passed as
a boot parameter via register `r3`.

The below is a very simple device tree source file describing an OpenRISC system
with:

 - 1 CPU
 - 1 UART at 0x90000000
 - 32 MB main memory at address 0x0
 - 20 MHz clock

The device tree will be compiled down to a `.dtb` binary file using the device
tree compiler (`dtc`) during the build processes.  During the boot process the
kernel uses the device tree definitions to initialize devices and memory.

```
/dts-v1/;
/ {
	compatible = "opencores,or1ksim";
	#address-cells = <1>;
	#size-cells = <1>;
	interrupt-parent = <&pic>;

	aliases {
		uart0 = &serial0;
	};

	chosen {
		stdout-path = "uart0:115200";
	};

	memory@0 {
		device_type = "memory";
		reg = <0x00000000 0x02000000>;
	};

	cpus {
		#address-cells = <1>;
		#size-cells = <0>;
		cpu@0 {
			compatible = "opencores,or1200-rtlsvn481";
			reg = <0>;
			clock-frequency = <20000000>;
		};
	};

	pic: pic {
		compatible = "opencores,or1k-pic";
		#interrupt-cells = <1>;
		interrupt-controller;
	};

	serial0: serial@90000000 {
		compatible = "opencores,uart16550-rtlsvn105", "ns16550a";
		reg = <0x90000000 0x100>;
		interrupts = <2>;
		clock-frequency = <20000000>;
	};
};
```

### Toolchains

To compile the Linux kernel itself the toolchain used is not very important,
as the kernel doesn't depend on any toolchain runtime features.  You can use
any toolchain to build the kernel, as long as it is a recent OpenRISC
toolchain.
However, if you want to build user space applications choosing the correct
toolchain requires some thought.  The main choices are:

 - [musl](../musl.html) - A lightweight and efficient toolchain
 - [glibc](../glibc.html) - A fully featured application runtime with c++ and FPU support

The musl toolchain is good enough for most purposes.  Whichever toolchain
you choose to build your applications be sure to use a rootfs with a compatible
runtime installed.

### Rootfs

The rootfs is like the Linux distribution for an embedded Linux.

We provide some [prebuilt rootfs images](https://github.com/stffrdhrn/or1k-rootfs-build) to
help get you started. The top choices are:

 - buildroot - a fully featured rootfs ideal for boards with and SD card, with
   well known utilities like `bash`.
 - busybox - a lightweight single binary rootfs, coming in at under 3MB

### Memory Layout

The OpenRISC is able to address up to 32-bits of address space giving us up
to 4GB of addressable memory.  The space is shared between user space, the
kernel and hardware devices.  Memory protection between processes is achieved
using the OpenRISC memory management unit **MMU**.

The OpenRISC MMU uses 8KB (13-bits) pages leaving the most significant 19-bits
for indexing into a software page table.  The architecture uses a 2-level [page table](https://docs.kernel.org/mm/page_tables.html)
using 8-bits to index a 256 entry page directory and 11-bits to index 2048 page table entry leaf nodes.

The **page global directory** or **pgd** looks like the following in OpenRISC:

```
        PGD (256 entries)

  --> +-----+           PTE (2048 entries)
      | ptr |-------> +-----+
      | ptr |-        | ptr |-------> PAGE
      | ptr | \       | ptr |
      | ptr |  \        ...
      | ... |   \
      | ptr |    \         PTE
      +-----+     +----> +-----+
                         | ptr |-------> PAGE
                         | ptr |
                           ...

 PMD, PUD and P4D are folded up on OpenRISC
```

Virtual address bits are used to index into the page table
and derive the physical address as below:

```
+--------+--------+--------+--------+
| 31  24 | 23  16 | 15   8 | 7    0 |
+--------+--------+--------+--------+
 |         |          |
 |         |          v
 |         |         [12:0] in-page offset
 |         +-------> [23:13] PTE index
 +-----------------> [21:24] PGD index
```

The are defined in `page.h` and `pgtable.h` as follows:

From page.h:

```
#define PAGE_SHIFT      13                               // 8KB
```

From pgtable.h:

```
#define PGDIR_SHIFT     (PAGE_SHIFT + (PAGE_SHIFT-2))    // 24
#define PTRS_PER_PTE    (1UL << (PAGE_SHIFT-2))          // 2048
#define PTRS_PER_PGD    (1UL << (32-PGDIR_SHIFT))        // 256

#define PGDIR_SIZE	(1UL << PGDIR_SHIFT)
#define USER_PTRS_PER_PGD       (TASK_SIZE/PGDIR_SIZE)
```

The definition of `USER_PTRS_PER_PGD` evaluates to 128. This macro is used to
reserve the first 128 pfn's for user space leaving pfn's 128 to 255 for kernel
space.

#### Physical Addresses

In Linux SoCs our data caches are configured with a 31-bit addresses width.
This means only the first 2GB of physical memory space addresses are cached.  This is useful
as it guarantees that all operations on addresses above `0x80000000` are not cached.
We use these upper address ranges for IO devices which we do not want to be
cached.

This means that technically OpenRISC systems cannot have more than 2GB of main
memory. However, due to the OpenRISC kernel not supporting highmem and some
other reserved address space, the main memory limit is about 768MB; which is
plenty for OpenRISC embedded system.

The physical address space looks like the follow:

```
Address Range       | Description
--------------------+---------------------------
0x80000000 ~ (2GB)  | IO space, not cached
--------------------+---------------------------
0x00000000 ~ (2GB)  | Physical RAM space, cached
```

#### Virtual Memory

Virtual memory in Linux is split between kernel space and user space as below.
There is 1GB reserved for the kernel, 2GiB reserved for user space and a 1GiB hole
which we reserve for other purposes.

OpenRISC uses 8KB pages.

```
| Address Range           | Defines                       | Size  | Usage
+-------------------------+-------------------------------+-------+------
| 0xffffc000 - 0xffffffff |                               | 16KB  | 2 Page hole
| 0xf7fc0000 - 0xffffbfff | FIXADDR_START to FIXADDR_TOP  | 256KB | 32 Fixmap slots, 256 KB
| 0xc0000000 - 0xf7fbffff | KERNELBASE                    | ~1GB  | direct mapped, kernel space (30-bits)
+-------------------------+-------------------------------+-------+-------
| 0xbc000000 - 0xbfffffff | VMALLOC_START to VMALLOC_END) | 64MB  | vmalloc/ioremap
| 0x80000000 - 0xbbffffff |                               | ~1GB  | Reserved
+-------------------------+-------------------------------+-------+------
| 0x00002000 - 0x7fffffff | TASK_SIZE                     | ~2GB  | User space
| 0x00000000 - 0x00001fff |                               | 8KB   | Unmapped page, NULL catch
+----
```

We can see how this works in practice if we look at a Linux kernel ELF binary as
below:

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

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x002000 0xc0000000 0x00000000 0x549344 0x549344 R E 0x2000
  LOAD           0x54c000 0xc054a000 0x0054a000 0x485ea0 0x499c20 RWE 0x2000
  NOTE           0x60d85c 0xc060b85c 0x0060b85c 0x00054 0x00054 R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x4
```

Notice the **Program Headers** reveal that only some of the sections
are loaded into memory.  Many of the ELF binary sections above are used
for debugging.  The main executable section `.text` is loaded starting at address `0x0`.
The other sections are added after that.  The virtual addresses
of the sections have a base of `0xc0000000`.

For *"fat"* kernels a rootfs is built into `.data` section.  As we can see below.

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

If we have a look at the ELF binary of a user space process we see the
following:

```
$ readelf -e ../../busybox-rootfs/initramfs/bin/busybox
There are 23 section headers, starting at offset 0x19478c:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .hash             HASH            00000134 000134 000ac4 04   A  3   0  4
  [ 2] .gnu.hash         GNU_HASH        00000bf8 000bf8 000048 04   A  3   0  4
  [ 3] .dynsym           DYNSYM          00000c40 000c40 001a80 10   A  4   9  4
  [ 4] .dynstr           STRTAB          000026c0 0026c0 000e60 00   A  0   0  1
  [ 5] .rela.dyn         RELA            00003520 003520 003e40 0c   A  3   0  4
  [ 6] .rela.plt         RELA            00007360 007360 0011f4 0c  AI  3  20  4
  [ 7] .init             PROGBITS        00008554 008554 000014 00  AX  0   0  1
  [ 8] .plt              PROGBITS        00008568 008568 001800 04  AX  0   0  4
  [ 9] .text             PROGBITS        00009d68 009d68 16023c 00  AX  0   0  4
  [10] .fini             PROGBITS        00169fa4 169fa4 000014 00  AX  0   0  1
  [11] .rodata           PROGBITS        00169fb8 169fb8 027036 00   A  0   0  8
  [12] .interp           PROGBITS        00190fee 190fee 000017 00   A  0   0  1
  [13] .eh_frame_hdr     PROGBITS        00191008 191008 00002c 00   A  0   0  4
  [14] .eh_frame         PROGBITS        00191034 191034 0000c0 00   A  0   0  4
  [15] .init_array       INIT_ARRAY      00192510 192510 000004 04  WA  0   0  4
  [16] .fini_array       FINI_ARRAY      00192514 192514 000004 04  WA  0   0  4
  [17] .data.rel.ro      PROGBITS        00192518 192518 0019fc 00  WA  0   0  8
  [18] .dynamic          DYNAMIC         00193f14 193f14 0000e8 08  WA  4   0  4
  [19] .data             PROGBITS        00194000 194000 00001d 00  WA  0   0  4
  [20] .got              PROGBITS        00194020 194020 0006b8 04  WA  0   0  4
  [21] .bss              NOBITS          001946d8 1946d8 0005cc 00  WA  0   0  8
  [22] .shstrtab         STRTAB          00000000 1946d8 0000b1 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  PHDR           0x000034 0x00000034 0x00000034 0x00100 0x00100 R   0x4
  INTERP         0x190fee 0x00190fee 0x00190fee 0x00017 0x00017 R   0x1
      [Requesting program interpreter: /lib/ld-musl-or1k.so.1]
  LOAD           0x000000 0x00000000 0x00000000 0x1910f4 0x1910f4 R E 0x2000
  LOAD           0x192510 0x00192510 0x00192510 0x021c8 0x02794 RW  0x2000
  DYNAMIC        0x193f14 0x00193f14 0x00193f14 0x000e8 0x000e8 RW  0x4
  GNU_EH_FRAME   0x191008 0x00191008 0x00191008 0x0002c 0x0002c R   0x4
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x10
  GNU_RELRO      0x192510 0x00192510 0x00192510 0x01af0 0x01af0 R   0x1

```

Notice how the virtual addresses of the loaded sections have a base address
of `0x00000000`, not `0xc0000000` as we saw in the Linux kernel binary above.

When this binary is running we can see it maps into user space as follows.

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

We can see a few things looking at this map:

 - The first page is not mapped; mapping starts at 0x2000. This
   allows accesses to `0x0` to throw a null pointer exception.
 - The binary sections are loaded into executable, read only and read write
   protected regions.
 - A dynamic heap has been allocated.
 - Shared libraries are mapped into memory space around the `0x30000000`
   range.
 - The stack is high in the virtual memory address space around `0x7fffffff`.
   It grows down.

### Conclusion

We have gone over some of the internals of the OpenRISC Linux implementation.
We hope this helps you in the understanding of the fundamentals of embedded
Linux and will improve your understanding of the Linux bring-up tutorials that
follow.
