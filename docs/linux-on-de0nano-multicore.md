---
title: SMP Linux on De0 Nano Multicore
layout: page
parent: Linux
nav_order: 6
---

# Prerequisites

#### Tutorials

Run our [Linux on De0 Nano tutorial](linux-on-de0nano.html) to ensure you have:

   - A working version of OpenOCD
   - A UART connected to the De0 Nano development board
   - `fusesoc` - The [FuseSoC build system](../fusesoc.html).
   - OpenOCD 0.10.0 (As of 2025, versions 0.11.0 and 0.12.0 have jtag timing issues)
   - `or1k-elf-` Toolchain as installed in our [newlib tutorial](../newlib.html).
   - `or1k-none-linux-musl-` - OpenRISC musl linux userspace toolchain

#### System

Additionally for the Linux tutorial we will need:

 - An x86 Linux workstation
 - The `curl` and `git` command line utilities
 - A serial terminal emulator, here we use `picocom`
 - 2.5 GB of disk space

#### Files

We will download these below.

 - linux - Linux kernel source code
 - [busybox-small-rootfs-20250708.tar.xz](https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/busybox-small-rootfs-20250708.tar.xz) - Linux rootfs for userspace programs

# SMP Linux on De0 Nano Multicore Tutorial

In this tutorial we will cover building a Symetrical Multi-Processing (SMP) Linux kernel and booting it on [De0 Nano](../de0_nano/index.html)
with a [busybox](https://busybox.net) root filesystem.  This builds on the De0 Nano
hello world FGPA board bring up and the Linux on De0 Nano tutorials.

In this tutorial we will be able to expirment with an OpenRISC design with 2 cpu's.

We break this tutorial down into parts:

 - Downloading the pieces
 - Compiling the kernel
 - Building the FPGA bitstream
 - Running the kernel

## Downloading the Pieces

To get started we will create a temporary directory and setup our environment, if
you plan to do a lot of OpenRISC development consider adding these tools to your
`PATH` permanently.

To get everything you need run:

```bash
mkdir /tmp/linux-on-de0nano-multicore/
cd /tmp/linux-on-de0nano-multicore/

# Get our config for openocd
curl -L -O https://openrisc.io/tutorials/de0_nano/de0_nano.cfg

# Clone kernel source, ~2GiB
git clone --depth 1 --branch v7.0.0-rc1 https://kernel.googlesource.com/pub/scm/linux/kernel/git/torvalds/linux.git

# Download a busybox rootfs and our toolchain
curl -L -O https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/busybox-small-rootfs-20250708.tar.xz

# Add IP cores to the environment
fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc library add elf-loader https://github.com/fusesoc/elf-loader.git
fusesoc library add openrisc-cores https://github.com/openrisc/openrisc-cores
fusesoc library add de0_nano-multicore https://github.com/stffrdhrn/de0_nano-multicore.git

# Check the SoC design is available
fusesoc core show de0_nano-multicore

# Extract software needed for the kernel
tar -xf busybox-small-rootfs-20250708.tar.xz

# Check the OpenRISC linux toolchain is on the path, if not see the Linux on De0 Nano tutorial
or1k-none-linux-musl-gcc --version
```

## Compiling the Kernel

To build a Linux kernel we use the toolchain, kernel source code and rootfs just downloaded
in the following make commands:

```bash
make -C linux \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-none-linux-musl- \
  de0_nano_multicore_defconfig

make -C linux \
  -j$(nproc) \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-none-linux-musl- \
  CONFIG_INITRAMFS_SOURCE="$PWD/busybox-small-rootfs-20250708/initramfs/ $PWD/busybox-small-rootfs-20250708/initramfs.devnodes"
```

The first command configures the kernel with the default configuration `de0_nano_multicore_defconfig` which is for the De0 Nano
board using our Mutlicore design. The `make` arguments are as follows:

 * `-C linux` - This saves us from having to change directory, `make` will run from within the Linux source code directory.
 * `ARCH=openrisc` - This passes the `ARCH` variable to the build system selecting the OpenRISC architecture.
 * `CROSS_COMPILE=or1k-none-linux-musl-` - This passes the `CROSS_COMPILE` variable to the build system selecting our toolchain.
 * `de0_nano_multicore_defconfig` - The make target, configures the linux kernel for the build.

The second command builds the kernel.  The new argument is:

 * `CONFIG_INITRAMFS_SOURCE=...` - This configures the built in root filesystem.

When running on machines with no disk capabilities such as De0 Nano we can use an [initfamfs](https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.txt)
that is built directly into our kernel ELF binary.  This is one of the most
simple ways to boot Linux but it means that our data is only in RAM and will be
lost after reset.  Also, it means that updating the rootfs userspace utilties
requires rebuilding the kernel.

## Building the FPGA bitstream

As with the De0 Nano hello world tutorial we can build the bitstream with:

```bash
fusesoc run de0_nano-multicore
```

*Note*: The De0 Nano multicore design uses 16K or 73% of the Cyclone IV LEs
compared to 10K or 49% for the single core design.  Also, you may notice that
the total number of memory bits in the multicore design is slightly less
compared to the single core design as we shrank the cache sizes on each core to
allow for the design to fit.

See fitting details below:

```
$ tail build/de0_nano-multicore_1.1/default-quartus/de0_nano-multicore_1_1.fit.summary
Timing Models : Final
Total logic elements : 16,245 / 22,320 ( 73 % )
    Total combinational functions : 14,659 / 22,320 ( 66 % )
    Dedicated logic registers : 7,440 / 22,320 ( 33 % )
Total registers : 7440
Total pins : 53 / 154 ( 34 % )
Total virtual pins : 0
Total memory bits : 312,576 / 608,256 ( 51 % )
Embedded Multiplier 9-bit elements : 12 / 132 ( 9 % )
Total PLLs : 1 / 4 ( 25 % )

$ tail ../or1k-de0nano/build/de0_nano_1.1/default-quartus/de0_nano_1_1.fit.summary
Timing Models : Final
Total logic elements : 10,980 / 22,320 ( 49 % )
    Total combinational functions : 9,706 / 22,320 ( 43 % )
    Dedicated logic registers : 5,472 / 22,320 ( 25 % )
Total registers : 5472
Total pins : 73 / 154 ( 47 % )
Total virtual pins : 0
Total memory bits : 327,936 / 608,256 ( 54 % )
Embedded Multiplier 9-bit elements : 6 / 132 ( 5 % )
Total PLLs : 1 / 4 ( 25 % )
```

## Running the Kernel

*(Note: this step is the same as Linux on De0 Nano)*

To start Linux on the De0 Nano development board we need to load the bitstream then
upload the kernel image into RAM over the debug interface.  The steps being:

 1. Program the FPGA bitstream onto the FPGA board
 2. Using GDB load the kernel image - including the embedded rootfs - into RAM
 3. Reset the FPGA design, kicking off the kernel boot process

#### Terminal 1

We can program the OpenRISC FPGA bitstream and Linux kernel to the board with
the following commands.

```bash
fusesoc run de0_nano-multicore --pgm quartus

# Run openocd in the background so we can use one terminal.
openocd -f interface/altera-usb-blaster.cfg -f de0_nano.cfg > openocd.log 2>&1 &

or1k-elf-gdb ./linux/vmlinux \
   -ex 'target remote :3333' \
   -ex 'monitor reset' \
   -ex 'monitor halt' \
   -ex load \
   -ex 'monitor reset' \
   -ex detach \
   -ex quit

pkill openocd
```

The GDB command will connect to OpenOCD, then reset and halt the board making
it ready to program.  The `load` command will load the `vmlinux` ELF binary into
the De0 Nano RAM.  The next `monitor reset` command will reset the FPGA design
kicking off the Linux boot process.

In a second terminal while the FPGA board is running connect
to the serial console using `picocom`.

#### Terminal 2

*(Note: this step is the same as Linux on De0 Nano)*

We will use terminal 2 for connecting to the development board.

Open `picocom` with the following:

```bash
cd /tmp/linux-on-de0nano-multicore/

picocom -b 115200 /dev/ttyUSB0 --receive-cmd 'rx -vv' --send-cmd 'sx -vv'
```

To disconnect press `Ctrl-a` `Ctrl-q`

To upload files to the board press `Ctrl-a` `Ctrl-s`

## Example Boot Sequence

For reference in the `picocom` terminal the boot sequence will look as follows:

#### Terminal 2

```
[    0.000000] Compiled-in FDT at (ptrval)
[    0.000000] Linux version 7.0.0-rc1-de0nano-smp (shorne@antec) (or1k-none-linux-musl-gcc (GCC) 15.1.0, GNU ld (GNU Binutils) 2.44) #2 SMP Thu Feb 26 21:37:09 GMT 2026
[    0.000000] OF: reserved mem: Reserved memory: No reserved-memory node in the DT
[    0.000000] CPU: OpenRISC-10 (revision 0) @50 MHz
[    0.000000] -- dmmu:   64 entries, 1 way(s)
[    0.000000] -- immu:   64 entries, 1 way(s)
[    0.000000] -- additional features:
[    0.000000] -- debug unit
[    0.000000] -- PIC
[    0.000000] -- timer
[    0.000000] Initial ramdisk not found
[    0.000000] Setting up paging and PTEs.
[    0.000000] map_ram: Memory: 0x0-0x2000000
[    0.000000] itlb_miss_handler (ptrval)
[    0.000000] dtlb_miss_handler (ptrval)
[    0.000000] OpenRISC Linux -- http://openrisc.io
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x0000000001ffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000000000-0x0000000001ffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x0000000001ffffff]
[    0.000000] percpu: Embedded 5 pages/cpu s16032 r0 d24928 u40960
[    0.000000] Kernel command line: earlycon
[    0.000000] earlycon: ns16550a0 at MMIO 0x90000000 (options '115200')
[    0.000000] printk: legacy bootconsole [ns16550a0] enabled
[    0.000000] printk: log buffer data + meta data: 16384 + 51200 = 67584 bytes
[    0.000000] Dentry cache hash table entries: 4096 (order: 1, 16384 bytes, linear)
[    0.000000] Inode-cache hash table entries: 2048 (order: 0, 8192 bytes, linear)
[    0.000000] Sorting __ex_table...
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 4096
[    0.000000] mem auto-init: stack:all(zero), heap alloc:off, heap free:off
[    0.000000] mem_init_done ...........................................
[    0.000000] SLUB: HWalign=16, Order=0-1, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] rcu: Hierarchical RCU implementation.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 10 jiffies.
[    0.000000] NR_IRQS: 32, nr_irqs: 32, preallocated irqs: 0
[    0.000000] rcu: srcu_init: Setting srcu_struct sizes based on contention.
[    0.000000] clocksource: openrisc_timer: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 38225208935 ns
[    0.000000] 100.00 BogoMIPS (lpj=500000)
[    0.000000] pid_max: default: 32768 minimum: 301
[    0.010000] Mount-cache hash table entries: 2048 (order: 0, 8192 bytes, linear)
[    0.020000] Mountpoint-cache hash table entries: 2048 (order: 0, 8192 bytes, linear)
[    0.040000] VFS: Finished mounting rootfs on nullfs
[    0.120000] rcu: Hierarchical SRCU implementation.
[    0.120000] rcu:     Max phase no-delay instances is 1000.
[    0.140000] Timer migration: 1 hierarchy levels; 8 children per group; 1 crossnode level
[    0.160000] smp: Bringing up secondary CPUs ...
[    0.190000] CPU1: Booted secondary processor
[    0.190000] CPU: OpenRISC-10 (revision 0) @50 MHz
[    0.190000] -- dmmu:   64 entries, 1 way(s)
[    0.190000] -- immu:   64 entries, 1 way(s)
[    0.190000] -- additional features:
[    0.190000] -- debug unit
[    0.190000] -- PIC
[    0.190000] -- timer
[    0.190000] Synchronize counters for CPU 1: done.
[    0.230000] smp: Brought up 1 node, 2 CPUs
[    0.260000] Memory: 19960K/32768K available (5412K kernel code, 167K rwdata, 776K rodata, 5383K init, 79K bss, 12096K reserved, 0K cma-reserved)
[    0.280000] devtmpfs: initialized
[    0.360000] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 19112604462750000 ns
[    0.370000] posixtimers hash table entries: 1024 (order: 0, 8192 bytes, linear)
[    0.370000] futex hash table entries: 512 (16384 bytes on 1 NUMA nodes, total 16 KiB, linear).
[    0.440000] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.540000] pps_core: LinuxPPS API ver. 1 registered
[    0.540000] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.550000] PTP clock support registered
[    0.620000] clocksource: Switched to clocksource openrisc_timer
[    0.740000] NET: Registered PF_INET protocol family
[    0.760000] IP idents hash table entries: 2048 (order: 1, 16384 bytes, linear)
[    0.800000] tcp_listen_portaddr_hash hash table entries: 1024 (order: 0, 8192 bytes, linear)
[    0.810000] Table-perturb hash table entries: 65536 (order: 5, 262144 bytes, linear)
[    0.820000] TCP established hash table entries: 2048 (order: 0, 8192 bytes, linear)
[    0.830000] TCP bind hash table entries: 2048 (order: 2, 32768 bytes, linear)
[    0.840000] TCP: Hash tables configured (established 2048 bind 2048)
[    0.850000] UDP hash table entries: 256 (order: 1, 14336 bytes, linear)
[    0.860000] UDP-Lite hash table entries: 256 (order: 1, 14336 bytes, linear)
[    0.880000] NET: Registered PF_UNIX/PF_LOCAL protocol family
[    0.910000] RPC: Registered named UNIX socket transport module.
[    0.920000] RPC: Registered udp transport module.
[    0.920000] RPC: Registered tcp transport module.
[    0.930000] RPC: Registered tcp-with-tls transport module.
[    0.940000] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.990000] workingset: timestamp_bits=30 max_order=12 bucket_order=0
[    1.140000] ledtrig-cpu: registered to indicate activity on CPUs
[    1.170000] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.260000] printk: legacy console [ttyS0] disabled
[    1.280000] 90000000.serial: ttyS0 at MMIO 0x90000000 (irq = 2, base_baud = 3125000) is a 16550A
[    1.290000] printk: legacy console [ttyS0] enabled
[    1.290000] printk: legacy console [ttyS0] enabled
[    1.310000] printk: legacy bootconsole [ns16550a0] disabled
[    1.310000] printk: legacy bootconsole [ns16550a0] disabled
[    1.340000] -- dcache: 4096 bytes total, 32 bytes/line, 128 set(s), 1 way(s)
[    1.350000] -- icache: 4096 bytes total, 32 bytes/line, 128 set(s), 1 way(s)
[    1.370000] -- dcache: 4096 bytes total, 32 bytes/line, 128 set(s), 1 way(s)
[    1.380000] -- icache: 4096 bytes total, 32 bytes/line, 128 set(s), 1 way(s)
[    1.500000] NET: Registered PF_PACKET protocol family
[    1.830000] clk: Disabling unused clocks
[    4.840000] Freeing unused kernel image (initmem) memory: 5376K
[    4.840000] This architecture does not have kernel memory protection.
[    4.850000] Run /init as init process
ifconfig: SIOCSIFADDR: No such device
route: SIOCADDRT: Network unreachable

Please press Enter to activate this console. run-parts: /etc/network/if-pre-up.d: No such file or directory
~ # uname -a
Linux openrisc 7.0.0-rc1-de0nano-smp #2 SMP Thu Feb 26 21:37:09 GMT 2026 openrisc GNU/Linux
~ # cat /proc/cpuinfo
processor               : 0
cpu architecture        : OpenRISC 1000 (1.1-rev0)
cpu implementation id   : 0x1
cpu version             : 0x50001
frequency               : 50000000
immu                    : 64 entries, 1 ways
dmmu                    : 64 entries, 1 ways
bogomips                : 100.00
features                : orbis32

processor               : 1
cpu architecture        : OpenRISC 1000 (1.1-rev0)
cpu implementation id   : 0x1
cpu version             : 0x50001
frequency               : 50000000
immu                    : 64 entries, 1 ways
dmmu                    : 64 entries, 1 ways
bogomips                : 100.00
features                : orbis32
```

## Further Reading

 - [de0_nano-multicore](https://github.com/stffrdhrn/de0_nano-multicore) - A De0 Nano Multicore OpenRISC SoC design
 - [Linux Releases](https://kernel.org) - Linux release tarballs
 - [OpenRISC toolchain Releases](https://github.com/stffrdhrn/or1k-toolchain-build/releases) - Toolchain point releases
 - [OpenRISC rootfs Releases](https://github.com/stffrdhrn/or1k-rootfs-build/releases) - Rootfs point release
