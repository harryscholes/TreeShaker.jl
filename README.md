# TreeShaker.jl
Shake packages until unused deps fall off.

[![Build Status](https://travis-ci.com/arnavs/TreeShaker.jl.svg?branch=master)](https://travis-ci.com/arnavs/TreeShaker.jl)

Uses [SnoopCompile](https://github.com/timholy/SnoopCompile.jl) to step through package build & tests, and then diffs it against things you've used in your `Project.toml`.

Relies on good (ideally 100%) test code coverage, but there are likely to be many edge cases, so take the fruit with a pinch of salt.

## Usage 

I added a few spurious packages to my local copy of `Expectations.jl`, and then ran: 

```
julia> using TreeShaker

julia> shake("Expectations")
[ Info: Snooping `]build` and `]test` for Expectations...
[ Info: Diffing dependencies...
[ Info: Filtering...
[ Info: These project deps are unused in tests:
Set(["Weave", "Flux"])
```

Full output during snooping of build and tests can be returned with `shake("Expectations", verbose=true)`.
