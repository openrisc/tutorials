## OpenRISC Tutorials

This repository contains the source for the [OpenRISC architecture tutorials](https://openrisc.io/tutorials/)

These documents are helpful for users who want to get started
developing software and SoC's using the OpenRISC cpu architecture.

## Outline

We are currently in progress working on a new structure
and the intended outline is:

```
Getting started with OpenRISC

Programmers Guide
 - Link to the architecture

Toolchain Options
  Binaries
   - downloads from github, need to setup CI for building

  Obtaining
   - or1k-linux-          gcc
   - or1k-elf-            newlib
   - or1k-unknown-gnu-    glibc
   - or1k-unkiown-musl-   musl
     - https://github.com/richfelker/musl-cross-make - or1k/openrisc needs update
   - or1k-unknown-uclibc-
     - https://uclibc-ng.org/docs/ - docs to build

 Platforms
  Loading binaries into platforms. ELF binaries explaination.
  - or1ksim
  - QEMU
  - Fusesoc
  - Litex

Programs on OpenRISC

 Memory layout
 - Elf binary lays out memeory for linux/bare metal.

Linux on OpenRISC
 Memory layout
 - In addition to ELF binary
 - Device tree
 - Rootfs loaded to memory for embedded systems / no sd card

 Rootfs
 - buildroot
 - busybox

 Running linux on or1ksim
  - defconfig + busybox

 Running linux on QEMU
  - virt_defconfig + buildroot

 Running linux on Litex SoC
  - SIM + litex_defconfig + buildroot
  - arty + litex_defconfig + buildroot

 Running Linux on fusesoc SoC
  - SIM + defconfig + busybox
  - de0_nano + defconfig + busybox
  - de0_nano-multicore + smp_defconfig + busybox
```

