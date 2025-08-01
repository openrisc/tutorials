## OpenRISC Tutorials

This repository contains the source for the [OpenRISC architecture tutorials](https://openrisc.io/tutorials/)

These documents are helpful for users who want to get started
developing software and SoC's using the OpenRISC cpu architecture.

## Outline

We are currently in progress working on a new structure
and the intended outline is:

 - [Intro](https://openrisc.io/tutorials/) - OK
   - Programmers Guide - Link to architecture spec, etc.
   - Getting EDA tools, quartus, vivado

 - [Toolchains](https://openrisc.io/tutorials/toolchains.html) - Stub *TODO*
   - Binaries - downloads from github, need to setup CI for building

   - Tutorials
     - or1k-linux-          gcc
     - or1k-elf-            [newlib](https://openrisc.io/tutorials/newlib.html) - OK
     - or1k-unknown-gnu-    [glibc](https://openrisc.io/tutorials/glibc.html) - Stub *TODO*
     - or1k-unkiown-musl-   [musl](https://openrisc.io/tutorials/musl.html) - Stub *TODO*
     - or1k-unknown-uclibc-

 - [Platforms](https://openrisc.io/tutorials/platforms.html) - Stub *TODO*
   - Loading binaries into platforms. ELF binaries explanation.
   - Programs on OpenRISC
     - Memory layout
     - Elf binary lays out memory for linux/bare metal.
   - Tutorials
     - [or1ksim](https://openrisc.io/tutorials/or1ksim/) - OK
     - [QEMU](https://openrisc.io/tutorials/platform/qemu.html) - OK
     - [Fusesoc](https://openrisc.io/tutorials/fusesoc.html) - OK
       - `mor1kx-generic` - *TODO*
       - `de0_nano-multicore` - *TODO*
       - [de0_nano](https://openrisc.io/tutorials/de0_nano/) - OK
     - Litex *TODO*

  - [Linux on OpenRISC](https://openrisc.io/tutorials/docs/Linux.html) - Stub/Outdated move/remove? *TODO*
    - Memory Layout
      - In addition to ELF binary
      - Device tree
      - Rootfs loaded to memory for embedded systems / no sd card
    - Rootfs
      - buildroot
      - busybox
    - Tutorials
      - [linux on or1ksim](https://openrisc.io/tutorials/docs/linux-on-or1ksim.html) - OK
        - defconfig + busybox
      - [linux on QEMU](https://openrisc.io/tutorials/docs/linux-on-qemu.html) - OK
        - virt_defconfig + buildroot
      - Running linux on Litex SoC *TODO*
        - SIM + litex_defconfig + buildroot
        - arty + litex_defconfig + buildroot
      -  Running Linux on fusesoc SoC *TODO*
        - SIM + defconfig + busybox
        - de0_nano + defconfig + busybox
        - de0_nano-multicore + smp_defconfig + busybox
