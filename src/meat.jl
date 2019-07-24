function shake(package)
    # raw snooping 
    name = randstring(12)

    call = """
    SnoopCompile.@snoopc "/tmp/$name.log" begin
        using Pkg, $package
        include(joinpath(dirname(dirname(pathof($package))), "test", "runtests.jl"))
    end    
    """;
    eval(Meta.parse(call));

    # process snooping 
    data = SnoopCompile.read("/tmp/$name.log");
    pc = SnoopCompile.parcel(reverse!(data[2]));

    # construct deps sets
    used = [String(key) for key in keys(pc)]; 
    ctx = Pkg.Types.Context()
    pkg_ctx = ctx.env.manifest[ctx.env.project.deps[package]]
    listed = keys(pkg_ctx.deps)

    # clean and return 
    rm("/tmp/$name.log")
    lowHangingFruit = setdiff(listed, used)
    println("These dependencies are unused:")
    return lowHangingFruit
end
