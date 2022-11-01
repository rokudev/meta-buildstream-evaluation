# Hello Universe: New User Onboarding for BuildStream

Hello! Let's get you started building with BuildStream, a _Meta Build System_, which is responsible for coordinating, knowing the instructions for how to build, and knowing how to combine the results of all our different components that make up our OS!  All the individual components use their own build systems, such as Bazel, CMake, and Autotools, which BuildStream manipulates to do what we want!

## Getting started with BuildStream

This tutorial assumes that you have already installed BuildStream, and are able to run and get the output:

```
$ bst --version
1.95.3.dev0
```

If you can't get that output, then you'll need to first follow the [install instructions](https://docs.buildstream.build/master/main_install.html)!

If you can get that output, then you're ready to continue to your first BuildStream adventure!

## Using BuildStream to Build

BuildStream's easy!  To build the MetaOS, simply run:

```
~/meta-buildstream-evaluation $ bst build
```

Your first build should take a minimal amount of time, because our BuildStream project uses a Central Caching Server to store already-built artifacts that you can download and use as-is!

Now, our build command was more complicated than it appeared:  The `bst build` command by itself actually has a lot of default arguments!  It is functionally equivalent to:

```
~/meta-buildstream-evaluation $ bst -o target_arch x86_64 -o platform pristine -o debug false build image.bst
```

That's a lot of command line!  Don't worry, let's break it down:

| Argument |What it does | Options and the default |
|---|---|---|
| bst | BuildStream! ||
| -o target_arch | Selects a target architecture to cross-compile for! | Default is "x86_64". Most other devices use "armhf". Some newer use "aarch64". Some older use "arm" (soft-float).|
| -o platform | "Platforms" in BuildStream sense mean an element stack, or a collection of different elements. | Default is "pristine", our primary all-in-one stack that all platforms use. Other choices (currently) are "rpi", the Raspberry Pi Platform!|
| | _A note on "target_arch" and "platform"_ | Only certain combinations of "target_arch" and "platform" go together (BuildStream will warn otherwise). Consult your device's building guides for the correct CLI combination. For this tutorial, we'll just be using "-o target_arch aarch64 -o platform carbon"|
| -o debug | A debug flag, which enables or disables certain features and/or elements from being included in your build | Default is "false". "true" will add things like "gdbserver" and "dropbear" SSH components to the "pristine" platform. It will also change the name of your images to have "-debug" in the name.|
| build | Finally, the command to give to BuildStream:  Here, "build". | See "bst --help" for all the different BuildStream commands! |
| image.bst | The element argument to "build" | Default is "image.bst", but this can be any relative path to the "elements" directory in the meta repo! "image.bst" is special in that it will always produce a flashable image, rootfs tarball, etc, for any given combination of "target_arch" and "platform" BuildStream project options! You can safely use this default element to always build everything assigned to a given platform! |

## Your First Ticket:  A compile error in "Hello Universe"

Let's take a look at the platform stack "Hello Universe", an element stack exclusive to this training exercise.

Take a look at the file `elements/platform/hello-universe.bst`.  This is a "stack" element that simply acts as a collection of other elements:

```yml
kind: stack
description: |
  This is the stack for the "Hello Universe" example.
  Only need to add the final applications to this list:
 
depends:
- components/target/hello-universe-autotools-app.bst
- components/target/hello-universe-cmake-app.bst
```

Here, it has two dependencies, two `hello-universe-*` apps.  However, it really has 4!

If you take a look inside `elements/components/target/hello-universe-cmake-app.bst`, that element has dependencies of its own!  (Both do)

```yml
<snip>
 
depends:
  (>):
  - components/target/hello-universe-autotools-lib.bst
  - components/target/hello-universe-cmake-lib.bst
 
<snip>
```

BuildStream builds a DAG (directed acyclic graph) internally and understands how to chain and handle dependencies automatically.

The two libraries and two executables that are a part of "Hello Universe" are more or less the same, with some minor edits in naming.  It's not really important, but here's some basic info about them if you're curious:

| Name | What | Artifacts | Source Link |
|---|---|---|---|
| Example Autotools Library | Builds two libraries using the Autotools build system | libjupiter.so.0.0.0 libeuropa.so.0.0.0 | https://github.com/rokudev/example-autotools-lib |
| Example CMake Library | Builds two libraries using the CMake build system | libsaturn.so.1.2.3 libtitan.so.1.2.3 | https://github.com/rokudev/example-cmake-lib |
| Example Autotools Executable | Builds one executable using Autotools that links with 'libeuropa' and 'libjupiter' | buzz_aldrin | https://github.com/rokudev/example-autotools-app |
| Example CMake Executable | Builds one executable using CMake that links with all four of our libraries like: `-lsaturn -ltitan -leuropa -ljupiter` | neil_armstrong | https://github.com/rokudev/example-cmake-app |

## Building Hello Universe

Let's build just this Hello Universe stack:

```
~/meta-buildstream-evaluation $ bst -o target_arch aarch64 build platform/hello-universe.bst
```

Now, BuildStream outputs a lot of information, and it can be quite overwhelming!

Early in the output, something you'll want to pay attention to however is the "pipeline" that is generated:

```
Pipeline
      cached b34177c85396521ec0825e3210e3e8e4201d4356cc85e81d7ccb97310086a649 base/fdsdk/fdsdk-x86_64.bst
      cached a33ef380604526a903f3fe18d3379579dd6f4083671e71f4a1a087f51c08effd base/fdsdk/filtered.bst
      cached 336b719e7a239200eda15da43a5ff8f47ebbd3658e8a214d4f346ca187b7094f base/fdsdk/symlinks.bst
      cached 3e6d99eeb07437b928e563a25f3f12f9f35d5a232b5bcd4f768ae91ede9b8fba base/fdsdk.bst
      cached 362d619bae0f955b9c7532e91a00a5ca3d54c8d945c4888b5ce4b33126196148 base/base.bst
      cached 33d48ab45638809af87cfed1fd0d1eb631d925258385768cf3d756cbb025be3c components/host/rsync.bst
      cached 7a90990ac99a72ea1ee68e6ea1b04deb11bedd3108a262485e3c38bfc525795b system/helper-scripts.bst
      cached 9a0c380944f4e4d12100f5290b09c78897898971a2c5d8273ea52e5c2797c4c3 components/host/python3.bst
      cached e9a71d3e547e52ed6e14613d71912201b6c33f6d0c173b43ecaae2e35ab646ee toolchain/pieces/fake-bootstrap.bst
      cached d1d8447c9a8b77ed4b8af7aec928c8465d6ece6d09b461bc24cb6ee0a7200281 toolchain/pieces/binutils.bst
      cached 268d7acc8dc0d0b2e0643a7708463270d6a8ff6c3b7d392ecaa996aed230680c toolchain/pieces/kernel-headers.bst
      cached f2d5ce3686410ae8f2531b27179f6134e4b58b041dc71564a838ca2bd121b368 toolchain/pieces/gcc-minimal.bst
      cached 4343b446f124eaca7d746ad58f5c3a802c4c0f7c21629e1b336988d8a7a67e5d toolchain/pieces/glibc-headers.bst
      cached 85c8451ead5e0cf9a74c197614d95832eda1d92b80c0a0c944624bc9155776ee toolchain/pieces/gcc-initial.bst
      cached 6c17f415674f5be78cf8b65224864120b1a61029558ec494462ff892718a8d3f toolchain/pieces/glibc.bst
      cached 7d892d1f08fb43ffc70ef1a7b0d0cd387f40445bb98dc7f3cb6ffc7746917d27 toolchain/pieces/gcc-final.bst
      cached 66cb45d30667c300ebf3f99a8f783b5b7876c17e39cc90b9044f3dd7633557b8 toolchain/pieces/sysroot-staging.bst
      cached fc8aad3ff4d26fe81e0b0a4ec6169591ec0d39a372fbe2692418cf1d230a05de toolchain/cross-compiler.bst
fetch needed d0683199544681ae5fe60d946e0f9e0eaddb0cea2d8e87b7c06706d3bc616dc4 components/target/hello-universe-autotools-lib.bst
fetch needed 061fe1e71cdfa51198b688b054ff13bb60a2b6f64487da9793d58b4cb1919f32 components/target/hello-universe-autotools-app.bst
      cached 06d4d4282ec21f4a3f69a3371224122fcfd6e7c9ce0ce986f2a154a76e38d798 components/host/libressl.bst
      cached 0b533476df08c88dc5cd1dd08cc7bae55dbe606d0559b3b271caabfcaab1287e components/host/ninja.bst
      cached 15ed0ef807e0edfc635b89d5ba79e1c8f6bc54696ea3a91b2bed3da1f49a1d48 components/host/cmake.bst
fetch needed a373e0ffc9d07d9dba76a17900ee8fd5bcdeee3546d865579f4d3bb2f9525269 components/target/hello-universe-cmake-lib.bst
fetch needed 5ee1244937b6f765728251d0bd0dde0df41fc4eff215e915db6fb6945bd349be components/target/hello-universe-cmake-app.bst
     waiting a219fb1daf63e776d3454c907dc8fcaec0c638c2bd24324e382ced9d795008bb platform/hello-universe.bst
```

Your entries will either be "cached", "waiting", or "fetch needed":

| What | Meaning |
|-|-|
| cached | You don't need to build anything that has already been built! Ever! This includes locally built elements that are saved in your local cache, but also artifacts that have been downloaded from our Central Caching Server that have been built by our CI system! |
| fetch needed |This means that BuildStream needs to fetch these sources first, and then you'll be building after! |
| waiting | This means that you have sources for this element downloaded (if any), but BuildStream doesn't yet have a built artifact for it! You'll be building this element in this pipeline!| 

Now, BuildStream should successfully build the two CMake examples, as well as the Autotools library.  However, there will be a build failure in "hello-universe-autotools-app"!

You should see output like this:

```
[00:00:00][5ee12449][   build:components/target/hello-universe-cmake-app.bst] SUCCESS Running commands
[--:--:--][5ee12449][   build:components/target/hello-universe-cmake-app.bst] START   Caching artifact
[00:00:00][5ee12449][   build:components/target/hello-universe-cmake-app.bst] SUCCESS Caching artifact
[00:00:00][5ee12449][   build:components/target/hello-universe-cmake-app.bst] SUCCESS rbst/components-target-hello-universe-cmake-app/5ee12449-build.4119044.log
[00:00:06][061fe1e7][   build:components/target/hello-universe-autotools-app.bst] FAILURE Running commands
[--:--:--][061fe1e7][   build:components/target/hello-universe-autotools-app.bst] START   Caching artifact
[00:00:00][061fe1e7][   build:components/target/hello-universe-autotools-app.bst] SUCCESS Caching artifact
[00:00:06][061fe1e7][   build:components/target/hello-universe-autotools-app.bst] FAILURE Command failed

    Printing the last 20 lines from log file:
    /home/jstaehle/bst/logs/rbst/components-target-hello-universe-autotools-app/061fe1e7-build.4119044.log
    ======================================================================
          |          ^~~~
    buzz.cpp:6:1: note: 'std::cout' is defined in header '<iostream>'; did you forget to '#include <iostream>'?
        5 | #include <jupiter.h>
      +++ |+#include <iostream>
        6 |
    buzz.cpp:9:10: error: 'cout' is not a member of 'std'
        9 |     std::cout << europa_new_friend() << '\n';
          |          ^~~~
    buzz.cpp:9:10: note: 'std::cout' is defined in header '<iostream>'; did you forget to '#include <iostream>'?
    make[2]: *** [Makefile:432: buzz_aldrin-buzz.o] Error 1
    make[2]: Leaving directory '/buildstream/rbst/components/target/hello-universe-autotools-app.bst/src'
    make[1]: *** [Makefile:401: all-recursive] Error 1
    make[1]: Leaving directory '/buildstream/rbst/components/target/hello-universe-autotools-app.bst'
    make: *** [Makefile:333: all] Error 2
    make: Leaving directory '/buildstream/rbst/components/target/hello-universe-autotools-app.bst'
    Command 'make -C .  ' failed with exitcode 2
    [00:00:06] FAILURE components/target/hello-universe-autotools-app.bst: Running commands
    [--:--:--] START   [061fe1e7] components/target/hello-universe-autotools-app.bst: Caching artifact
    [00:00:00] SUCCESS [061fe1e7] components/target/hello-universe-autotools-app.bst: Caching artifact
    [00:00:06] FAILURE [061fe1e7] components/target/hello-universe-autotools-app.bst: Command failed
    ======================================================================


Build failure on element: components/target/hello-universe-autotools-app.bst

Choose one of the following options:
  (c)ontinue  - Continue queueing jobs as much as possible
  (q)uit      - Exit after all ongoing jobs complete
  (t)erminate - Terminate any ongoing jobs and exit
  (r)etry     - Retry this job
  (l)og       - View the full log file
  (s)hell     - Drop into a shell in the failed build sandbox

Pressing ^C will terminate jobs and exit

Choice: [continue]:
```

Uh oh!  BuildStream prints out the last 20 lines from the element's build log file, and here we can see it's because someone forgot to put `#include <iostream>` in their C++ file!

BuildStream provides some remedial options for you to choose from at this point.  If you're curious, you can try some of these options like "l" and ENTER to view the full logfile (or open the filename provided where it says "Printing the last 20 lines from log file").

However, let's just type "t" and ENTER to exit BuildStream.

## Using BuildStream Workspaces

Let's fix our compile error!  To do so, we need to make the source code for the example autotools app editable!  BuildStream provides "Workspaces" for this.

Let's open one for our app:

```
~/meta-buildstream-evaluation $ bst workspace open components/target/hello-universe-autotools-app.bst
```

When we do this, BuildStream will create a subdirectory in our meta repo that contains the Git repo of our element.  You can verify this by running `git remote -v` in the meta repo and in the element's:

```
~/meta-buildstream-evaluation $ git remote -v
origin  https://github.com/rokudev/meta-buildstream-evaluation.git (fetch)
origin  https://github.com/rokudev/meta-buildstream-evaluation.git (push)

~/meta-buildstream-evaluation $ cd components/target/hello-universe-autotools-app

~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ git remote -v
origin  https://github.com/rokudev/example-autotools-lib.git (fetch)
origin  https://github.com/rokudev/example-autotools-lib.git (push)
```

## Fixing the Compile Error

Navigate to the `components/target/hello-universe-autotools-app` workspace directory that BuildStream created.

Make these changes to fix the compile error.  It's a pretty easy fix, just changing the header file includes (and we can remove the unneeded ones while we're at it):

```diff
--- a/src/buzz.cpp
+++ b/src/buzz.cpp
@@ -1,6 +1,4 @@
-#include <string>
-#include <vector>
-#include <algorithm>
+#include <iostream>
 
 #include <jupiter.h>
```

Now, let's test our fix!  You can run `bst build` directly in this workspace directory without needing to specify the element after for convenience:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst -o target_arch aarch64 build
```

Or, if you like consistency with running build commands outside of workspaces, you can specify the element name after if you wish.  This is functionally the same command:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst -o target_arch aarch64 build components/target/hello-universe-autotools-app.bst
```

As a note, when running `bst build` commands, you can verify if it will build inside a workspace or not by looking at the active workspace list:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst workspace list
```

Anyway, after running your `bst build` command, your autotools app should now compile successfully!

You can verify what artifacts a certain element creates with the `bst artifact list-contents` command.  Our autotools app should have created a `buzz_aldrin` executable, placing the original/unstripped/debuggable version in our `staging/sysroot` and a release/stripped version in `staging/image`:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst -o target_arch aarch64 artifact list-contents components/target/hello-universe-autotools-app.bst
[--:--:--][        ][    main:core activity                 ] START   Loading elements
[00:00:00][        ][    main:core activity                 ] SUCCESS Loading elements
[--:--:--][        ][    main:core activity                 ] START   Resolving elements
[00:00:00][        ][    main:core activity                 ] SUCCESS Resolving elements
[--:--:--][        ][    main:core activity                 ] START   Initializing remote caches
[00:00:00][        ][    main:core activity                 ] SUCCESS Initializing remote caches
[--:--:--][        ][    main:core activity                 ] START   Query cache
[00:00:00][        ][    main:core activity                 ] SUCCESS Query cache
  components/target/hello-universe-autotools-app.bst:
        rbst
        rbst/staging
        rbst/staging/image
        rbst/staging/image/usr
        rbst/staging/image/usr/sbin
        rbst/staging/image/usr/sbin/buzz_aldrin
        rbst/staging/sysroot
        rbst/staging/sysroot/usr
        rbst/staging/sysroot/usr/bin
        rbst/staging/sysroot/usr/bin/buzz_aldrin
```

Let's run one more `bst build` command, the original platform build command we ran earlier!

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst -o target_arch aarch64 build platform/hello-universe.bst
```

You should a successful Pipeline Summary at the end (your numbers might be different):

```
Pipeline Summary
    Total:       26
    Session:     26
    Pull Queue:  processed 0, skipped 13, failed 0
    Fetch Queue: processed 0, skipped 13, failed 0
    Build Queue: processed 1, skipped 12, failed 0
    Push Queue:  processed 0, skipped 13, failed 0
```

## Creating a Commit

The normal workflow at this point would be to create a new branch, create a commit, push your dev branch to the upstream GitHub server, and then create a Pull Request for your branch into "main".  We won't be doing that for this example, simply because this is a BuildStream training exercise, not a Git one.

For this training exercise, let's just create a commit directly in "main" (don't worry, GitHub won't allow you to push).  Do note that this is in the "hello-universe-autotools-app" Git repo, not the "meta-buildstream-evaluation" meta repo.

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ git checkout main
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ git add src/buzz.cpp
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ git commit -m "My first commit, fix buzz.cpp"
```

Take a look at `git log`, and take note of the Git Commit ID that is generated.  Yours will be different, but mine here is `42c8af16`:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ git log
* commit 42c8af16ce67cae8c52f5d301489c8c135aad203 (HEAD -> main)
| Author: Jake Staehle <jstaehle@roku.com>
| Date:   Tue Oct 11 11:12:08 2022 -0500
|
|     My first commit, fix buzz.cpp
|
```

## Updating the BuildStream Metadata Ref / Placing Your Commit in Metadata Main

This step would emulate what happens after a Merge Request is approved and merged into main.  So, let's pretend that happened, and work on the step that occurs after that:  Updating the commit reference in the BuildStream metadata!

Head back to the root of the meta repo:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ cd ../../..
~/meta-buildstream-evaluation $ ls
components  docker  elements  files  include  keys  patches  scripts  sources  project.conf  README.md
```

Then, since we committed to "hello-universe-autotools-app" already, and BuildStream stores the Git metadata in its own cache, we can close our workspace for it:

```
~/meta-buildstream-evaluation $ bst workspace close --remove-dir components/target/hello-universe-autotools-app.bst
```

Now, we can have BuildStream automatically update our ref in the element .bst file automatically with the `bst source track` command:

```
~/meta-buildstream-evaluation $ bst source track components/target/hello-universe-autotools-app.bst
```

Take a look at `git diff` here now to see what changed:

```
~/meta-buildstream-evaluation $ git diff
diff --git a/elements/components/target/hello-universe-autotools-app.bst b/elements/components/target/hello-universe-autotools-app.bst
index 20e304f..7664635 100644
--- a/elements/components/target/hello-universe-autotools-app.bst
+++ b/elements/components/target/hello-universe-autotools-app.bst
@@ -11,7 +11,7 @@ sources:
- kind: git
url: github-public:rokudev/example-autotools-app.git
track: main
- ref: d2aca47368c31f5741ebadd81d459cf5a72e5b0a
+ ref: 42c8af16ce67cae8c52f5d301489c8c135aad203

depends:
```

It's now the same `42c8af16` as the commit we just made!  This happens because this element is tracking "main" for the given git repo url, and it only updates if we run `bst source track` (or is manually changed).

At this point in a normal workflow, we would then create a second branch/commit/MR in the meta repo to get your changes really in the production "main" branch.  However, that's beyond the scope of this tutorial.

Try building our Hello Universe platform again:

```
~/meta-buildstream-evaluation/components/target/hello-universe-autotools-app $ bst -o target_arch aarch64 build platform/hello-universe.bst
```

No more compile error!  You fixed it!

**Congratulations! You have successfully completed your first BuildStream training!**

Let's just run some clean-up steps now:

```
$ git reset --hard
$ git clean -dffx
```
