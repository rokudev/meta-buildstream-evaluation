# Roku Meta-BuildStream Evaluation Repo

Hello!

We have a Roku Engineering Blog post about our journey in evaluating a new _Meta Build System_ for RokuOS! Check it out: [You Need a Build System, January 2023 Roku Engineering Blog](https://engineering.roku.com/you-need-a-build-system)

This repository contains an open-source version of a BuildStream evaluation that used the `1.95.3.dev0` version of BuildStream.

NOTICE: This is a historical, initial version of that evaluation, and will not be updated.

Some documentation was also created for new user onboarding with BuildStream. Check out [Hello Universe](Hello-Universe.md)!

## Organization and Architecture Design

This BuildStream 2 project is quite different in comparison to other BuildStream projects. For example, FreeDesktopSDK's primary focus is for cross-compiling for Flatpak containers, which has drastically different goals than what is needed for cross-compiling for Embedded Linux environments.

It was needed to re-design some sort of cross-compilation support from scratch. Looking back at this, it would have been much better to implement this as BuildStream Plugins, instead of just having include'd YAML files, but here we are. Ultimately, what BuildStream needs is some equivalent to OpenEmbedded, which has a proven known working architecture design for cross-compiling for Embedded Linux environments. We attempted to do that here using experience with other build systems.

### Directory Layout

| Path | Description |
|---|---|
| /elements | Individual build pieces |
| /elements/base | Sandbox elements -- Currently FreeDesktopSDK |
| /elements/components | Components, sorted by group |
| /elements/components/common | YAML files that can be included by components in 'host' and/or 'target' |
| /elements/components/host | Components that are intended as a host tool |
| /elements/components/platform-specific | Components that are intentionally platform-specific |
| /elements/components/target | Components that are cross-compiled |
| /elements/platform | Platform stacks to combine common groupings of elements, as well as imaging/packaging stages. |
| /elements/plugins | BuildStream plugins |
| /elements/system | Elements for system-level use (sandbox, toolchain) |
| /elements/toolchain | Elements for building the cross-compiler! |
| /elements/image.bst | The primary element! Intended for the most direct user use: `bst -o target_arch aarch64 -o platform rpi -o debug true build index.bst` will generate full images for the Raspberry Pi, as well as a debug rootfs tarball. |
| /elements/stack.bst | The _actual_ element that defines what goes into what platform. `image.bst` utilizes this as a dependency. |
| /files | Small files for helper items |
| /include | Global YAML files that elements can include |
| /keys | Third-party keys |
| /patches | Patches for elements should go here |
| /sources | Place for small local source code bases to live |
| /sources/hello-world | An example source code base -- compile with: `bst -o target_arch aarch64 build components/target/hello-world.bst` |
| /project.conf | Global BuildStream project configuration file |

### Explanations

This uses the FreeDesktopSDK Bootstrap environment as the base 'sandbox' system. It includes a GCC 11 compiler. They provide both x86_64 and aarch64 variants of it, but this was only tested with the x86_64 version.

It would have been ideal to drop FDSDK entirely and create our own sandbox, but this works fine. This is all located in `elements/base` if you're interested.

### How do components (elements) work?

A component ("element" in BST terms) here lives in `elements/components`. It's .bst definition must include `include/host-component.yml` if it is to compile as a host tool, or `include/cross-compile-component.yml` if it should cross-compile for a target platform. Need it to compile for both? Place your common defines like `source` in a .yml file in `elements/components/common`, and have both versions of your component in `elements/components/host` and `elements/components/target` include it! "rsync" is a good example of that.

#### Compile-on-demand Host Tools

For a simple component example that is going to compile both natively for the Host/Sandbox and cross-compile for the Target/Platform, let's look at `rsync`, since it doesn't have any dependencies on its own:

```
$ bst build components/host/rsync.bst
```

This will compile a working 'rsync' application that can then be used by any build process that depends on it. (An example would be for the cross-compile toolchain's kernel-headers step, `elements/toolchain/pieces/02-kernel-headers.bst`)

Check your new host application with the *BuildStream shell* -- just replace 'build' in the command with 'shell' and enter an interactive sandbox shell:

```
$ bst shell components/host/rsync.bst
[...rsync.bst]$ which rsync
[...rsync.bst]$ rsync --version
[...rsync.bst]$ exit
```

#### Cross-Compiling

Let's build 'rsync' again, but *cross-compile* it! This time, you'll also want to add in an *argument* to `bst` defining our target architecture: Let's say it's "arm" like we're used to. (Other functioning architectures are 'aarch64', 'armhf', and 'x86_64'.)

Also, we'll want to change our build target from `components/host/rsync.bst` to `components/target/rsync.bst`:

```
$ bst -o target_arch arm build components/target/rsync.bst
```

This should succeed. However, you'll notice that there were a lot more steps taken in order to build the cross-compiler -- You should only ever need to do that exactly one time, and then BuildStream will automatically re-use the cached version from now on. Cool, right?

Again, you can explore your build environment by replacing the `build` part of the command with `shell`:

```
$ bst -o target_arch arm shell components/target/rsync.bst
```


### How does it all come together?

In this architecture, everything that is built for the host/sandbox lives in the same standard linux directory structure.  A `$ which rsync` command should point you to `/usr/bin/rsync`, which is the host version we compiled earlier.

The exception to this rule is the cross-compiler, which lives in `/rbst/toolchains/<target_arch_name>`. Right now for this proof-of-concept, we can only have one toolchain at a time, but this can be amended to support multiple rather easily. It's all defined in `elements/toolchain` and `include/variables.yml` and `include/cross-compile-component.yml`.

Anything cross-compiled for the target platform will be installed directly to and live in the "path_staging_sysroot", `/rbst/staging/sysroot`, as defined by whatever embedded component build system that component uses -- The 'sysroot' dir will also use the same directory structure you're used to. Anything compiled with dependencies, etc, should use `/rbst/staging/sysroot` as its "sysroot". Defines for CFLAGS, LDFLAGS, ./configure args, etc. are all handled automatically by the build system (hard-defined in GCC/Binutils and also various vars in `include/cross-compile-component.yml`)

However, there is another directory: `/rbst/staging/image`, the "path_staging_imageprep". Items going into "sysroot" above does not directly translate into files going to the final built image for your platform. Each component is responsible for selectively choosing file from "sysroot" and placing them in "image". At the end of each element's compile process, items in `/rbst/staging/image` will be automatically stripped. If there is a specific file you do NOT want stripped, define it in the `strip-exclude` variable.


### How do you get artifacts out of BuildStream?

BuildStream has a heavier focus on caching, so any built element results in a cached artifact, and not much else unless you ask for it specifically.

The primary element we have defined is `image.bst`. This is a "compose" element that takes the image artifacts from `platform/pristine.bst` and whatever platform argument you may have defined, such as `platform/rpi.bst`. So to get both flashable images and rootfs tarballs for the Raspberry Pi, run these two commands:

1) `bst -o target_arch aarch64 -o platform rpi build image.bst`
2) `bst -o target_arch aarch64 -o platform rpi artifact checkout image.bst`

Your files will be in the "images" directory!

Want "debug" images with GDBServer in them? Add a `-o debug true` arg as well!

For a separate artifact example, we have `toolchain/export.bst`: This element simply uses `cross-compiler.bst` as a *build* dependency and then creates a tarball of `/rbst/toolchains/<target_arch_name>`! So, if you simply want a tarball of the toolchain, you need to run two commands. First to "build" this element's artifact, and then the second to *checkout* that artifact:

1) `bst -o target_arch <arch> build toolchain/export.bst`
2) `bst -o target_arch <arch> artifact checkout toolchain/export.bst`

By default, the second command will place your tarball in a directory similarly named to the element. Here, it would be the `toolchain/export` directory. See `bst artifact checkout --help` for options, including specifying alternative locations.

Note that you can run `bst artifact checkout` on **any** element to examine the files an element installs, or use `bst artifact list-contents` to just get a file list.
