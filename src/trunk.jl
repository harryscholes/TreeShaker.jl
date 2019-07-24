"""
    shake(package; verbose = false) -> List of unused dependencies

Uses SnoopCompile to step through package build & tests, and then diffs it against things you've included in your `Project.toml`.
"""
function shake(package::Module; verbose = false)
    # raw snooping 
    name = randstring(12)
    
    modroot = dirname(dirname(pathof(package)))
    
    call_build = """
    SnoopCompile.@snoopc """/tmp/$(name)_test.log""" begin
        using Pkg
        Pkg.dev($modroot)
        cd($modroot)
        Pkg.instantiate()
        include(joinpath("deps", "build.jl"))
    end
    """
    call_test = """
    SnoopCompile.@snoopc "/tmp/$(name)_build.log" begin
        using $string(package), Pkg
        include(joinpath($modroot, "test", "runtests.jl"))
    end
    """

    @info "Snooping on `] build $(string(package))`..."
    
    if verbose 
        eval(Meta.parse(call_build));
    else 
        @suppress eval(Meta.parse(call_build));
    end
    
    @info "Snooping on `] test $(string(package))`..."
    
    if verbose 
        eval(Meta.parse(call_test));
    else 
        @suppress eval(Meta.parse(call_test));
    end

    # process snooping 
    data_build = SnoopCompile.read("/tmp/$(name)_build.log");
    rm("/tmp/$(name)_build.log")
    data_test = SnoopCompile.read("/tmp/$(name)_test.log");
    rm("/tmp/$(name)_test.log")
    
    pc_build = SnoopCompile.parcel(reverse!(data_build[2]));
    pc_test = SnoopCompile.parcel(reverse!(data_test[2]));

    # construct deps sets
    @info "Diffing dependencies..."
    @show vcat(keys(pc_build),keys(pc_test))
    used = [String(key) for key in vcat(keys(pc_build),keys(pc_test))]; 
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
