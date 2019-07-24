"""
    shake(package; verbose = false) -> List of unused dependencies

Uses SnoopCompile to step through package build & tests, and then diffs it against things you've included in your `Project.toml`.
"""
function shake(package; verbose = false)
    # raw snooping
    log_file = tempname()

    call = quote
        SnoopCompile.@snoopc $log_file begin
            using Pkg, $package
            if isfile(joinpath(dirname(dirname(pathof($package))), "build", "deps.jl"))
                include(joinpath(dirname(dirname(pathof($package))), "build", "deps.jl"))
            end
            include(joinpath(dirname(dirname(pathof($package))), "test", "runtests.jl"))
        end
    end

    @info "Snooping `] build` and `] test` for $package..."

    if verbose
        eval(call)
    else
        @suppress eval(call)
    end

    # process snooping
    data = SnoopCompile.read(log_file)
    pc = SnoopCompile.parcel(reverse!(data[2]))
    rm(log_file)

    # construct deps sets
    @info "Diffing dependencies..."
    used = [String(key) for key in keys(pc)]; 
    ctx = Pkg.Types.Context()
    pkg_ctx = ctx.env.manifest[ctx.env.project.deps[package]]
    listed = keys(pkg_ctx.deps)

    # filtering step, just to reduce false positives
    low_hanging_fruit = setdiff(listed, used)
    @info "Filtering..."
    filter!(fruit -> ~any(occursin.(Ref(fruit), data[2])), low_hanging_fruit)

    @info "These project deps are unused in tests: $low_hanging_fruit"
    return low_hanging_fruit
end
