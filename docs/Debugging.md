---
title: Debugging FPGAs with OpenOCD and GDB
layout: home
---

### Prerequisites

#### Software

* `or1k-elf` toolchain with gdb [Releases](https://github.com/stffrdhrn/or1k-toolchain-build/releases)
* OpenOCD
* A running OpenRISC SoC using `adv_debug_sys`

## Debugging OpenRISC on FPGAs

The OpenRISC cpu and toolchain provide a full debugging environment when running
on FPGAs using gdb and OpenOCD.  At a low level this is provided with
[adv_debug_sys](https://github.com/olofk/adv_debug_sys) which provides jtag
interface for OpenOCD to talk to.  Much can be done directly in OpenOCD. But for
a full debug environments we recommend GDB. GDB communicates with OpenOCD as a
remote target and provides a familiar debugging environment for programmers.

### OpenOCD Basics

OpenOCD is a brirdge for accessing hardware connected to a workstation via JTAG.
OpenOCD requires a configuration file to start up.  The configuration files
specify the chips details (jtag tap) and the details of the interface we are
using.

You can also define `init` and `reset` hooks to perform extra operations to
propertly refresh and initialize your system. See details on the OpenOCD user
guide on
[Target Events](http://openocd.org/doc/html/CPU-Configuration.html#targetevents).

```
# command for starting openocd when connecting to openrisc on the altera de0 nano
#  -s specifies the files source path
#  -f specifies config files to load

OPENOCD={location of openocd}
openocd -s $OPENOCD/scripts -f interface/altera-usb-blaster.cfg -f board/or1k_generic.cfg

Open On-Chip Debugger 0.10.0-dev-00247-g73b676c (2016-03-03-15:18)
Licensed under GNU GPL v2
...
Info : adv debug unit is configured with option ADBG_USE_HISPEED
Info : adv debug unit is configured with option ENABLE_JSP_MULTI
Info : adv debug unit is configured with option ENABLE_JSP_SERVER
Halting processor
or1200.cpu: target state: halted
Chip is or1200.cpu, Endian: big, type: or1k
Target ready...
```

Once started OpenOCD will start listening on 2 TCP ports
 * 4444 - OpenOCD telnet interface
 * 3333 - GDB target interface

You can connect to the 4444 telnet interface and do things such as follows

```
# Telnet to OpenOCD
telnet localhost 4444

# Initialize the init script
init

# Perform a reset
reset

requesting target halt and executing a soft reset

# Halt the cpu
halt

# Load an image (the image location is relative to the working directory of openocd)
load_image tutorials/de0_nano/hello.elf

# Set a register (in this case next program counter)
# OpenRISC reset vector is 0x100 so this causes the cpu to jump
# to the start of our program which should start at 0x100
reg npc 0x100

# Resume execution after a halt
resume

# For loading a linux image you can do it all at one time.
# Notice here we also reset r3 which linux uses as a bootargs
# vector.
halt; load_image vmlinux; reg r3 0; reg npc 0x100; resume

# Inspect registers
reg npc

npc (/32): 0x00006BC0

# Inspect all registers
reg

===== OpenRISC 1000 registers:
(0) r0 (/32)
(1) r1 (/32)
(2) r2 (/32)
(3) r3 (/32)
...
(2212) itlbw3mr126 (/32)
(2213) itlbw3tr126 (/32)
(2214) dtlbw3mr127 (/32)
(2215) dtlbw3tr127 (/32)
(2216) itlbw3mr127 (/32)
(2217) itlbw3tr127 (/32)
(2218) rtest (/32)

# Inspecting memory
mdw 0x100

0x00000100: 18000000

# Finish up
exit

```

### GDB Basics

[GDB](https://sourceware.org/gdb/) is a very popular debugger that allows
inspecting programs running on a cpu (target).

When we debug OpenRISC cpus running on FPGAs GDB connects to the remote OpenRISC
target via the debug tcp port provided by OpenOCD.  Once OpenOCD is running we
can start GDB as follows:

```
# Starting up gdb (with a remote target)
or1k-elf-gdb hello.elf --eval-command='target remote localhost:3333'

# Issue any OpenOCD commands by prefixing with monitor
monitor init
monitor reset

# Loading an image
load

Loading section .vectors, size 0x2000 lma 0x0
Loading section .init, size 0x28 lma 0x2000
Loading section .text, size 0x4da0 lma 0x2028
Loading section .fini, size 0x1c lma 0x6dc8
Loading section .rodata, size 0x1c lma 0x6de4
Loading section .eh_frame, size 0x4 lma 0x8e00
Loading section .ctors, size 0x8 lma 0x8e04
Loading section .dtors, size 0x8 lma 0x8e0c
Loading section .jcr, size 0x4 lma 0x8e14
Loading section .data, size 0xc74 lma 0x8e18
Start address 0x100, load size 31372
Transfer rate: 329 KB/sec, 2091 bytes/write.

# List our program (if its c)
l

1       #include <stdio.h>
2
3       int main(int argc, char* argv[]) {
4         printf("Hello World!\n");
5         return 0;
6       }

# See actual assembly
disas

Dump of assembler code for function main:
   0x00002398 <+0>:     l.sw -8(r1),r2
   0x0000239c <+4>:     l.addi r2,r1,0
   0x000023a0 <+8>:     l.sw -4(r1),r9
   0x000023a4 <+12>:    l.addi r1,r1,-16
   0x000023a8 <+16>:    l.sw -12(r2),r3
   0x000023ac <+20>:    l.sw -16(r2),r4
=> 0x000023b0 <+24>:    l.movhi r3,0x0
   0x000023b4 <+28>:    l.ori r3,r3,0x6de4
   0x000023b8 <+32>:    l.jal 0x252c <puts>
   0x000023bc <+36>:    l.nop 0x0
   0x000023c0 <+40>:    l.addi r3,r0,0
   0x000023c4 <+44>:    l.ori r11,r3,0x0
   0x000023c8 <+48>:    l.ori r1,r2,0x0
   0x000023cc <+52>:    l.lwz r2,-8(r1)
   0x000023d0 <+56>:    l.lwz r9,-4(r1)
   0x000023d4 <+60>:    l.jr r9
   0x000023d8 <+64>:    l.nop 0x0
End of assembler dump.

# Inspecing Registers

## Inspecting a single register
info reg r1

r1             0x1ffdff0        33546224

## Listing all general registers.
info reg

r0             0x0      0                 (always zero)
r1             0x1ffdff0        33546224  (stack pointer)
r2             0x1ffe000        33546240  (frame pointer)
r3             0x0      0
r4             0x0      0
r5             0x0      0
r6             0xffffffc3       -61
r7             0x39080  233600
r8             0x1c2000 1843200
r9             0x2130   8496              (return address)
r10            0x0      0
r11            0x0      0
r12            0x9a8c   39564
r13            0x5      5
r14            0x20     32
r15            0x80000000       -2147483648
r16            0x0      0
r17            0x0      0
r18            0x0      0
r19            0x0      0
r20            0x0      0
r21            0x0      0
r22            0x22     34
r23            0x0      0
r24            0x0      0
r25            0x0      0
r26            0x0      0
r27            0x0      0
r28            0x0      0
r29            0x0      0
r30            0x0      0
r31            0x0      0

## Listing all special register groups
maint print reggroups

Group      Type
 system     user
 dmmu       user
 immu       user
 dcache     user
 icache     user
 mac        user
 debug      user
 perf       user
 power      user
 pic        user
 timer      user

## Listing registers in a register group
info reg system

vr             0x10000040       268435520
upr            0x55f    1375
cpucfgr        0x3820   14368
dmmucfgr       0x18     24
immucfgr       0x18     24
dccfgr         0x24c1   9409
iccfgr         0x4c1    1217
dcfgr          0x0      0

# Inspecing Memory

## print 32 hex words of memory contents at location
x/10xw 0x1ffdff0
0x1ffdff0:      0x00000000      0x00000000      0x01ffe000      0x00002130
0x1ffe000:      0xc1fffe92      0x00000004      0xc1fff930      0xc1ffe034
0x1ffe010:      0x00000000      0x00000000

## print 3 instructions at location
x/3ih 0x100
   0x100 <_or1k_reset>: l.movhi r0,0x0
   0x104 <_or1k_reset+4>:       l.movhi r1,0x0
   0x108 <_or1k_reset+8>:       l.movhi r2,0x0

```

These commands and further reading should get you started.

### Further Reading

* [OpenOCD Docs](http://openocd.org/doc/html/) - OpenOCD User Guide
* [JTAG](http://www.fpga4fun.com/JTAG2.html) - How JTAG works
* [GDD Docs](https://sourceware.org/gdb/onlinedocs/gdb/) - Debugging with GDB
