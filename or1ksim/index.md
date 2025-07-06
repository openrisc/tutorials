---
title: or1ksim
layout: page
parent: Platforms
nav_order: 2
---

# Files

 - [or1ksim.cfg](or1ksim.cfg) - config needed for or1ksim
 - [or1ksim-2025-04-27.tar.gz](https://github.com/openrisc/or1ksim/releases/download/2025-04-27/or1ksim-2025-04-27.tar.gz)
 - [timer.c](./sw/timer/timer.c) - timer program
# or1ksim Tutorial

If you downloaded the tutorials as a release archive, you can directly
start. If you have cloned the git repository, you instead need to
follow the instructions for building the hardware and software as
described below. Please also follow the
[common tutorial setup](../README.md).

To run the demo you need:

* `or1k-sim` in your `PATH`, check with

	or1k-sim --version

## Run hello world

	or1k-sim -f or1ksim.cfg hello.elf

You can find that the last output is `Hello World!`. or1ksim can be
much more verbose and give you a full execution trace:

	or1k-sim -f or1ksim.cfg hello.elf -t

This is of course a lot slower and the simulation exits after a
while. You can finish the simulation before with `CTRL+C`, which will
take you to the simulators command line (`(sim) `). You can exit the
command line with `quit`.

## Run the timer example

	or1k-sim -f or1ksim.cfg timer.elf

In the terminal you can see an UART output every *simulated*
second. You can quit this as described before.

## Boot Linux

You can also boot Linux:

	or1k-sim -f or1ksim.cfg ../vmlinux

## (Re-)build the baremetal software

Some example software is available, that you can (re-)build for the
DE0 nano board by running

	make build-sw

## Links

 - [openrisc/or1ksim](https://github.com/openrisc/or1ksim) - The home page and git repo
 - [Releases](https://github.com/openrisc/or1ksim/releases) - Nightly build and point release
