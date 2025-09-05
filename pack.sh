#!/bin/bash -e

# This script generates a binary distribution to allow new users a
# real quick start.

FILES="
Makefile
README.md
bootstrap-quick-start.sh
environment.sh
sw/hello/hello.c
sw/timer/timer.c
or1ksim/Makefile
or1ksim/README.md
or1ksim/or1ksim.cfg
or1ksim/hello.elf
or1ksim/timer.elf
de0_nano/Makefile
de0_nano/README.md
de0_nano/de0_nano.sof
de0_nano/hello.elf
de0_nano/timer.elf
de0_nano/de0_nano.cfg
docs/Debugging.md
"

# Update the de0_nano bitstream if a newer one is available
if [ -e de0_nano/build/de0_nano/bld-quartus/de0_nano.sof ]; then
	cp -u de0_nano/build/de0_nano/bld-quartus/de0_nano.sof de0_nano/de0_nano.sof
fi

# Fail if no bitstream is found
if [ ! -e de0_nano/de0_nano.sof ]; then
	echo "You need to build de0_nano before packing";
	exit 1;
fi

tar -czf openrisc-tutorials.tgz --transform 's,^,openrisc-tutorials/,' $FILES
