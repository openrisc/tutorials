---
title: Home
layout: home
nav_order: 1
permalink: /
---

# OpenRISC Tutorials

These are tutorials for the [OpenRISC](https://openrisc.io) processor. The tutorials run on
different FPGA boards and simulators. Hence, the different tutorials have
different requirements. Each tutorial tries to be as independent as possible and
will instruct you how to download what is needed, but for FPGA development some
basics will be needed.

## Contributing

If you wish to contribute to the tutorials please see our
[openrisc/totorials](https://github.com/openrisc/tutorials) git repo where this
site's source code is hosted.

Checkout the **TODO** list in `README.md`.

## Programming

These tutorials cover setting up development environments for OpenRISC hardware
and/or software development.  For embedded system programming we recommend
getting familiar with OpenRISC assembly and C.

### Assembly

If you are interested in writing programs in OpenRISC assembly read the
[OpenRISC architecture spec](https://openrisc.io/architecture) to understand the
capabilities and programming model of OpenRISC.

Example of what OpenRISC assembly looks like:

```
        .global _main
_main:
        l.ori   r3, r0, 2
        l.ori   r4, r0, 2
        l.mul   r5, r3, r4
        l.sfeqi r5, 4
        l.bf    test_ok
         l.nop
```

### Bare Metal C/C++

If you want to write programs in bare metal C taking advantage of the OpenRISC
architecture facilities such as exception handling, MMU and timers
checkout the newlib [or1k apis](https://openrisc.io/newlib/docs/html/modules.html).

Example of what OpenRISC bare metal looks like:

```c
#include <or1k-support.h>
#include <or1k-sprs.h>
#include <stdint.h>

void
or1k_interrupts_enable(void)
{
        uint32_t sr = or1k_mfspr(OR1K_SPR_SYS_SR_ADDR);
        sr = OR1K_SPR_SYS_SR_IEE_SET(sr, 1);
        or1k_mtspr(OR1K_SPR_SYS_SR_ADDR, sr);
}

uint32_t
or1k_interrupts_disable(void)
{
        uint32_t oldsr, newsr;
        oldsr= or1k_mfspr(OR1K_SPR_SYS_SR_ADDR);
        newsr = OR1K_SPR_SYS_SR_IEE_SET(oldsr, 0);
        or1k_mtspr(OR1K_SPR_SYS_SR_ADDR, newsr);
        return OR1K_SPR_SYS_SR_IEE_GET(oldsr);
}
```

See the [newlib tutorial](newlib.html) for details on how to setup the newlib development
environment.  Or checkout the [Quickstart tutorial](images.html) for docker images
that have the newlib environment out of the box.

## Tools (partially required)

### FuseSoC

FuseSoC is an automated build environment and package manager for
OpenRISC. You can install it as described
[here](https://github.com/olofk/fusesoc).

Featured in:

 * [De0 Nano](de0_nano/) - De0 Nano FPGA development board platform tutorial.
 * [Quickstart Images](images.html) - Docker verilog development environment

### OpenOCD

The [OpenOCD](http://www.openocd.org) version delivered with the Linux
distributions is most probably outdated. Hence, you can quickly
install a current version.

Featured in:

 * [De0 Nano](de0_nano/) - De0 Nano FPGA development board platform tutorial.
 * [Debugging](docs/Debugging.html) - OpenOCD debugging cheat sheet.

### Quartus Prime

This is the software which compiles RTL and ultimately generates an
FPGA programming file. Unfortunately this software is closed source,
extremely large, and requires registration to download. However, it is
required for some tutorials.

Featured in:

 * [De0 Nano](de0_nano/) - De0 Nano FPGA development board platform tutorial.

For downloading the free version, visit the
[Intel website](https://www.intel.com/content/www/us/en/software-kit/849769/intel-quartus-prime-lite-edition-design-software-version-24-1-for-linux.html) and
download the latest version of Quartus Prime Lite.
It is more than 7GB in size and will obviously take a while to download. Once it
is downloaded, extract it and run the setup.sh file in there. Install
it to any location.

Once downloaded and extracted you can run the installer from the command line as follows:

```bash
./components/QuartusLiteSetup-24.1std.0.1077-linux.run  --mode text \
  --unattendedmodeui none \
  --installdir /opt/quartus-24.1 \
  --disable-components quartus_help --accept_eula 1
```

After installation add the following path (corrected for your
installation) to the search path:

```bash
export PATH=/opt/quartus-24.1/quartus/bin/:$PATH
```

*Note:* Make sure you select to include the Cyclone IV E device
 families during installation.

### Vivado

Like Quartus this is the software which compiles RTL and generates an FPGA
programming file. This software is closed source, extremely large, and requires
registration to download. It is required for the Litex ARTY tutorials.

Visit the [Vivado downloads](https://www.xilinx.com/support/download.html)
page and get the latest version.
