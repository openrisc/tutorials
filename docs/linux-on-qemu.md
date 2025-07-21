---
title: Linux on QEMU
layout: page
parent: Linux
nav_order: 2
---

# Prerequisites

#### System

 - An x86 Linux workstation
 - The `curl` command line utility
 - The `gcc` compiler and developer tools for your workstation
 - 2.5 GB of disk space, mostly for the kernel build

#### Files

To be downloaded below.

 - [qemu-9.2.4.tar.xz](https://download.qemu.org/qemu-9.2.4.tar.xz) - QEMU source code
 - [or1k-nonehf-linux-gnu-15.1.0-20250621.tar.xz](https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-nonehf-linux-gnu-15.1.0-20250621.tar.xz) - OpenRISC glibc linux userspace toolchain
 - [linux-6.15.5.tar.xz](https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.5.tar.xz) - Linux kernel source code
 - [buildroot-qemu-rootfs-20250708.tar.xz](https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/buildroot-qemu-rootfs-20250708.tar.xz) - Linux rootfs qcow image

# Linux on QEMU Tutorial

In this tutorial we will cover building a Linux kernel and booting it on QEMU
with a [buildroot](https://buildroot.org) root filesystem.  This will provide a flexible environment which can be used
to test and develop userspace binaries or do Linux Kernel development.

The OpenRISC QEMU platform provides:

 - [SMP](https://en.wikipedia.org/wiki/Symmetric_multiprocessing) multicore support
 - Networking support
 - PCI bus to allow hotplugging devices
 - Up to 4 GB of RAM
 - Persistent storage via the qcow2 filesystem

We break this tutorial down into parts:

 - Downloading the pieces
 - Running the or1ksim kernel
 - Compiling the kernel
 - Running the kernel
 - Adding custom userspace programs

## Downloading the Pieces

To get started we will create a temporary directly and setup our environment, if
you plan to do a lot of OpenRISC development consider adding these tools to your
`PATH` permanently.

To get everything you need run:

```bash
mkdir /tmp/linux-on-qemu/
cd /tmp/linux-on-qemu/

# Download qemu source, linux source, a buildroot rootfs and our toolchain
curl -L -O https://download.qemu.org/qemu-9.2.4.tar.xz
curl -L -O https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.5.tar.xz
curl -L -O https://github.com/stffrdhrn/or1k-rootfs-build/releases/download/or1k-20250708/buildroot-qemu-rootfs-20250708.tar.xz
curl -L -O https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-nonehf-linux-gnu-15.1.0-20250621.tar.xz

# Extract everything
tar -xf qemu-9.2.4.tar.xz
tar -xf linux-6.15.5.tar.xz
tar -xf buildroot-qemu-rootfs-20250708.tar.xz
tar -xf or1k-nonehf-linux-gnu-15.1.0-20250621.tar.xz

export PATH=$PATH:$PWD/or1k-nonehf-linux-gnu/bin
```

## Setting up QEMU

This tutorial requires the `qemu-system-or1k` binary from QEMU with at least
version 9.2.1.  This versoin is now available on some distributions out-of-the-box, if available you
can skip compiling QEMU from scratch.  So, let's check if that is available first.

### Checking if your Distribution has an up-to-date QEMU

#### QEMU on fedora

```bash
# Look for the qemu system package
dnf info qemu-system-or1k

# If the version is good:
dnf install qemu-system-or1k
```

Below we can see the Fedora Project provides an up to date version for
QEMU.  We can install it.

```
$ dnf info qemu-system-or1k
Updating and loading repositories:
Repositories loaded.
Available packages
Name           : qemu-system-or1k
Epoch          : 2
Version        : 9.2.4
Release        : 1.fc42
Architecture   : x86_64
Download size  : 14.6 KiB
Installed size : 0.0   B
Source         : qemu-9.2.4-1.fc42.src.rpm
Repository     : updates
Summary        : QEMU system emulator for OpenRisc32
URL            : http://www.qemu.org/
...
Vendor         : Fedora Project
```

#### QEMU on Debian/Ubuntu

In Debian based distributions `qemu-system-or1k` is provided by the `qemu-system-misc` package.

```bash
# Look for the qemu system package
apt-cache update
apt-cache show qemu-system-misc | grep Version

# if the version is good
apt-get install -y qemu-system-misc
```

Below we can see that in my Ubuntu environment it only provides QEMU 8.2.2.
In this case we must compile QEMU from source.

```
# apt-cache show qemu-system-misc | grep Version
Version: 1:8.2.2+ds-0ubuntu1.7
Version: 1:8.2.2+ds-0ubuntu1.4
Version: 1:8.2.2+ds-0ubuntu1
```

#### QEMU on Others

If you use another distrobution you are probably advanced enough to figure out
how to check for the QEMU package and version on your own.  If you can't figure
it out then you can compile the source code.

### Compiling QEMU from sources

Continuing from the environment above, we can compile QEMU with the commands below.

During configuration we provide the option `--enable-fdt` to support
[devicetree](https://docs.kernel.org/devicetree/usage-model.html)
which is used by QEMU to communicate the system layout to the kernel.  Also,
we enable both `or1k-softmmu` which is the QEMU full system emulator and
`or1k-linux-user` which is an emulator that translates and passes system calls to your
host operating system.  In this tutorial we will not look into the
`or1k-linux-user` emulator but it's good to know about.

```bash
cd /tmp/linux-on-qemu/qemu-9.2.4
./configure --enable-fdt --target-list="or1k-softmmu or1k-linux-user"
make -j$(nproc)

# Add QEMU to your path
export PATH=$PWD/build:$PATH
cd /tmp/linux-on-qemu
```

If all worked well you should be able to see QEMU available via the following
command:

```bash
qemu-system-or1k --version
```

For example:

```
$ qemu-system-or1k --version
QEMU emulator version 9.2.4
Copyright (c) 2003-2024 Fabrice Bellard and the QEMU Project developers
```

## Running the or1ksim kernel

In the [Linux on or1ksim](linux-on-or1ksim.html) tutorial we built a simple kernel that runs on
the or1ksim platform.  QEMU can also simulate the or1ksim platform, so we can run the same
kernel on QEMU.

To do this run:

```bash
qemu-system-or1k -cpu or1200 -machine or1k-sim \
  -kernel /tmp/linux-on-or1ksim/linux-6.15.5/vmlinux \
  -nic user,net=10.9.0.0/24,host=10.9.0.100,dns=10.9.0.3 \
  -serial mon:stdio \
  -nographic \
  -gdb tcp::10001 \
  -m 32 \
  -append earlycon
```

This will start qemu using the `or1k-sim` machine which is equivelent to the
`or1ksim` platform.  The other options are:

 - `-kernel KERNEL` - tells QEMU to load the Linux kernel into memory before booting the
   system
 - `-nic user,net=10.9.0.0/24,host=10.9.0.100,dns=10.9.0.3` - Configures
   userspace networking.  The default QEMU configures is network `10.0.2.0/24`,
   we override this to match the `10.9.0.0/24` network that we have built into
   the busybox rootfs.
 - `-serial mon:stdio` and `-nographic` - by default QEMU will try to start
   a graphics terminal.  This enables a simple commandline terminal and monitor.
   to access the monitor run `Ctrl+A C`.
 - `-gdb tcp::10001` - Configures a GDB server that we can connect to with
   `or1k-elf-gdb` to debug Linux.
 - `-m 32` - Configures the QEMU system to use 32MB of RAM, consistent with the
   `or1ksim` default.
 - `-append earlycon` - Passes the `earlycon` argument to the Linux kernel
   command line.  The [earlycon](https://www.kernel.org/doc/html/v5.16/admin-guide/kernel-parameters.html) argument provides early console output which
   is helpful for debugging kernel boot issues.

For example:

```
$ qemu-system-or1k -cpu or1200 -machine or1k-sim   -kernel /home/shorne/work/linux/vmlinux   -nic user,net=10.9.0.0/24,host=10.9.0.100
,dns=10.9.0.3,hostfwd=tcp::2222-:22   -serial mon:stdio   -nographic   -gdb tcp::10001   -smp cpus=1   -m 32   -append earlyconb
FDT at (ptrval)
Linux version 6.15.0-00004-g0dfb061db5b3 (shorne@antec) (or1k-linux-gcc.br_real (Buildroot 2021.11-12449-g1bef613319) 13.3.0, GNU ld (GNU Binutils) 2.41) #122 Sun
 Jul 20 10:14:56 BST 2025
OF: reserved mem: Reserved memory: No reserved-memory node in the DT
CPU: OpenRISC-13 (revision 8) @20 MHz
-- dmmu:  128 entries, 1 way(s)
-- immu:  128 entries, 1 way(s)
-- additional features:
-- power management
-- PIC
-- timer
Initial ramdisk not found
Setting up paging and PTEs.
map_ram: Memory: 0x0-0x2000000
Zone ranges:
  Normal   [mem 0x0000000000000000-0x0000000001ffffff]
Movable zone start for each node
...
Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
printk: legacy console [ttyS0] disabled
90000000.serial: ttyS0 at MMIO 0x90000000 (irq = 2, base_baud = 1250000) is a 16550A
printk: legacy console [ttyS0] enabled
90000100.serial: ttyS1 at MMIO 0x90000100 (irq = 2, base_baud = 1250000) is a 16550A
90000200.serial: ttyS2 at MMIO 0x90000200 (irq = 2, base_baud = 1250000) is a 16550A
90000300.serial: ttyS3 at MMIO 0x90000300 (irq = 2, base_baud = 1250000) is a 16550A
-- dcache disabled
-- icache disabled
NET: Registered PF_PACKET protocol family
clk: Disabling unused clocks
Freeing unused kernel image (initmem) memory: 5360K
This architecture does not have kernel memory protection.
Run /init as init process
ethoc 92000000.ethoc eth0: Link is Up - 100Mbps/Full - flow control off

Please press Enter to activate this console. 
~ # ls
bin      etc      lib      mnt      root     sys      usr
dev      init     linuxrc  proc     sbin     tmp      var
~ # exit

Please press Enter to activate this console. 
~ # poweroff
~ # Shutting down...
The system is going down NOW!
Sent SIGTERM to all processes
Sent SIGKILL to all processes
Requesting system poweroff
reboot: Power off not available: System halted instead
*** MACHINE HALT ***
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000000
---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000000 ]---
QEMU 9.2.3 monitor - type 'help' for more information
(qemu) q
```

 - To exit I used `Ctrl+a c` to enter the monitor console, then `q` to quit.

Notice how `poweroff` did not work to stop the system.  This is because
`or1ksim` does not provide powerdown hardware. This is fixed in the QEMU `virt`
environment.

## Compiling the QEMU `virt` Kernel

In the previous section we booted the `or1ksim` kernel.  That kernel is limited
as it support only devices available on the `or1ksim` platform, no multicore
and no filesystem persistence.  Using the OpenRISC QEMU `virt` (virtual)
platform we have an extensible platform that allows us to plug in virtually
any available QEMU device.

To build a Linux kernel we use the toolchain and kernel source code downloaded
previously with the following make commands:

```bash
cd /tmp/linux-on-qemu/

# Configure
make -C linux-6.15.5 \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-nonehf-linux-gnu- \
  virt_defconfig

# Build
make -C linux-6.15.5 \
  -j12 \
  ARCH=openrisc \
  CROSS_COMPILE=or1k-nonehf-linux-gnu-
```

The first command configures the kernel with the configuration `virt_defconfig` which is the QEMU `virt` platform configuration. The `make`
arguments are as follows:

 * `-C linux-6.15.5` - This saves us from having to change directory, `make` will run from within the Linux source code directory.
 * `ARCH=openrisc` - This passes the `ARCH` variable to the build system selecting the OpenRISC architecture.
 * `CROSS_COMPILE=or1k-nonehf-linux-gnu-` - This passes the `CROSS_COMPILE` variable to the build system selecting our toolchain.
 * `virt_defconfig` - The make target, configures the linux kernel for the build.

## Running the Kernel

To start Linux on QEMU `virt` we run `or1k-system-or1k` passing the kernel and device configurations arguments.
This will:

 1. Initialize the OpenRISC virt simulator
 2. Load the kernel image into memory
 3. Load the QEMU generated devicetree into memory
 4. Sets register arguments for the boot process:
   - `r3` - is set to point to the location of the device tree in memory
 5. Reset the simulator CPU to PC 0x100 kicking off the kernel boot process

```bash
qemu-system-or1k -cpu or1200 -machine virt \
  -kernel /tmp/linux-on-qemu/linux-6.15.5/vmlinux \
  -device virtio-net-pci,netdev=user \
  -netdev user,id=user,net=10.9.0.1/24,host=10.9.0.100,hostfwd=tcp::2222-:22 \
  -serial mon:stdio -nographic \
  -device virtio-blk-device,drive=d0 \
  -drive file=/tmp/linux-on-qemu/buildroot-qemu-rootfs-20250708/qemu-or1k-rootfs.qcow2,id=d0,if=none,format=qcow2 \
  -gdb tcp::10001 \
  -accel tcg,thread=multi -smp cpus=4 \
  -m 768 \
  -append "earlycon rootwait root=/dev/vda2"
```

The arguments can be explained as follows:

 - `-kernel KERNEL` - tells QEMU to load the Linux kernel into memory before booting the
   system
 - `-device virtio-net-pci,netdev=user` - Plugs a `virtio-net-pci` [network device](https://wiki.qemu.org/Documentation/Networking)
    onto the platform's PCI bus.
 - `-netdev user,id=user,net=10.9.0.1/24,host=10.9.0.100,hostfwd=tcp::2222-:22` - Configures
   userspace networking.  The default QEMU configures is network `10.0.2.0/24`,
   we override this to match the `10.9.0.0/24` network that we have built into
   the buildroot rootfs.  Also, we setup to forward `localhost` port `2222` to the
   platforms port `22`.  This allows us to SSH to the platform.
 - `-serial mon:stdio` and `-nographic` - by default QEMU will try to start
   a graphics terminal.  This enables a simple commandline terminal and monitor.
   to access the monitor run `Ctrl+A C`.
 - `-device virtio-blk-device,drive=d0` - Plugs a `virtio-blk-device` block
   device onto the platform's PCI bus.
 - `-drive file=/tmp/linux-on-qemu/buildroot-qemu-rootfs-20250708/qemu-or1k-rootfs.qcow2,id=d0,if=none,format=qcow2` - Configures
   the block device drive to be backed by the `qcow2` file that we downloaded
   earlier.
 - `-gdb tcp::10001` - Configures a GDB server that we can connect to with
   `or1k-elf-gdb` to debug Linux.
 - `-accel tcg,thread=multi -smp cpus=4` - Configures 4 CPU cores to run on 4 OS threads.
 - `-m 768` - Configures the QEMU system to use 768MB of RAM.
 - `-append "earlycon rootwait root=/dev/vda2"` - Passes the `earlycon` argument to the Linux kernel
   command line.  The [earlycon](https://www.kernel.org/doc/html/v5.16/admin-guide/kernel-parameters.html) argument provides early console output which
   is helpful for debugging kernel boot issues.  The other perameters tell the
   kernel which disk contains our root filesystem.


## Example Boot Sequence

 - Below we login with `root`
 - We can then shutdown using the `poweroff` command

```
$ qemu-system-or1k -cpu or1200 -machine virt -no-reboot -kernel /home/shorne/work/linux/vmlinux -device virtio-net-pci,netdev=user -netdev user,id=user,net=10
.9.0.1/24,host=10.9.0.100,hostfwd=tcp::2222-:22 -serial mon:stdio -nographic -device virtio-blk-device,drive=d0 -drive file=/home/shorne/work/openrisc/buildroot-r
ootfs/qemu-or1k-rootfs.qcow2,id=d0,if=none,format=qcow2 -gdb tcp::10001 -smp cpus=1 -m 768 -append earlycon rootwait root=/dev/vda2
[    0.000000] FDT at (ptrval)
[    0.000000] random: crng init done
[    0.000000] Linux version 6.15.0-00004-g0dfb061db5b3 (shorne@antec) (or1k-linux-gcc.br_real (Buildroot 2021.11-12449-g1bef613319) 13.3.0, GNU ld (GNU Binutils)
 2.41) #123 SMP Mon Jul 21 06:34:34 BST 2025
[    0.000000] OF: reserved mem: Reserved memory: No reserved-memory node in the DT
[    0.000000] CPU: OpenRISC-13 (revision 8) @20 MHz
[    0.000000] -- dmmu:  128 entries, 1 way(s)
[    0.000000] -- immu:  128 entries, 1 way(s)
[    0.000000] -- additional features:
[    0.000000] -- power management
[    0.000000] -- PIC
[    0.000000] -- timer
[    0.000000] Initial ramdisk not found
[    0.000000] Setting up paging and PTEs.
[    0.000000] map_ram: Memory: 0x0-0x30000000
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x0000000000000000-0x000000002fffffff]
[    0.000000] Movable zone start for each node
...
setting coredumps ...
Starting sshd: OK

Welcome to Linux on OpenRISC
buildroot login: root
  _      __    __
 | | /| / /__ / /______  __ _  ___
 | |/ |/ / -_) / __/ _ \/  ' \/ -_)
 |__/|__/\__/_/\__/\___/_/_/_/\__/
                   / /____
                  / __/ _ \
  ____     _____  \__/\___/________  ______
 / __ \___<  / /_____| | / /  _/ _ \/_  __/
/ /_/ / __/ /  '_/___/ |/ // // , _/ / /
\____/_/ /_/_/\_\    |___/___/_/|_| /_/

 32-bit OpenRISC CPUs on a QEMU Virt Platform
# poweroff

Broadcast message from root@buildroot (console) (Wed Apr 30 08:23:45 2053):

The system is going down for system halt NOW!
INIT: Switching to runlevel: 0
INIT: No inittab.d directory found
Stopping sshd: stopped /usr/sbin/sshd (pid 135)
OK
unmounting nfs ...
umount: can't unmount /home/shorne/work: Invalid argument
Stopping crond: stopped /usr/sbin/crond (pid 125)
OK
Nothing to do, sntp is not a daemon.
Stopping network: OK
Stopping klogd: OK
Stopping syslogd: stopped /sbin/syslogd (pid 91)
OK
Seeding 256 bits and crediting
Saving 256 bits of creditable seed for next boot
umount: tmpfs busy - remounted read-only
umount: devtmpfs busy - remounted read-only
[   79.820000] EXT4-fs (vda2): re-mounted 775adf4e-2951-4464-bf7d-c9bbef55bb81 ro.
[   79.840000] reboot: Power down
[   79.840000] *** MACHINE POWER OFF ***
```

## Adding Custom User Space Programs

#### In the QEMU Console

As `root` you can add new users by setting up the environment as below.  The below
setup will create a user named `virt`, you can use any name you like.

```bash
# Setup the skeleton home directory, if needed add `.profile` etc. here.
mkdir /etc/skel
# Add the /home directory
mkdir /home

# Create a group named 'virt' for users
addgroup virt
# Create a user named 'virt'
adduser virt -G virt
```

#### On your Workstation

To add your own programs to the QEMU `virt` platform we use the [glibc](https://www.gnu.org/software/libc/)
toolchain to build executables as follows:

```bash
curl -L -O https://openrisc.io/tutorials/sw/hello/hello.c

or1k-nonehf-linux-gnu-gcc hello.c -o hello
```

This compiles the `hello.c` program and outputs the binary as `hello`.
The toolchain and rootfs runtime support c and c++ programs.

Next we can copy the program to the QEMU platform using the `scp` command.

```bash
scp -P 2222 hello virt@localhost:

# SSH to qemu to run the program
ssh -P 2222 virt@localhost
./hello
```

Example session:

```
$ scp -P 2222 hello virt@localhost: 
hello                                 100%   11KB   1.2MB/s   00:00
$ ssh -P 2222 virt@localhost
  _      __    __
 | | /| / /__ / /______  __ _  ___
 | |/ |/ / -_) / __/ _ \/  ' \/ -_)
 |__/|__/\__/_/\__/\___/_/_/_/\__/
                   / /____
                  / __/ _ \
  ____     _____  \__/\___/________  ______
 / __ \___<  / /_____| | / /  _/ _ \/_  __/
/ /_/ / __/ /  '_/___/ |/ // // , _/ / /
\____/_/ /_/_/\_\    |___/___/_/|_| /_/

 32-bit OpenRISC CPUs on a QEMU Virt Platform
$ ./hello 
Hello QEMU!
$ 
```

The buildroot system also support gdb, so we can debug our
programs as usual.  Example debug session.

```
$ gdb hello
GNU gdb (GDB) 15.2
Copyright (C) 2024 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "or1k-buildroot-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from hello...
(No debugging symbols found in hello)
(gdb) b main
Breakpoint 1 at 0x23c8
(gdb) r
Starting program: /home/virt/hello 
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/libthread_db.so.1".

Breakpoint 1, 0x000023c8 in main ()
(gdb) bt
#0  0x000023c8 in main ()
(gdb) x/12i $pc
=> 0x23c8 <main+16>:    l.movhi r17,0x0
   0x23cc <main+20>:    l.addi r3,r17,9208
   0x23d0 <main+24>:    l.jal 0x2270 <puts>
   0x23d4 <main+28>:    l.nop 0x0
   0x23d8 <main+32>:    l.movhi r17,0x0
   0x23dc <main+36>:    l.or r11,r17,r17
   0x23e0 <main+40>:    l.lwz r2,0(r1)
   0x23e4 <main+44>:    l.lwz r9,4(r1)
   0x23e8 <main+48>:    l.addi r1,r1,8
   0x23ec <main+52>:    l.jr r9
   0x23f0 <main+56>:    l.nop 0x0
   0x23f4 <_IO_stdin_used>:     l.j 0x823f8
```

## Further Reading

 - [openrisc/or1ksim](https://github.com/openrisc/or1ksim) - The or1ksim home page and git repo
 - [or1ksim Releases](https://github.com/openrisc/or1ksim/releases) - Nightly build and point release
 - [Linux Releases](https://kernel.org) - Linux release tarballs
 - [OpenRISC toolchain Releases](https://github.com/stffrdhrn/or1k-toolchain-build/releases) - Toolchain point releases
 - [OpenRISC rootfs Releases](https://github.com/stffrdhrn/or1k-rootfs-build/releases) - Rootfs point release
