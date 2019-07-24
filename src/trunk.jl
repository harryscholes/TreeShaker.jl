"""
    shake(package) -> List of unused dependencies

Uses SnoopCompile to step through package build & tests, and then diffs it against things you've included in your `Project.toml`.
"""
function shake(package)
    # raw snooping 
    name = randstring(12)

    call = """
    SnoopCompile.@snoopc "/tmp/$name.log" begin
        using Pkg, $package
        isfile(joinpath(dirname(dirname(pathof($package))), "build", "deps.jl")) ? include(joinpath(dirname(dirname(pathof($package))), "build", "deps.jl")) : nothing
        include(joinpath(dirname(dirname(pathof($package))), "test", "runtests.jl")) end    
    """

    @info "Snooping `] build` and `] test` for $package..."
    eval(Meta.parse(call));

    # process snooping 
    data = SnoopCompile.read("/tmp/$name.log");
    pc = SnoopCompile.parcel(reverse!(data[2]));
    rm("/tmp/$name.log")

    # construct deps sets
    @info "Diffing dependencies..."
    used = [String(key) for key in keys(pc)]; 
    ctx = Pkg.Types.Context()
    pkg_ctx = ctx.env.manifest[ctx.env.project.deps[package]]
    listed = keys(pkg_ctx.deps)

    # filtering step, just to reduce false positives 
    lowHangingFruit = setdiff(listed, used)
    @info "Filtering..."
    filter!(fruit -> ~any(occursin.(Ref(fruit), data[2])), lowHangingFruit)

    @info "These project deps are unused in tests: $lowHangingFruit"
    return lowHangingFruit
end
