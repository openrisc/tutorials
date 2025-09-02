---
title: Newlib
layout: page
parent: Toolchains
---

Newlib is a toolchain for building baremetal applications.  This allows building applications that run on OpenRISC
hardware without an operating system.

The newlib toolchain produces elf binaries that can be loaded directly into
system memory and exectured.  The binaries include exception vector tables,
support for UART IO and whatever else your program includes.

## Installing

You can install a newlib toolchain with the following commands:

```bash
mkdir /tmp/or1k-toolchains/
cd /tmp/or1k-toolchains/

# Download our toolchain
curl -L -O https://github.com/stffrdhrn/or1k-toolchain-build/releases/download/or1k-15.1.0-20250621/or1k-elf-15.1.0-20250621.tar.xz

# Extract everything
tar -xf or1k-elf-15.1.0-20250621.tar.xz

export PATH=$PATH:$PWD/or1k-elf/bin
```

## Testing

To compile a simple program we can do:

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

Then compile the program with:

```bash
or1k-elf-gcc -Og -g -o hello hello.c
```

We use debug options `-g and -Og` as below we will debug the program.
If everything worked well you should have a `hello` binary now.  For example:

```bash
$ file hello
hello: ELF 32-bit MSB executable, OpenRISC, version 1 (SYSV), statically linked, not stripped
```

## Utilities

The toolchain contains several utilties apart from the compiler.

### objdump

The objdump file can be used to inspect binaries, this includes facilities to decompile the program:

```bash
or1k-elf-objdump -d hello
```

For example:

```
$ or1k-elf-objdump -d hello
hello:     file format elf32-or1k


Disassembly of section .vectors:

00000000 <_or1k_reset-0x100>:
        ...

00000100 <_or1k_reset>:
     100:       18 00 00 00     l.movhi r0,0x0
     104:       18 20 00 00     l.movhi r1,0x0
     108:       18 40 00 00     l.movhi r2,0x0
     10c:       18 60 00 00     l.movhi r3,0x0
     110:       18 80 00 00     l.movhi r4,0x0
     114:       18 a0 00 00     l.movhi r5,0x0
...
00002264 <main>:
    2264:       9c 21 ff f8     l.addi r1,r1,-8
    2268:       d4 01 10 00     l.sw 0(r1),r2
    226c:       9c 41 00 08     l.addi r2,r1,8
    2270:       d4 01 48 04     l.sw 4(r1),r9
    2274:       1a 20 00 00     l.movhi r17,0x0
    2278:       9c 71 69 98     l.addi r3,r17,27032
    227c:       04 00 01 91     l.jal 28c0 <puts> <-- the actual print
    2280:       15 00 00 00     l.nop 0x0
    2284:       1a 20 00 00     l.movhi r17,0x0
    2288:       e1 71 88 04     l.or r11,r17,r17
    228c:       84 41 00 00     l.lwz r2,0(r1)
    2290:       85 21 00 04     l.lwz r9,4(r1)
    2294:       9c 21 00 08     l.addi r1,r1,8
    2298:       44 00 48 00     l.jr r9
    229c:       15 00 00 00     l.nop 0x0

000022a0 <atexit>:
...
```

In the above we can see the `hello` program's code decompiled.  Because
this is a baremetal binary it includes everything including the reset vector
and system initialization code.

### readelf

The `readelf` tool allows reading many parts of an elf binary.  For example
to read program headers we can run:

```bash
or1k-elf-readelf -l hello
```

Example output:

```
$ or1k-elf-readelf -l hello

Elf file type is EXEC (Executable file)
Entry point 0x100
There are 2 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x002000 0x00000000 0x00000000 0x069a8 0x069a8 R E 0x2000
  LOAD           0x0089a8 0x000089a8 0x000089a8 0x006b4 0x00b88 RW  0x2000

 Section to Segment mapping:
  Segment Sections...
   00     .vectors .text .rodata .eh_frame 
   01     .init_array .fini_array .data .bss 
```

Or to read the sections of the binary we can run:

```bash
or1k-elf-readelf -S hello
```

Example output:

```
$ or1k-elf-readelf -S hello
There are 13 section headers, starting at offset 0xabe0:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .vectors          PROGBITS        00000000 002000 002000 00  AX  0   0  1
  [ 2] .text             PROGBITS        00002000 004000 004998 00  AX  0   0  4
  [ 3] .rodata           PROGBITS        00006998 008998 000009 00   A  0   0  1
  [ 4] .eh_frame         PROGBITS        000069a4 0089a4 000004 00   A  0   0  4
  [ 5] .init_array       INIT_ARRAY      000089a8 0089a8 000004 04  WA  0   0  4
  [ 6] .fini_array       FINI_ARRAY      000089ac 0089ac 000004 04  WA  0   0  4
  [ 7] .data             PROGBITS        000089b0 0089b0 0006ac 00  WA  0   0  4
  [ 8] .bss              NOBITS          0000905c 00905c 0004d4 00  WA  0   0  4
  [ 9] .comment          PROGBITS        00000000 00905c 000012 01  MS  0   0  1
  [10] .symtab           SYMTAB          00000000 009070 000e90 10     11  76  4
  [11] .strtab           STRTAB          00000000 009f00 000c76 00      0   0  1
  [12] .shstrtab         STRTAB          00000000 00ab76 000068 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)
```

### CGEN simulator

There is also a tiny no mmu simulator available in the toolchain.  This allows
running simple programs like the `hello` binary we created.  The simulator is generated
by the CGEN descriptions used to describe the OpenRISC platform in gnu binutils.

```bash
or1k-elf-run hello
```

### gdb

The GDB debugger is also available in our toolchain build.  This allows debugging
OpenRISC programs running on OpenRISC systems.  This includes the CGEN simulator.

An example debug session:

```
$ or1k-elf-gdb

(gdb) target sim
Connected to the simulator.

(gdb) load hello
Loading section .vectors, size 0x2000 lma 0
Loading section .text, size 0x4988 lma 2000
Loading section .rodata, size 0x7 lma 6988
Loading section .eh_frame, size 0x4 lma 6990
Loading section .init_array, size 0x4 lma 8994
Loading section .fini_array, size 0x4 lma 8998
Loading section .data, size 0x6ac lma 899c
Start address 100
Transfer rate: 229944 bits in <1 sec.
(gdb) l main
1       #include <stdio.h>
2
3       int main() {
4           puts("Hello\n");
5           return 0;
6       }
(gdb) b 4
Breakpoint 1 at 0x226c: file hello.c, line 4.
(gdb) r
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /tmp/or1k-toolchains/hello 

Breakpoint 1, main () at hello.c:4
4           puts("Hello\n");
(gdb) n
Hello

5           return 0;
(gdb) n
0x00002108 in _or1k_start ()
```

Above we can see a debug session where we:

 1. Start the debugger
 2. Tell the debugger to run programs on the builtin simulator `sim`
 3. Load the `hello` program into the simulator
 4. Set a breakpoint at the `puts` line in in program
 5. Run the program and step through it

## Links

 - [Newlib git](https://sourceware.org/git/gitweb.cgi?p=newlib-cygwin.git) - Upstream repo
 - [Newlib releases](https://sourceware.org/newlib/) - Official release tarbals
 - [openrisc/newlib](https://github.com/openrisc/newlib) - staging for OpenRISC development work.
 - [stffrdhrn/or1k-toolchain-build](https://github.com/stffrdhrn/or1k-toolchain-build) - Tools for building and releasing binaries
 - [OpenRISC newlib binaries](https://github.com/stffrdhrn/or1k-toolchain-build/releases) - The latest OpenRISC binaries from Stafford
