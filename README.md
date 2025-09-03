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

## How To Contribute

All pages in the tutorials are built using the Jekyll and the Jekyll using the Just the Docs template. Therefore, **each Markdown file must include the following YAML configuration at the top**:

``` txt
---
title: "Page Title"
layout: layout_setting
nav_order: 1            # Navigation order
parent: "Parent Page"   # Parent page (optional)
---
```

The layout parameter typically supports three types: `default`, `home`, and `page`.
The nav_order setting determines the order of pages in the navigation menu, while the optional parent field is used to associate a child page with its parent. For more detailed information on configuring Just the Docs, please refer to the [official documentation](https://just-the-docs.com/).

### How To Deloyment on Local Env

To set up a local deployment environment, ensure your system meets the required dependencies. The instructions below are based on an environment:

``` bash
OS: Ubuntu 24.10 x86_64
Kernel: 6.11.0-29-generic
```

First, install the necessary packages using the following command:

``` bash
sudo apt-get install ruby-full build-essential zlib1g-dev # for Ubuntu apt
sudo apt-get install ruby-full build-essential # for Debian apt
sudo dnf install ruby ruby-devel openssl-devel redhat-rpm-config gcc-c++ @development-tools # for Fedora dnf
```

For more installation methods of other distribution versions, please refer to [Jekyll on Linux](https://jekyllrb.com/docs/installation/other-linux/). **For all distribution versions, Jekyll can be installed using the following command**:

``` bash
gem install jekyll bundler
```

> **Note: If you use RVM to manage Ruby installations, please refer to [rvm.io](https://rvm.io/)**.

If you only intend to deploy the site locally, clone the repository directly. However, if you plan to contribute, please fork the repository and submit a pull request according to the contribution guidelines:

``` bash
git clone https://github.com/openrisc/tutorials.git
cd tutorials
```

Next, configure Bundler to install dependencies into the vendor/bundle directory within the project:

``` bash
(tutorials)$ bundle config set --local path vendor/bundle
```

Verify the configuration with:

``` bash
(tutorials)$ bundle config get path
Settings for `path` in order of priority. The top value will be used
Set for your local app ($HOME/tutorials/.bundle/config): "vendor/bundle"
```

Then, install the specific dependencies listed in the Gemfile. After installation, build the site using:

``` bash
(tutorials)$ bundle install
(tutorials)$ bundle exec jekyll build
$HOME/tutorials/vendor/bundle/ruby/3.3.0/gems/liquid-4.0.4/lib/liquid/standardfilters.rb:2: warning: bigdecimal was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.4.0. Add bigdecimal to your Gemfile or gemspec. Also contact author of liquid-4.0.4 to add bigdecimal into its gemspec.
Configuration file: $HOME/tutorials/_config.yml
            Source: $HOME/tutorials
       Destination: $HOME/tutorials/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 0.391 seconds.
 Auto-regeneration: disabled. Use --watch to enable.
```

Once the build is successful, start the local server with:

``` bash
(tutorials)$ bundle exec jekyll serve
$HOME/tutorials/vendor/bundle/ruby/3.3.0/gems/liquid-4.0.4/lib/liquid/standardfilters.rb:2: warning: bigdecimal was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.4.0. Add bigdecimal to your Gemfile or gemspec. Also contact author of liquid-4.0.4 to add bigdecimal into its gemspec.
Configuration file: $HOME/tutorials/_config.yml
            Source: $HOME/tutorials
       Destination: $HOME/tutorials/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 0.388 seconds.
 Auto-regeneration: enabled for '$HOME/tutorials'
    Server address: http://127.0.0.1:4000
  Server running... press ctrl-c to stop.
```

The site will be available at `http://127.0.0.1:4000`. Press Ctrl+C to stop the server when you are done.
