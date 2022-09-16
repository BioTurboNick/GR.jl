# The GR module for Julia

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE.md)
[![GitHub tag](https://img.shields.io/github/tag/jheinen/GR.jl.svg)](https://github.com/jheinen/GR.jl/releases)
[![GR Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/GR)](https://pkgs.genieframework.com?packages=GR)
[![DOI](https://zenodo.org/badge/29193648.svg)](https://zenodo.org/badge/latestdoi/29193648)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jheinen/GR.jl/master)
[![Join the chat at https://gitter.im/jheinen/GR.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jheinen/GR.jl?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![Screenshots](https://gr-framework.org/_images/screenshots.png)](https://gr-framework.org)

This module provides a Julia interface to
[GR](http://gr-framework.org/), a framework for
visualisation applications.

## Installation

From the Julia REPL an up to date version can be installed with:

    Pkg.add("GR")

or in the [Pkg REPL-mode](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1):

    add GR

The Julia package manager will download and install a pre-compiled
run-time (for your hardware architecture), if the GR software is not
already installed in the recommended locations.

## Getting started

In Julia simply type ``using GR`` and begin calling functions
in the [GR framework](http://gr-framework.org/julia-gr.html) API.

Let's start with a simple example. We generate 10,000 random numbers and
create a histogram. The histogram function automatically chooses an appropriate
number of bins to cover the range of values in x and show the shape of the
underlying distribution.

```julia
using GR
histogram(randn(10000))
```

## Using GR as backend for Plots.jl

``Plots`` is a powerful wrapper around other Julia visualization
"backends", where ``GR`` seems to be one of the favorite ones.
To get an impression how complex visualizations may become
easier with [Plots](https://juliaplots.github.io), take a look at
[these](https://docs.juliaplots.org/latest/generated/gr/)  examples.

``Plots`` is great on its own, but the real power comes from the ecosystem surrounding it. You can find more information
[here](https://docs.juliaplots.org/latest/ecosystem/).

## Alternatives

Besides ``GR`` and ``Plots`` there is a nice package called [GRUtils](https://github.com/heliosdrm/GRUtils.jl) which provides a user-friendly interface to the low-level ``GR`` subsytem, but in a more "Julian" and modular style. Newcomers are recommended to use this package. A detailed documentation can be found [here](https://heliosdrm.github.io/GRUtils.jl/stable/).

``GR`` and ``GRUtils`` are currently still being developed in parallel - but there are plans to merge the two modules in the future.
## Basic Troubleshooting

Due to conflicts with already installed GR installations or problems with the download, it can happen that the GR runtime environment is not found. Unfortunately, to classify the problem, one can only proceed step by step:

1. The first troubleshooting step is to force GR to rebuild. This should reset GR to using GR_jll.

   ```julia
   ENV["JULIA_DEBUG"] = "GR" # Turn on debug statements    for the GR package
   ENV["GRDIR"] = "" # Force GR to rebuild from default settings
   import Pkg; Pkg.build("GR")
   using GR
   ```

   Check the generated build.log for errors.

2. The second step is try binaries from GR tarballs which are provided directly by the GR developers as self-contained distributions for selected platforms - independent of the programming language

   ```julia
   ENV["JULIA_DEBUG"] = "GR" # Turn on debug statements for the GR package
   ENV["GRDIR"] = ""
   ENV["JULIA_GR_PROVIDER"] = "GR"
   # ENV["JULIA_GR_PROVIDER"] = "BinaryBuilder" # Alternatively, uncomment this
   import Pkg; Pkg.build("GR")
   using GR
   ```

3. There might be an issue with GR_jll. Check if it can be loaded.

   ```julia
   import Pkg; Pkg.add("GR_jll")
   using GR_jll
   ccall( (:gr_initgr, "libGR",), Nothing, () )
   ```

   If none of these steps lead to success, please contact the developers.
