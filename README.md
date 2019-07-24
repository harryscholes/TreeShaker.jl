# TreeShaker

[![Build Status](https://travis-ci.com/arnavs/TreeShaker.jl.svg?branch=master)](https://travis-ci.com/arnavs/TreeShaker.jl)

Uses [SnoopCompile](https://github.com/timholy/SnoopCompile.jl) to step through package build & tests, and then diffs it against things you've used in your `Project.toml` 

## Usage 

I added a few spurious packages to my local copy of `Expectations.jl`, and then ran: 

```julia 
julia> using TreeShaker

julia> shake("Expectations")
Snooping tests for Expectations...
Diffing dependencies...
These project deps are unused in tests:
Set(["Weave", "Flux"])
```

Full output during snooping of build and tests can be returned with `shake("Expectations", verbose=true)`.
